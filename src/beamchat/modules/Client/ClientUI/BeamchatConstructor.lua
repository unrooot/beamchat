local require = require(game:GetService("ReplicatedStorage"):WaitForChild("BeamchatLoader"))

local BasicPane = require("BasicPane")
local BeamchatBase = require("BeamchatBase")
local UIPaddingUtils = require("UIPaddingUtils")

local RunService = game:GetService("RunService")

local BeamchatConstructor = setmetatable({}, BasicPane)
BeamchatConstructor.__index = BeamchatConstructor

function BeamchatConstructor.new(parent)
	if RunService:IsRunning() then
		assert(parent, "[BeamchatConstructor] Parent expected!")
	end

	local base = BeamchatBase.new()
	local self = setmetatable(BasicPane.new(base.Gui), BeamchatConstructor)

	self._screenGui = Instance.new("ScreenGui")
	self._screenGui.DisplayOrder = 6
	self._screenGui.Name = "Beamchat"
	self._screenGui.ResetOnSpawn = false
	self._screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self._screenGui.Parent = parent
	self._maid:GiveTask(self._screenGui)

	self._guiPadding = UIPaddingUtils.fromUDim(UDim.new(0, 15))
	self._guiPadding.Parent = self._screenGui

	self.Gui.Parent = self._screenGui
	self.ChatBar = base.ChatBar
	self.ChatBody = base.Gui.ChatBodyContainer

	self._maid:GiveTask(base)
	base:SetVisible(true)

	return self
end

return BeamchatConstructor