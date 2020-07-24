return function(plr, targets)
	for _,target in pairs(targets) do
		target.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
	end
end