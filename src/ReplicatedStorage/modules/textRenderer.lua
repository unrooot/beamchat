-- @unrooot, @hlelo_wolrd // text rendering module
-- jun. 24, 2020

local lib = {}
local rs = game:GetService("ReplicatedStorage")
local text = game:GetService("TextService")

local textData = {}

local u2 = UDim2.new
local c3 = Color3.fromRGB
local v2 = Vector2.new

local emotes = require(rs:WaitForChild("emotes"))
local keyframes = require(rs:WaitForChild("keyframes"))
local effects = require(rs:WaitForChild("effects"))

local function getBounds(source, contents)
	local fontSize = source.TextSize
	local font = source.Font

	return text:GetTextSize(contents, fontSize, font, Vector2.new(math.huge, 100))
end

local function addLabel(sourceLabel, newText, style)
	-- used to properly size the label
	local bounds = getBounds(sourceLabel, newText)

	local label = Instance.new("TextLabel")
	label.AnchorPoint = v2(0, 0.5)
	label.BackgroundTransparency = 1
	label.Font = sourceLabel.Font
	label.Size = u2(0, bounds.X, 0, bounds.Y)
	label.Text = newText
	label.TextColor3 = sourceLabel.TextColor3
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextSize = sourceLabel.TextSize
	label.TextStrokeTransparency = 0.7

	if style then
		for prop, val in pairs(style) do
			label[prop] = val
		end
	end

	label.Parent = sourceLabel
	table.insert(textData[sourceLabel], {label, bounds})
end

local function positionText(source)
	local width = source.AbsoluteSize.X
	local offset, line = 0, 0
	local lineHeightPx = (source.LineHeight * source.TextSize)

	for _,tup in pairs(textData[source]) do
		local obj = tup[1]
		local sz = tup[2]
		local w = sz.X

		if (offset + w) > width then
			offset = 0
			line = line + 1
		end

		obj.Position = u2(0, offset, 0, (line+0.5)*lineHeightPx)
		obj.Size = u2(0, math.min(sz.X + 1, width - offset), 0, sz.Y)
		offset = offset + w
	end

	line = line + 1
	source.Size = u2(source.Size.X.Scale, source.Size.X.Offset, 0, line*lineHeightPx)
end

local function animateEmote(img, emoteData)
	spawn(function()
		keyframes:play(img, emoteData.keyframe)
	end)
	return true
end

local function addEmote(source, emoteName, emoteData)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = v2(0, 0.5)
	frame.BackgroundTransparency = 1
	frame.Size = u2(0, emoteData.size.X, 0, emoteData.size.Y)
	frame.Parent = source

	local img = Instance.new("ImageLabel")
	img.AnchorPoint = v2(0.5, 0.5)
	img.Position = u2(0.5, 0, 0.5, 0)
	img.BackgroundTransparency = 1
	img.Image = "rbxassetid://" .. emoteData.image
	img.Size = u2(0, emoteData.size.X, 0, emoteData.size.Y)
	img.Parent = frame

	local label = Instance.new("TextLabel")
	local nameBounds = getBounds(label, ":" .. emoteName .. ":")
	label.AnchorPoint = v2(0.5, 0.5)
	label.BackgroundColor3 = c3()
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSans
	label.Position = u2(0.5, 0, 0.5, 0)
	label.Size = u2(0, nameBounds.X + 10, 1, 0)
	label.Text = ":" .. emoteName .. ":"
	label.TextColor3 = c3(255, 255, 255)
	label.TextSize = 16
	label.TextStrokeTransparency = 1
	label.TextTransparency = 1
	label.ZIndex = 2
	label.Parent = frame

	frame.MouseEnter:connect(function()
		effects.fade(label, 0.25, {BackgroundTransparency = 0.4, TextTransparency = 0, TextStrokeTransparency = 0.9})
	end)

	frame.MouseLeave:connect(function()
		effects.fade(label, 0.25, {BackgroundTransparency = 1, TextTransparency = 1, TextStrokeTransparency = 1})
	end)

	-- play animation (if it exists)
	if emoteData.keyframe then
		animateEmote(img, emoteData)
		local deb = false
		img.MouseEnter:connect(function()
			if not deb then
				deb = true
				animateEmote(img, emoteData)
				deb = false
			end
		end)
	end

	table.insert(textData[source], {frame, frame.AbsoluteSize})
end

local function updateText(source)
	local input = string.gsub(source.Text, "\n", "")

	for _,tup in pairs(textData[source]) do
		tup[1]:Destroy()
	end

	textData[source] = {}

	local tempStyle = {}
	local bold = false

	for section, modifier in string.gmatch(input .. " {}", "(.-)(\\?%b{})") do
		local startSpacing = string.match(section, "^%s+")

		if startSpacing then
			-- mandatory b/c the next pattern skips the first whitespace, not good when
			-- our non-meta might split next to whitespace -hlelo_wolrd
			addLabel(source, startSpacing)
		end

		for x in string.gmatch(section, "%S+%s*") do
			local emote, spacing = string.match(x, ":(%w+):(%s*)")
			if emote and emotes[emote] then
				addEmote(source, emote, emotes[emote])
				if #spacing > 0 then
					addLabel(source, spacing)
				end
			else
				addLabel(source, x, tempStyle)
			end
		end

		if string.sub(modifier, 1, 1) == "\\" then
			addLabel(source, string.sub(modifier, 2), tempStyle)
		elseif #modifier > 2 then
			if modifier == "{b}" then
				bold = not bold
				tempStyle.Font = bold and Enum.Font.SourceSansBold or nil
			else
				local r, g, b = string.match(modifier, "{#(%w%w)(%w%w)(%w%w)}")
				if r and g and b then
					local red = (tonumber("0x" .. r) or 0)
					local green = (tonumber("0x" .. g) or 0)
					local blue = (tonumber("0x" .. b) or 0)

					tempStyle.TextColor3 = c3(red, green, blue)
				end
			end
		else
			tempStyle = {}
		end
	end

	positionText(source)
end

function lib.renderText(sourceLabel)
	textData[sourceLabel] = {}
	updateText(sourceLabel)

	sourceLabel:GetPropertyChangedSignal("AbsoluteSize"):connect(function()
		positionText(sourceLabel)
	end)

	sourceLabel:GetPropertyChangedSignal("Text"):connect(function()
		updateText(sourceLabel)
	end)
end

return lib