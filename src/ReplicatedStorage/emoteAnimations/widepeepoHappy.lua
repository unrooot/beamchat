local rs = game:GetService("ReplicatedStorage")
local spr = require(script.Parent.Parent:WaitForChild("modules"):WaitForChild("spr"))

local u2 = UDim2.new

local function keyframes(gui)
	return {
		function()
			spr.target(gui, 0.6, 4, {
				Size = u2(0, 80*0.6, 0, 19*1.15)
			})
		end;

		0.14;

		function()
			spr.target(gui, 0.6, 4, {
				Size = u2(0, 80*1.25, 0, 19*0.75)
			})
		end;

		0.14;

		function()
			spr.target(gui, 0.6, 4, {
				Size = u2(0, 80*0.4, 0, 19*1.3)
			})
		end;

		0.14;

		function()
			spr.target(gui, 0.6, 4, {
				Size = u2(0, 80*1.15, 0, 19*0.85)
			})
		end;

		0.14;

		function()
			spr.target(gui, 0.6, 4, {
				Size = u2(0, 80*0.95, 0, 19*1.05)
			})
		end;

		0.14;

		function()
			spr.target(gui, 0.6, 4, {
				Size = u2(0, 80*1.05, 0, 19*0.95)
			})
		end;

		0.14;

		function()
			spr.target(gui, 1, 1, {
				Size = u2(0, 80, 0, 19)
			})
		end;
	}
end

return keyframes