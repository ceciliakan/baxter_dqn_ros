local nn = require 'nn'
local torches = require 'torch'
require 'dpnn'
require 'classic.torch' -- Enables serialisation

local Body = classic.class('Body')

-- Architecture based on "Learning Hand-Eye Coordination for Robotic Grasping with Deep Learning and Large-Scale Data Collection"

local histLen = 4
local numFilters = 32
local motorInputs = 6
local batchSize = 32
local size = 60

local ELU_convg = 1.0 -- required param. Value used in original paper

local data = torch.FloatTensor(batchSize, histLen, 6, size, size):uniform() -- Minibatch
data[{{}, {}, {4}, {}, {}}]:zero() -- Zero motor inputs
data[{{}, {}, {4}, {1}, {1, motorInputs}}] = 2 -- 3 motor inputs

function Body:_init(opts)
  opts = opts or {}
end

function Body:createBody()
	local imageNet = nn.Sequential()
	imageNet:add(nn.Narrow(3, 1, 3)) -- Extract 1st 3 (RGB) channels
	imageNet:add(nn.PrintSize('imageNet narrow'))
	imageNet:add(nn.View(histLen * 3, size, size):setNumInputDims(4)) -- Concatenate in time
	imageNet:add(nn.PrintSize('imageNet view'))
	imageNet:add(nn.SpatialConvolution(histLen * 3, numFilters, 5, 5))
	imageNet:add(nn.ELU(ELU_convg))
	imageNet:add(nn.SpatialConvolution(numFilters, numFilters, 3, 3))
	imageNet:add(nn.ELU(ELU_convg))
	imageNet:add(nn.PrintSize('imageNet'))
	    
	local depthNet = nn.Sequential()
	depthNet:add(nn.Narrow(3, 5, 2)) -- Extract 5th channels
	depthNet:add(nn.PrintSize('depth narrow'))
	depthNet:add(nn.View(histLen*2, size, size):setNumInputDims(4))
	depthNet:add(nn.PrintSize('depthNet view'))
	depthNet:add(nn.SpatialConvolution(histLen, numFilters, 5, 5))
	depthNet:add(nn.ELU(ELU_convg))
	depthNet:add(nn.SpatialConvolution(numFilters, numFilters, 3, 3))
	depthNet:add(nn.ELU(ELU_convg))
	depthNet:add(nn.PrintSize('depthNet'))
	
	local branches = nn.ConcatTable() -- Apply each module to input
	branches:add(imageNet)
	branches:add(depthNet)
	--local branches = imageNet
	
	local RGBDnet = nn.Sequential()
	--RGBDnet:add(nn.View(-1, histLen, 6, size, size)) -- Always pass through as batch (not using setNumInputDims)
	RGBDnet:add(branches)
	RGBDnet:add(nn.PrintSize('branches'))
	RGBDnet:add(nn.JoinTable(2, 4))
	RGBDnet:add(nn.PrintSize('jointable'))
	RGBDnet:add(nn.SpatialConvolution(numFilters, numFilters, 3, 3))
	RGBDnet:add(nn.ELU(ELU_convg))
	RGBDnet:add(nn.PrintSize('RGBDnet'))
    
	local RGBD = RGBDnet:forward(data)
	
	local convOutputSizes = RGBD:size()
	print('RGBDnet output size storage:')
	print(convOutputSizes)
	--[[local convOutputDim = RGBD:nDimension()
	print("RGBD output dim:")
	print(convOutputDim)
	convOutputSizes = torch.FloatTensor(convOutputSizes)
	print("dimension mul:")
	print (convOutputSizes)
	convOutputSizes	= torches.prod(convOutputSizes)
	print("output size:")
	print (convOutputSizes)]]--
	RGBDnet:add(nn.View(2768896):setNumInputDims(3)) --unroll
	
	RGBDnet:add(nn.PrintSize('RGBDnet unrolled'))

	local motorNet = nn.Sequential()
	motorNet:add(nn.Narrow(3, 4, 1)) -- Extract 4th channel
	motorNet:add(nn.View(histLen, size, size):setNumInputDims(4)) -- Concatenate in time
	motorNet:add(nn.Narrow(3, 1, 1)) -- Extract motor inputs row
	motorNet:add(nn.Narrow(4, 1, motorInputs)) -- Extract motor inputs
	motorNet:add(nn.View(histLen * motorInputs):setNumInputDims(3)) -- Unroll
	motorNet:add(nn.Linear(histLen * motorInputs, numFilters)) -- Expand to number of convolutional feature maps
	--motorNet:add(nn.Replicate(convOutputSizes[3], 2, 1)) -- Replicate over height (begins spatial tiling)
	--motorNet:add(nn.Replicate(convOutputSizes[4], 3, 2)) -- Replicate over width (completes spatial tiling)
	motorNet:add(nn.PrintSize(motorNet))
	
	local M = motorNet:forward(data)
	local merge = nn.JoinTable(2,1):forward{RGBD,M}
	--[[local net = nn.Sequential()
	net:add(nn.View(-1, histLen, 5, size, size)) -- Always pass through as batch (not using setNumInputDims)
	net:add(merge)
	net:add(nn.JoinTable(1, 3))
	net:add(nn.SpatialConvolution(2 * numFilters, numFilters, 3, 3))
	--]]
	
	return merge
end

return Body