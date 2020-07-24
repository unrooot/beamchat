return function(_, targets)
	for _,target in pairs(targets) do
		local e = Instance.new("Explosion")
		e.Parent = target.Character.HumanoidRootPart
		e.Position = e.Parent.Position
	end
end