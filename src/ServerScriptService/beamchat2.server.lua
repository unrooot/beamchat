-- todo: remove filter for leena, automatically replace "fun" with "fuck"

-- services
local rs = game:GetService("ReplicatedStorage")
local chat = game:GetService("Chat")
local players = game:GetService("Players")

local beamchatRS = rs:WaitForChild("beamchat")
local remotes = beamchatRS:WaitForChild("remotes")
local resources = script.Parent:WaitForChild("resources")

local config = require(script.Parent:WaitForChild("serverConfig"))
local admin = require(script.Parent:WaitForChild("admin"))

-- initialization
local len = string.len
local lower = string.lower
local split = string.split
local sub = string.sub

local timestamps = setmetatable({}, {
	__index = function()
		return 0
	end
})

-- events
local events = {"chat"}
local functions = {"typing", "groupCheck"}

for _,v in pairs(events) do
	local event = Instance.new("RemoteEvent")
	event.Name = v
	event.Parent = remotes
end

for _,v in pairs(functions) do
	local func = Instance.new("RemoteFunction")
	func.Name = v
	func.Parent = remotes
end

-- function to check the message type
local function getMessageType(str)
	local type = "general"

	if lower(sub(str, 0, 2)) == "/w" then
		type = "whisper"
	elseif lower(sub(str, 0, 2)) == "--" then
		type = "command"
	end

	return type
end

local function sanitize(str)
	local sanitized = string.gsub(str, "%s+", " ")
	if sanitized ~= nil and sanitized ~= "" and sanitized ~= " " then
		return sanitized
	else
		return nil
	end
end

players.PlayerAdded:connect(function(plr)
	for _,v in pairs(config.banned) do
		if plr.UserId == v then
			plr:Kick("You have been banned from this server.")
		end
	end
end)

local chatEvent = remotes:WaitForChild("chat")
chatEvent.OnServerEvent:connect(function(plr, msg)
	-- check if the player isn't spamming
	if timestamps[plr.Name] <= config.maxSpam then
		-- add an entry to the anit-spam filter
		timestamps[plr.Name] = timestamps[plr.Name] + 1
		spawn(function()
			-- take it out after config.spamLife seconds
			wait(config.spamLife)
			timestamps[plr.Name] = timestamps[plr.Name] - 1
		end)

		local type = getMessageType(msg)
		local filtered = chat:FilterStringAsync(sanitize(msg), plr, plr)

		if type == "general" then
			local chatData = {user = plr.Name, message = filtered, type = type, bubbleChat = config.bubbleChat}
			remotes.chat:FireAllClients(chatData)
		elseif type == "whisper" then
			local parameters = split(msg, " ")
			if players:FindFirstChild(parameters[2]) then
				local target = players[parameters[2]]
				if target ~= plr then
					local content = sub(filtered, 3 + len(target.Name) + 1)
					local chatData = {user = plr.Name, message = content, type = type, target = target.Name}

					-- send the message to both the sender and receiver
					remotes.chat:FireClient(plr, chatData)
					remotes.chat:FireClient(target, chatData)
				else
					remotes.chat:FireClient(plr, {user = "[system]", message = "You can't whisper to yourself.", type = "system"})
				end
			else
				remotes.chat:FireClient(plr, {user = "[system]", message = "Player not found.", type = "system"})
			end
		elseif type == "command" then
			for _,v in pairs(config.admins) do
				if plr.UserId == v then
					local command = lower(sub(split(filtered, " ")[1], 3))
					local args = split(filtered, " ")

					-- remove the command from the arguments
					table.remove(args, 1)

					admin:runCommand(plr, command, args)
				end
			end
		end
	else
		remotes.chat:FireClient(plr, {user = "[system]", message = "Please wait before sending another message.", type = "system"})
	end
end)

-- checks user groups for the client
local groupIDs = { admins = 1200769, interns = 2868472, stars = 4199740 }
local groupCheck = remotes:WaitForChild("groupCheck")

function groupCheck.OnServerInvoke(_, id)
	local player = players:GetPlayerByUserId(id)
	if player:IsInGroup(groupIDs.admins) then
		return groupIDs.admins
	elseif player:IsInGroup(groupIDs.interns) then
		return groupIDs.interns
	elseif player:IsInGroup(groupIDs.stars) then
		return groupIDs.stars
	else
		return 0
	end
end

local typing = remotes:WaitForChild("typing")
function typing.OnServerInvoke(plr, status)
	-- we don't want output spammed if someone is dead while typing
	pcall(function()
		-- in case we want to change this later
		local parent = plr.Character.Head

		if status then
			local ind = resources:WaitForChild("indicator"):Clone()
			ind.Parent = parent
			ind.Adornee = parent
		else
			local ind = parent:FindFirstChild("indicator")
			if ind then
				ind:Destroy()
			end
		end
	end)
end