return function(_, targets)
	for _,target in pairs(targets) do
		target:Kick("You have been kicked from the game by an admin.")
	end
end