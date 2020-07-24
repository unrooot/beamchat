local config = require(script.Parent.Parent:WaitForChild("serverConfig"))

return function(_, targets)
	for _,target in pairs(targets) do
		table.insert(config.banned, target.UserId)
		target:Kick("You have been banned from this server.")
	end
end