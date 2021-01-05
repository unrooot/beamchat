-- builds beamchat on the server/client

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("beamchat"))

-- local Chat = game:GetService("Chat")
-- local Players = game:GetService("Players")

-- local Message = require("Message")
-- local Sender = require("Sender")
-- local Loader = require("Loader")

-- local Senders = {}

-- Loader.ChatRouter.OnServerEvent:Connect(function(player, message)
-- 	if not Senders[player] then
-- 		Senders[player] = Sender.new(player)
-- 	end

-- 	local newMessage = Message.new({
-- 		Sender = Senders[player],
-- 		Content = Chat:FilterStringAsync(message, player, player),
-- 		Type = "General"
-- 	})

-- 	Loader.ChatRouter:FireAllClients(newMessage)
-- end)

-- Players.PlayerRemoving:Connect(function(player)
-- 	-- clean up sender cache
-- 	if Senders[player] then
-- 		Senders[player] = nil
-- 	end
-- end)