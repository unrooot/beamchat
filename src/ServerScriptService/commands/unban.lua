local config = require(script.Parent.Parent:WaitForChild("serverConfig"))

return function(_, targets)
	for _,target in pairs(targets) do
		table.remove(config.banned, table.find(config.banned, target.UserId))
	end
end