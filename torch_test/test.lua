require 'image'
require 'ros'
require 'torch'
local BaxterEnvClass = require "BaxterEnv"

local demo = BaxterEnvClass{}

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

demo:step(0) -- required to publish processed images

while true do
	sleep(1)
	ros.spinOnce()
	demo:msgToImg()
	-- first three channels of image contain rgb information
	-- 4th channel contains motor angle information
	print('tensor size')
	print(demo.screen:size())
	imgd = demo.screen[{{1,3},{},{}}]
	imgd:mul(255)
	
	image.display(imgd)
	print('Image subtensor:')
	print(imgd[{ 2, {30,40}, {30,40} }])
	

	imgdep = demo.screen[{ {5,7},{},{} }]
	--imgdep:mul(255)	
	
	--[[dep1 = imgdep[{ 1, {}, {} }]
	dep2 = imgdep[{ 2, {}, {} }]
	print('endian')
	print(demo.dep_endian)
	print("Check for subtensor values in depth image:")	
	print(imgdep[{ 1,{1,10}, {1,10} }])
	print(imgdep[{ 2, {1,10}, {1,10} }])
	print("max min:")
	print(torch.max(imgdep))
	print(torch.min(imgdep))--]]
	image.display(imgdep)
	
	--[[

	local out = assert(io.open("./dep1a.csv", "w"))
	splitter = ","
	for i=1,dep1:size(1) do
		for j=1,dep1:size(2) do
			out:write(dep1[i][j])
			if j == dep1:size(2) then
				out:write("\n")
			else
				out:write(splitter)
			end
		end
	end

	out:close()
	
	local ou = assert(io.open("./dep2.csv", "w"))
	splitter = ","
	for i=1,dep2:size(1) do
		for j=1,dep2:size(2) do
			ou:write(dep2[i][j])
			if j == dep2:size(2) then
				ou:write("\n")
			else
				ou:write(splitter)
			end
		end
	end

	ou:close()
	--]]
	
	-- wrist motor position (normalised to 255)
	print("1st motor data:")
	print(demo.screen[4][1][1])
	print("task completion:")
	print(demo.signal)
	print('step')
	print(demo.count)
	if (demo.signal == 10) then
		print("Task Completed")
		demo:sendMessage("reset")
		demo:waitForResponse("reset")
		end
	print("Ready for command")
	local cmd = io.read()
	if (cmd == e) then
		demo:_close()
		break
	end
	demo:sendMessage(cmd)
	demo:waitForResponse(cmd)
	
end



