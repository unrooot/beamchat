local require = require(game:GetService("ReplicatedStorage"):WaitForChild("BeamchatLoader"))

local StarterPlayer = game:GetService("StarterPlayer")
local ServerScriptService = game:GetService("ServerScriptService")

local BeamchatServer = {}

local SERVER_MASTER = ServerScriptService:WaitForChild("beamchat")
local SCRIPTS_FOLDER = SERVER_MASTER:WaitForChild("Scripts")

-- Replicates beamchat client code to the client
function BeamchatServer:Init()
	local clientCode = SCRIPTS_FOLDER:WaitForChild("Client"):Clone()
	clientCode.Name = "BeamchatClient"
	clientCode.Parent = StarterPlayer.StarterPlayerScripts
end

return BeamchatServer