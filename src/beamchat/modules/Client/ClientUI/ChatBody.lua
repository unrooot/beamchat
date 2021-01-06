local require = require(game:GetService("ReplicatedStorage"):WaitForChild("BeamchatLoader"))

local BasicPane = require("BasicPane")
local Spring = require("Spring")
local SpringUtils = require("SpringUtils")
local StepUtils = require("StepUtils")
local Math = require("Math")

local ChatBody = setmetatable({}, BasicPane)
ChatBody.__index = ChatBody

function ChatBody.new(gui)
	assert(gui, "[ChatBody] Gui expected!")
	local self = setmetatable(BasicPane.new(gui), ChatBody)

	self._alphaSpring = Spring.new()
	self._alphaSpring.s = 35
	self._alphaSpring.d = 0.7

	self._maid:GiveTask(self.VisibleChanged:Connect(function(isVisible, doNotAnimate)
		self._alphaSpring.t = isVisible and 1 or 0

		if doNotAnimate then
			self._alphaSpring.p = self._alphaSpring.t
		end

		self:_startAnimation()
	end))

	self._startAnimation, self._maid._stopAnimation = StepUtils.bindToRenderStep(self._update)
	self:_startAnimation()

	return self
end

function ChatBody:SetTransparency(transparency)
	self.Gui.BackgroundTransparency = Math.map(transparency, 0, 1, 0.4, 1)
end

function ChatBody:_update()
	local animatingAlpha, alphaProgress = SpringUtils.animating(self._alphaSpring)
	local transparency = 1 - alphaProgress

	self:SetTransparency(transparency)

	return animatingAlpha
end

return ChatBody