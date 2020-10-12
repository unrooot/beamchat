local ts = game:GetService("TweenService")
local lib = {}

lib.fade = function(obj, len, props)
	ts:Create(obj, TweenInfo.new(len, Enum.EasingStyle.Sine), props):Play()
end

lib.autoFade = function(obj, len, target)
	local props = {}
	
	-- insert a boolvalue (or any instance, really) with the name of noFade to prevent it from being touched
	if not obj:FindFirstChild("noFade") then
		if obj:IsA("TextLabel") or obj:IsA("TextBox") then
			props = {TextTransparency = target}
		elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("ViewportFrame") then
			props = {ImageTransparency = target}
		elseif obj:IsA("ScrollingFrame") then
			props = {ScrollBarImageTransparency = target}
		elseif obj:IsA("Frame") then
			props = {BackgroundTransparency = target}
		end
	end
	
	ts:Create(obj, TweenInfo.new(len, Enum.EasingStyle.Sine), props):Play()
end

lib.fadeAll = function(obj, len, target)
	lib.autoFade(obj, len, target)
	for _,v in pairs(obj:GetDescendants()) do
		-- for hiding/showing imagebuttons & scrollingframes
		local bool = false
		if target == 0 then
			bool = true
		end
				
		if v:IsA("ImageButton") or v:IsA("ScrollingFrame") or v:IsA("TextBox") or v:IsA("TextButton") then
			v.Visible = bool
		end
		
		lib.autoFade(v, len, target)
	end
end

return lib