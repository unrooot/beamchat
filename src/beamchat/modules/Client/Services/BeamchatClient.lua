local require = require(game:GetService("ReplicatedStorage"):WaitForChild("BeamchatLoader"))

local PlayerGuiUtils = require("PlayerGuiUtils")
local BeamchatConstructor = require("BeamchatConstructor")

local BeamchatClient = {}

function BeamchatClient:Init()
	self:_disableDefaultChat()
	BeamchatConstructor.new(PlayerGuiUtils.getPlayerGui())
end

function BeamchatClient:_disableDefaultChat()
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
end

return BeamchatClient