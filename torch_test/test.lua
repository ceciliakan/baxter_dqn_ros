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
	demo:step(0)
	ros.spinOnce()
	demo:msgToImg()
	-- first three channels of image contain rgb information
	-- 4th channel contains motor angle information
	imgd = demo.screen[{{1,3},{},{}}]
	imgd:mul(255)
	
	image.display(imgd)
	
	imgdep = demo.screen[{ {5,8},{},{} }]
	imgdep1 = imgdep[{{1,3},{},{}}]
	imgdep2 = imgdep[{3,{},{}}] + imgdep[{4,{},{}}]
	image.display(imgdep)
	image.display(imgdep1)
	image.display(imgdep2)
	

	-- wrist motor position (normalised to 255)
	print(demo.screen[4][1][1])
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



