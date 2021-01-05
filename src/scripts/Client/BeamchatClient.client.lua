local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local plr = Players.LocalPlayer
local pgui = plr.PlayerGui

-- replicate guis into playergui
for _,gui in pairs(StarterGui:GetChildren()) do
	gui:Clone().Parent = pgui
end

local beamchatFolder = game:GetService("ReplicatedStorage"):WaitForChild("beamchat")

local require = require(beamchatFolder.require)
local gcr = require("gcr")

gcr:init()
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local remotes = beamchatFolder.remotes

remotes:WaitForChild("ChatRouter").OnClientEvent:Connect(function(Message)
	print(Message.Sender)
	gcr:fire("newMessage", Message)
end)