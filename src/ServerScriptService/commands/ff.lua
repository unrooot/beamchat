return function(_, targets)
	for _,target in pairs(targets) do
		local ff = Instance.new("ForceField")
		ff.Parent = target.Character
	end
end