local TEXT = game:GetService("TextService")

local src = script.Parent
local fontSize = src.TextSize
local font = src.Font
local transparency = src.TextTransparency
local lineHeightPx = src.LineHeight * fontSize
src.TextTransparency = 1
local textData = {}
local input = src.Text

function addTextLabel(ohtext, style)
	local sz = TEXT:GetTextSize(text, fontSize, style and style.Font or font, Vector2.new(math.huge, 100))

	local label = Instance.new("TextLabel")
	label.Font = font
	label.TextSize = fontSize
	label.TextColor3 = src.TextColor3
	label.TextStrokeColor3 = src.TextColor3
	label.TextTransparency = transparency
	label.TextStrokeTransparency = src.TextStrokeTransparency
	label.BackgroundTransparency = 1
	label.AnchorPoint = Vector2.new(0,0.5)
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Size = UDim2.new(0,sz.X, 0, sz.Y)
	label.Text = text

	if style then
		for prop, val in pairs(style) do
			label[prop] = val
		end
	end

	label.Parent = src

	table.insert(textData, {label, sz})
end

function addEmoji(emoji)
	local img = Instance.new("ImageLabel")
	img.AnchorPoint = Vector2.new(0,0.5)
	img.Size = UDim2.new(0,lineHeightPx,0,lineHeightPx)
	img.BackgroundTransparency = 1
	img.Image = "rbxassetid://399855976"
	img.Parent = src

	table.insert(textData, {img, img.AbsoluteSize})
end

local lastWidth
function positionText()
	local width = script.Parent.AbsoluteSize.X
	if width == lastWidth then return end

	local offset = 0
	local line = 0

	for _, tup in pairs(textData) do
		local obj = tup[1]
		local sz = tup[2]
		local w = sz.X
		if offset + w > width then
			offset = 0
			line = line + 1
		end

		obj.Position = UDim2.new(0, offset, 0, (line+0.5)*lineHeightPx)
		obj.Size = UDim2.new(0, math.min(sz.X+1, width-offset), 0, sz.Y)
		--[[if sz.X > width-offset then
			obj.Size = UDim2.new(0, math.min(sz.X+1, width-offset), 0, sz.Y)
		else
			obj.Size = UDim2.new(0, sz.X, 0, sz.Y)
		end]]
		offset = offset + w
	end

	line = line + 1
	src.Size = UDim2.new(src.Size.X.Scale, src.Size.X.Offset, 0, line*lineHeightPx)
end

function updateText()
	input = string.gsub(src.Text, "\n", "")
	--WARNING: we will probably have to put a stringvalue in and read that instead of the input text
	--otherwise roblox will detect that we're messing around with the filter if people put
	--bad shit in the emoji/meta text

	for _, tup in pairs(textData) do
		tup[1]:Destroy()
	end

	textData = {}
	local tempStyle = {}
	local bold = false
	for section, modifier in string.gmatch(input .. " {}", "(.-)(\\?%b{})") do
		print("@"..section.."@")

		local startSpacing = string.match(section, "^%s+")
		if startSpacing then
			addTextLabel(startSpacing)
			--we need this because the next pattern skips the first whitespace, not good when our non-meta might split
			--next to whitespace
		end
		for x in string.gmatch(section, "%S+%s*") do
			local emoji, spacing = string.match(x, ":(%w+):(%s*)")
			if emoji then
				addEmoji(emoji)
				if #spacing > 0 then
					addTextLabel(spacing)
				end
			else
				addTextLabel(x, tempStyle)
			end
		end

		if string.sub(modifier, 1, 1) == "\\" then
			addTextLabel(string.sub(modifier, 2), tempStyle)
		elseif #modifier > 2 then
			if modifier == "{b}" then
				bold = not bold
				tempStyle.Font = bold and Enum.Font.SourceSansBold or nil
			else
				local r, g, b = string.match(modifier, "{#(%w%w)(%w%w)(%w%w)}")
				if r and g and b then
					local red = (tonumber("0x"..r) or 0)/255
					local green = (tonumber("0x"..g) or 0)/255
					local blue = (tonumber("0x"..b) or 0)/255
					tempStyle.TextColor3 = Color3.new(red,green,blue)
				end
			end

		else
			tempStyle = {}
		end
	end
	positionText()
end

updateText()
src:GetPropertyChangedSignal("AbsoluteSize"):connect(positionText)
src:GetPropertyChangedSignal("Text"):connect(updateText)