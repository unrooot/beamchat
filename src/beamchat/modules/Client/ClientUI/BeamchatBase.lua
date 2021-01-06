local require = require(game:GetService("ReplicatedStorage"):WaitForChild("BeamchatLoader"))

local ChatBar = require("ChatBar")
local UIPaddingUtils = require("UIPaddingUtils")
local BasicPane = require("BasicPane")
local ChatBody = require("ChatBody")
local BeamchatSettings = require("BeamchatSettings")

local HIDE_AFTER_SECONDS = BeamchatSettings:Get("HIDE_AFTER_SECONDS")

local BeamchatBase = setmetatable({}, BasicPane)
BeamchatBase.__index = BeamchatBase

function BeamchatBase.new()
	local Gui = Instance.new("Frame")
	Gui.BackgroundTransparency = 1
	Gui.Size = UDim2.fromScale(0.3, 0.271)
	Gui.Name = "Container"

	local self = setmetatable(BasicPane.new(Gui), BeamchatBase)

	self._maid:GiveTask(self.Gui)

	self._lastInteraction = tick()
	self._hovering = false

	-- build other ui elements
	self:_construct()

	self._maid:GiveTask(self.VisibleChanged:Connect(function(isVisible, doNotAnimate)
		if isVisible then
			self:_attemptHide()
		end

		self.ChatBody:SetVisible(isVisible, doNotAnimate)
		self.ChatBar:SetVisible(isVisible, doNotAnimate)
	end))

	-- container hover events, handle fading in/out
	self._maid:GiveTask(self.Gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self._lastInteraction = tick()
			self._hovering = true

			self:SetVisible(true)
		end
	end))

	self._maid:GiveTask(self.Gui.MouseLeave:Connect(function()
		self._hovering = false
		self:_attemptHide()
	end))

	-- listen for typing changes
	self._maid:GiveTask(self.ChatBar.TypingStatus:GetPropertyChangedSignal("Value"):Connect(function()
		if not self.ChatBar:IsTyping() then
			self._lastInteraction = tick()
			self:_attemptHide()
		else
			self:SetVisible(true)
		end
	end))

	return self
end

function BeamchatBase:_attemptHide()
	delay(HIDE_AFTER_SECONDS, function()
		if not self._hovering and not self.ChatBar:IsTyping() then
			if tick() - self._lastInteraction >= HIDE_AFTER_SECONDS then
				self:SetVisible(false)
			end
		end
	end)
end

function BeamchatBase:_construct()
	-- create the chat body
	do
		local chatBody = Instance.new("Frame")
		chatBody.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		chatBody.BackgroundTransparency = 0.4
		chatBody.BorderSizePixel = 0
		chatBody.Name = "ChatBodyContainer"
		chatBody.Size = UDim2.new(1, 0, 1, -46)
		chatBody.Parent = self.Gui

		self.ChatBody = ChatBody.new(chatBody)
		self.ChatBody:SetVisible(true)

		self._maid:GiveTask(self.ChatBody)

		local padding = UIPaddingUtils.fromUDim(UDim.new(0, 15))
		padding.Parent = chatBody

		local chatContainer = Instance.new("Frame")
		chatContainer.BackgroundTransparency = 1
		chatContainer.Name = "container"
		chatContainer.Size = UDim2.fromScale(1, 1)
		chatContainer.Parent = chatBody
	end

	-- create the chat bar
	do
		local chatBarFrame = Instance.new("Frame")
		chatBarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		chatBarFrame.BackgroundTransparency = 0.2
		chatBarFrame.BorderSizePixel = 0
		chatBarFrame.Name = "ChatBarContainer"
		chatBarFrame.Position = UDim2.new(0, 0, 1, -42)
		chatBarFrame.Size = UDim2.new(1, 0, 0, 42)
		chatBarFrame.Parent = self.Gui

		local input = Instance.new("TextBox")
		input.BackgroundTransparency = 1
		input.Font = Enum.Font.GothamBold
		input.Name = "userInput"
		input.Position = UDim2.fromOffset(10, 10)
		input.Size = UDim2.new(1, -20, 1, -20)
		input.Text = ""
		input.TextColor3 = Color3.fromRGB(255, 255, 255)
		input.TextSize = 15
		input.TextXAlignment = Enum.TextXAlignment.Left
		input.Visible = false
		input.Parent = chatBarFrame

		local previewLabel = Instance.new("TextLabel")
		previewLabel.BackgroundTransparency = 1
		previewLabel.Position = UDim2.fromOffset(10, 10)
		previewLabel.Size = UDim2.new(1, -20, 1, -20)
		previewLabel.Font = Enum.Font.GothamBold
		previewLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		previewLabel.RichText = true
		previewLabel.TextSize = 15
		previewLabel.Text = ChatBar:GetChatLabelText()
		previewLabel.TextXAlignment = Enum.TextXAlignment.Left
		previewLabel.Name = "previewLabel"
		previewLabel.Parent = chatBarFrame

		self.ChatBar = ChatBar.new(chatBarFrame)
		self.ChatBar:SetVisible(true)
		self._maid:GiveTask(self.ChatBar)
	end
end

return BeamchatBase