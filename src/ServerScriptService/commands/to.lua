return function(plr, targets)
	if targets[1] then
		plr.Character.HumanoidRootPart.CFrame = targets[1].Character.CFrame
	end
end