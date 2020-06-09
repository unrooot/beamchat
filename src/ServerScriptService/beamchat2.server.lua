-- todo: remove filter for leena, automatically replace "fun" with "fuck"

-- services
local rs = game:GetService("ReplicatedStorage")
local chat = game:GetService("Chat")
local players = game:GetService("Players")

local beamchatRS = rs:WaitForChild("beamchat")
local remotes = beamchatRS:WaitForChild("remotes")
local resources = script.Parent:WaitForChild("resources")

local config = require(script.Parent:WaitForChild("serverConfig"))

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

local function getMessageType(str)
	local type = "general"

	if lower(sub(str, 0, 2)) == "/w" then
		type = "whisper"
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

remotes.chat.OnServerEvent:connect(function(plr, msg)
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
				local content = sub(filtered, 3 + len(target.Name) + 1)

				local chatData = {user = plr.Name, message = content, type = type, target = target.Name}

				-- send the message to both the sender and receiver
				remotes.chat:FireClient(plr, chatData)
				remotes.chat:FireClient(target, chatData)
			else
				remotes.chat:FireClient({user = "[system]", message = "Player not found.", type = "system"})
			end
		end
	end
end)

function remotes.typing.OnServerInvoke(plr, status)
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