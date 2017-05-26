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
	imgd = demo.screen[{{1,3},{},{}}]
	imgd:mul(255)
	
	image.display(imgd)
	
	imgdep = demo.screen[{ 5,{},{} }]
	imgdep:mul(255)
	subtensor = imgdep[{ {1,20}, {1,20} }] 
	
	print("bit data")
	print("bit1")
	print(demo.dep_bit1)
	print('bit2')
	print(demo.dep_bit2)
	print('shiftbit2')
	print(demo.shiftbit2)
	print('or bit12')
	print(demo.or_bit12)
	
	print('endian')
	print(demo.dep_endian)
	print("Check for subtensor values in depth image:")	print(subtensor)
	print("max min:")
	print(torch.max(imgdep))
	print(torch.min(imgdep))

	--imgdep2 = imgdep[{1,{},{}}] + imgdep[{2,{},{}}]
	image.display(imgdep)
	--image.display(imgdep2)
	

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



