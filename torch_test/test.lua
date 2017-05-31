require 'image'
require 'ros'
require 'torch'
local BaxterEnvClass = require "BaxterEnv"

local demo = BaxterEnvClass{}

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end


while true do
	sleep(1)
	demo:step(0) -- required to publish processed images
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
	

	imgdep = demo.screen[{ {5,6},{},{} }]
	--imgdep:mul(255)	
	
	print('endian')
	print(demo.dep_endian)
	print("Check for subtensor values in depth image:")	
	print(imgdep[{ 1,{1,10}, {1,10} }])
	print(imgdep[{ 2, {1,10}, {1,10} }])
	print("max min:")
	print(torch.max(imgdep))
	print(torch.min(imgdep))
	image.display(imgdep)
	
	-- wrist motor position (normalised to 255)
	print("1st motor data:")
	print(demo.screen[4][1][1])
	print("task completion:")
	print(demo.signal)
	if (demo.signal == 1) then
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



