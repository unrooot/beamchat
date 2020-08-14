-- services
local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

-- module
local admin = {}
local aliases = {"me", "all", "others"}

-- references
local commands = script.Parent.Parent.commands
local beamchatRS = rs.beamchat
local remotes = beamchatRS.remotes

-- initialization
local lower = string.lower
local find = string.find

function admin:runCommand(plr, command, args)
	local found = false
	for _,v in pairs(commands:GetDescendants()) do
		if lower(v.Name) == lower(command) then
			found = true

			local targets = {}
			local aliased = false

			-- check for things like me, others, all
			for _,alias in pairs(aliases) do
				if lower(args[1]) == alias then
					aliased = true
				end
			end

			-- compile the list of targets
			if aliased then
				local alias = lower(args[1])
				if alias == "me" then
					table.insert(targets, plr)
				elseif alias == "others" or alias == "all" then
					for _,player in pairs(players:GetPlayers()) do
						if alias == "others" then
							if player.Name ~= plr.Name then
								table.insert(targets, player)
							end
						elseif alias == "all" then
							table.insert(targets, player)
						end
					end
				end
			else
				for _,target in pairs(args) do
					for _,player in pairs(players:GetPlayers()) do
						if find(lower(player.Name), lower(target)) then
							table.insert(targets, player)
						end
					end
				end
			end

			require(v)(plr, targets)
		end
	end

	if not found then
		remotes.chat:FireClient(plr, {user = "[system]", message = "Command \"command\" not found.", type = "system"})
	end
end

return admin