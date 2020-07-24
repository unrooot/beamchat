return function(_, targets)
	for _,target in pairs(targets) do
		target.Character:BreakJoints()
	end
end