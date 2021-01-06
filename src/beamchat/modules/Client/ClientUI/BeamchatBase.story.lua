local require = require(game:GetService("ReplicatedStorage"):WaitForChild("BeamchatLoader"))

local Maid = require("Maid")
local BeamchatConstructor = require("BeamchatConstructor")

return function(target)
	local maid = Maid.new()

	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BorderSizePixel = 0
	background.BackgroundColor3 = Color3.fromRGB(196, 227, 255)
	background.ZIndex = 0
	background.Parent = target
	maid:GiveTask(background)

	local beamchatConstructor = BeamchatConstructor.new()
	beamchatConstructor.Gui.AnchorPoint = Vector2.new(0.5, 0.5)
	beamchatConstructor.Gui.Position = UDim2.fromScale(0.5, 0.5)
	beamchatConstructor.Gui.ZIndex = 2
	beamchatConstructor.Gui.Parent = target
	beamchatConstructor:SetVisible(true)
	maid:GiveTask(beamchatConstructor)

	return function()
		maid:DoCleaning()
	end
end