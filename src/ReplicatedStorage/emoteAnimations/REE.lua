local spr = require(script.Parent.Parent.modules.spr)
local u2 = UDim2.new

local function keyframes(gui)
	return {
		function()
			local t = 0
			repeat
				spr.target(gui, 1, 5, {Position = u2(0.5, -8, 0.5, 0)})
				wait(0.075)
				spr.target(gui, 1, 5, {Position = u2(0.5, 0, 0.5, 0)})
				wait(0.075)
				t = t + 1
			until
				t == 7
		end;
	}
end

return keyframes