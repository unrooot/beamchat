local ts = game:GetService("TweenService")
local lib = {}

lib.fade = function(obj, len, props)
	ts:Create(obj, TweenInfo.new(len, Enum.EasingStyle.Sine), props):Play()
end

return lib