-- module stuff
local module = {}
local cache = {}

-- services
local sg = game:GetService("StarterGui")
local players = game:GetService("Players")

-- resources
local remotes = script.Parent.Parent:WaitForChild("remotes")
local plr = players.LocalPlayer

-- ids
local groupIDs = { admins = 1200769, interns = 2868472, stars = 4199740 }
local iconIDs = { friends = 4824031110, blocked = 4824030503, premium = 4824031303, admin = 4824030199, intern = 5575476747, star = 4824031541, owner = 4824074645 } -- custom icon: moderator (3477496824)

-- garbage collection
game.Players.PlayerRemoving:Connect(function(exPlayer)
	cache[exPlayer.UserId] = nil
end)

-- check which icon to supply next to a username in the chat
function module:fetchStatusIcon(id)
	local selectedIcon

	-- prevent duplicate checks
	if cache[id] then
		return cache[id]
	end

	-- check if the user is blocked
	local userIsBlocked = false

	-- wrapping it in pcall because it keeps erroring ?
	pcall(function()
		local blocked = game:GetService("RunService"):IsStudio() == false and sg:GetCore("GetBlockedUserIds") or {}
		for i = 1, #blocked do
			if id == blocked[i] then
				userIsBlocked = true
			end
		end
	end)

	local player
	if id == plr.UserId then
		player = plr
	else
		player = players:GetPlayerByUserId(id)
	end

	local groupCheck = remotes:WaitForChild("groupCheck"):InvokeServer(id)

	-- conditions to select icons
	if userIsBlocked then
		selectedIcon = iconIDs.blocked
	elseif plr:IsFriendsWith(id) then
		selectedIcon = iconIDs.friends
	elseif id == game.CreatorId then
		selectedIcon = iconIDs.owner
	elseif groupCheck == groupIDs.admins then
		selectedIcon = iconIDs.admin
	elseif groupCheck == groupIDs.interns then
		selectedIcon = iconIDs.intern
	elseif groupCheck == groupIDs.stars then
		selectedIcon = iconIDs.star
	elseif player.MembershipType == Enum.MembershipType.Premium then
		selectedIcon = iconIDs.premium
	end

	if selectedIcon then
		cache[id] = "rbxassetid://" .. selectedIcon
		return "rbxassetid://" .. selectedIcon
	else
		cache[id] = ""
		return ""
	end
end

return module