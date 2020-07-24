return function(_, targets)
	for _,target in pairs(targets) do
		target:LoadCharacter()
	end
end