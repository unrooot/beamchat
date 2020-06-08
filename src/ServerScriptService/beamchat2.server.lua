-- todo: remove filter for leena, automatically replace "fun" with "fuck"

-- services
local rs = game:GetService("ReplicatedStorage")

-- module memes
local beamchatRS = rs:WaitForChild("beamchat")
local remotes = beamchatRS:WaitForChild("remotes")

local resources = script.Parent:WaitForChild("resources")

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

remotes.chat.