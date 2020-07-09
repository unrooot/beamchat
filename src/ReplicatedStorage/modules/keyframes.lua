-- @unrooot // may 5th, 2020 (last updated may 14th, 2020)
-- github.com/unrooot/keyframes

local rs = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")
local bc2 = rs:WaitForChild("beamchat")
local modules = bc2:WaitForChild("emoteAnimations")

local format = string.format
local tinfo = TweenInfo.new

local lib = {}

local function getModule(query)
	for _,module in pairs(modules:GetDescendants()) do
		if module.Name == query then
			return module
		end
	end
end

local function playAnimation(data, asynchronous)
	for _,v in pairs(data) do
		if typeof(v) == "table" then
			-- convert to enum (if needed)
			local direction, style = v[2], v[3]
			if typeof(direction) == "string" then
				v[2] = Enum.EasingDirection[direction]
			end

			if typeof(style) == "string" then
				v[3] = Enum.EasingStyle[style]
			end

			-- play animation
			ts:Create(v[1], tinfo(v[4], v[3], v[2]), v[5]):Play()
			if not asynchronous then
				wait(v[3])
			end
		elseif typeof(v) == "number" then
			wait(v)
		elseif typeof(v) == "function" then
			v()
		end
	end
end

function lib:play(instance, animation, reverse, asynchronous, ...)
	if typeof(animation) == "string" then
		local module = getModule(animation)
		if module then
			local keyframes, reverseKeyframes = require(module)(instance, ...)
			if reverse then
				playAnimation(reverseKeyframes, asynchronous)
			else
				playAnimation(keyframes, asynchronous)
			end
		else
			warn(format("[keyframes] animation %s not found.", animation))
		end
	elseif typeof(animation) == "table" then
		playAnimation(animation, asynchronous)
	end
end

return lib