local rs = game:GetService("ReplicatedStorage")
local spr = require(rs:WaitForChild("spr"))

local u2 = UDim2.new

local function keyframes(gui)
	return {
		{gui, "Out", "Quart", 0.3, {Position = u2(0.5, 0, 0.5, -5)}};
		0.1;
		{gui, "Out", "Quart", 0.3, {Position = u2(0.5, 0, 0.5, 5)}};
		0.1;
		{gui, "Out", "Quart", 0.3, {Position = u2(0.5, 0, 0.5, -5)}};
		0.1;
		{gui, "Out", "Quart", 0.3, {Position = u2(0.5, 0, 0.5, 5)}};
		0.1;
		{gui, "Out", "Quart", 0.3, {Position = u2(0.5, 0, 0.5, -5)}};
		0.1;
		{gui, "Out", "Quart", 0.3, {Position = u2(0.5, 0, 0.5, 5)}};
		0.1;
		{gui, "Out", "Quart", 0.3, {Position = u2(0.5, 0, 0.5, 0)}};
		0.1;
	}
end

return keyframes