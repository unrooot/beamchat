local require = require(game:GetService("ReplicatedStorage"):WaitForChild("BeamchatLoader"))

local BeamchatSettings = require("BeamchatSettings")
local PlatformUtils = require("PlatformUtils")
local BasicPane = require("BasicPane")
local Spring = require("Spring")
local SpringUtils = require("SpringUtils")
local StepUtils = require("StepUtils")
local Math = require("Math")

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ChatBar = setmetatable({}, BasicPane)
ChatBar.__index = ChatBar

function ChatBar.new(gui)
	assert(gui, "[ChatBar] Gui expected!")
	local self = setmetatable(BasicPane.new(gui), ChatBar)

	self._labelSpring = Spring.new()
	self._labelSpring.s = 35
	self._labelSpring.d = 1

	self._alphaSpring = Spring.new()
	self._alphaSpring.s = 30
	self._alphaSpring.d = 1

	self._label = self.Gui.previewLabel
	self._input = self.Gui.userInput

	self.TypingStatus = Instance.new("BoolValue")
	self._maid:GiveTask(self.TypingStatus)

	-- input events
	self._maid:GiveTask(self.Gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not self:IsTyping() then
				self:StartTyping()
			end
		end
	end))

	-- more input events
	self._maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if not gameProcessedEvent then
				if input.KeyCode == Enum.KeyCode.Slash then
					RunService.RenderStepped:Wait()
					self:StartTyping()
				end
			else
				if input.KeyCode == Enum.KeyCode.Tab then
					-- search memes
				end
			end
		end
	end))

	-- label animation
	self._maid:GiveTask(self.VisibleChanged:Connect(function(isVisible, doNotAnimate)
		self._alphaSpring.t = isVisible and 1 or 0

		if doNotAnimate then
			self._alphaSpring.p = self._alphaSpring.t
		end

		self:_startAnimation()
	end))

	self._maid:GiveTask(self._input.Focused:Connect(function()

	end))

	self._maid:GiveTask(self._input.FocusLost:Connect(function(enterPressed)
		self:StopTyping()
		if enterPressed then
			self._input.Text = ""
		end
	end))

	self._startAnimation, self._maid._stopAnimation = StepUtils.bindToRenderStep(self._update)
	self:_setLabelVisibility(true)

	return self
end

function ChatBar:StartTyping()
	if self.TypingStatus.Value then
		return
	end

	self.TypingStatus.Value = true

	self._input.Visible = true
	self._input:CaptureFocus()

	self:_setLabelVisibility(false)
end

function ChatBar:StopTyping()
	self.TypingStatus.Value = false
	self._input.Visible = false
	self:_setLabelVisibility(true)
end

function ChatBar:IsTyping()
	return self.TypingStatus.Value
end

function ChatBar:GetChatLabelText()
	return self:_getTextForPlatform()
end

function ChatBar:_getTextForPlatform()
	return PlatformUtils:ClientIsMobile() and BeamchatSettings:Get("CHATBAR_LABEL_TEXT_MOBILE") or BeamchatSettings:Get("CHATBAR_LABEL_TEXT")
end

function ChatBar:_setLabelVisibility(isVisible, doNotAnimate)
	self._labelSpring.t = isVisible and 1 or 0

	if doNotAnimate then
		self._labelSpring.p = self._labelSpring.t
	elseif isVisible then
		self._labelSpring.v = self._labelSpring.v + self._labelSpring.s * 0.15
	end

	self:_startAnimation()
end

function ChatBar:_update()
	local animatingAlpha, alphaProgress = SpringUtils.animating(self._alphaSpring)
	local animatingLabel, labelProgress = SpringUtils.animating(self._labelSpring)

	local transparency = 1 - alphaProgress
	local position = 1 - labelProgress

	self.Gui.BackgroundTransparency = Math.map(transparency, 0, 1, 0.2, 1)

	self._label.TextTransparency = self:IsTyping() and position or animatingLabel and position or transparency
	self._label.Position = UDim2.new(position * 0.1, 10, 0, 10)

	self._input.TextTransparency = labelProgress

	return animatingLabel or animatingAlpha
end

return ChatBar