return function(_, targets)
	for _,target in pairs(targets) do
		target:Kick()
	end
end