local module = {}
local sg = game:GetService("StarterGui")
local groupIDs = { admins = 1200769, interns = 2868472, stars = 4199740 }
local iconIDs = { blocked = 4824030503, premium = 4824031303, admin = 4824030199, intern = 4824065185, star = 4824031541, owner = 4824074645 } -- custom icon: moderator (3477496824)


local cache = {}

game.Players.PlayerRemoving:connect(function(plr)
	cache[plr.UserId] = nil
end)

function module:fetchStatusIcon(id)
	if cache[id] then
		return cache[id]
	end
	local plr = game.Players.LocalPlayer
	local selectedIcon

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

	-- conditions to select icons
	if userIsBlocked then
		selectedIcon = iconIDs.blocked
	elseif game.Players.LocalPlayer:IsFriendsWith(id) then
		selectedIcon = iconIDs.friends
	elseif id == game.CreatorId then
		selectedIcon = iconIDs.owner
	elseif plr:IsInGroup(groupIDs.admins) then
		selectedIcon = iconIDs.admin
	elseif plr:IsInGroup(groupIDs.interns) then
		selectedIcon = iconIDs.interns
	elseif plr:IsInGroup(groupIDs.stars) then
		selectedIcon = iconIDs.star
	elseif plr.MembershipType == Enum.MembershipType.Premium then
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