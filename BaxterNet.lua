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
	local net = nn.Sequential()
	net:add(nn.View(-1, histLen, 6, size, size))
	--net:add(nn.PrintSize('net input'))
	
	local imageNet = nn.Sequential()
	--imageNet:add(nn.PrintSize('first'))
	imageNet:add(nn.Narrow(3, 1, 3)) -- Extract 1st 3 (RGB) channels
	--imageNet:add(nn.PrintSize('imageNet narrow'))
	imageNet:add(nn.View(histLen * 3, size, size):setNumInputDims(4)) -- Concatenate in time
	--imageNet:add(nn.PrintSize('imageNet view'))
	imageNet:add(nn.SpatialConvolution(histLen * 3, numFilters, 5, 5))
	imageNet:add(nn.ELU(ELU_convg))
	imageNet:add(nn.SpatialConvolution(numFilters, numFilters, 3, 3))
	imageNet:add(nn.ELU(ELU_convg))
	--imageNet:add(nn.PrintSize('imageNet'))
	    
	local depthNet = nn.Sequential()
	--depthNet:add(nn.PrintSize('depth input'))
	depthNet:add(nn.Narrow(3, 5, 2)) -- Extract 5th + 6th channels
	--depthNet:add(nn.PrintSize('depth narrow'))
	depthNet:add(nn.View(histLen*2, size, size):setNumInputDims(4))
	--depthNet:add(nn.PrintSize('depthNet view'))
	depthNet:add(nn.SpatialConvolution(histLen * 2, numFilters, 5, 5))
	depthNet:add(nn.ELU(ELU_convg))
	depthNet:add(nn.SpatialConvolution(numFilters, numFilters, 3, 3))
	depthNet:add(nn.ELU(ELU_convg))
	--depthNet:add(nn.PrintSize('depthNet'))
	
	local branches = nn.ConcatTable()
	branches:add(imageNet)
	--branches:add(depthNet)
	
	local RGBDnet = nn.Sequential()
	--RGBDnet:add(nn.View(-1, histLen, 6, size, size)) -- Always pass through as batch (not using setNumInputDims)
	--RGBDnet:add(nn.PrintSize('RGBDnet input'))
	RGBDnet:add(branches)
	--RGBDnet:add(nn.PrintSize('branches'))
	RGBDnet:add(nn.JoinTable(2, 4))
	--RGBDnet:add(nn.PrintSize('jointable'))
	RGBDnet:add(nn.SpatialConvolution(numFilters, numFilters, 3, 3)) --1st param *2 for RGBD
	--RGBDnet:add(nn.PrintSize("RGBDnet spatconv"))
	RGBDnet:add(nn.ELU(ELU_convg))
	--RGBDnet:add(nn.PrintSize('RGBDnet output size storage:'))
	RGBDnet:add(nn.View(1):setNumInputDims(3)) --unroll
	--RGBDnet:add(nn.PrintSize('RGBDnet unrolled'))
	
	local motorNet = nn.Sequential()
	--motorNet:add(nn.PrintSize('motorNet input'))
	motorNet:add(nn.Narrow(3, 4, 1)) -- Extract 4th channel
	motorNet:add(nn.View(histLen, size, size):setNumInputDims(4)) -- Concatenate in time
	--motorNet:add(nn.PrintSize('motorNet view'))
	motorNet:add(nn.Narrow(3, 1, 1)) -- Extract motor inputs row
	motorNet:add(nn.Narrow(4, 1, motorInputs)) -- Extract motor inputs
	motorNet:add(nn.View(histLen * motorInputs):setNumInputDims(3)) -- Unroll
	--motorNet:add(nn.PrintSize('motor unroll'))
	motorNet:add(nn.Linear(histLen * motorInputs, numFilters)) -- 
	--motorNet:add(nn.PrintSize('preview'))
	motorNet:add(nn.View(1):setNumInputDims(1))
	--motorNet:add(nn.PrintSize('motorNet'))
	
	
	local merge = nn.ConcatTable()
	merge:add(RGBDnet)
	merge:add(motorNet)
		
	
	net:add(merge)
	--net:add(nn.PrintSize('net add merge'))
	net:add(nn.JoinTable(1,2))
	--net:add(nn.PrintSize('net'))
	--[[
	for i,mod in ipairs(net:listModules()) do
		print(mod)
	end]]
	return net
end

return Body
