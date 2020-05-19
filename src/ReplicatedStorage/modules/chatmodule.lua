local lib = {}
lib.chatbarToggle = false
lib.searching = nil
lib.emojiSearch = {}

lib.chatHistory = {}
lib.historyPosition = 0
lib.chatCache = ""

-- services
local ts = game:GetService("TweenService")
local txt = game:GetService("TextService")
local rs = game:GetService("ReplicatedStorage")

-- initialization
local beamchatRS = rs:WaitForChild("beamchat")
local modules = beamchatRS:WaitForChild("modules")
local remotes = beamchatRS:WaitForChild("remotes")

local effects = require(modules:WaitForChild("effects"))
local emoji = require(modules:WaitForChild("emoji"))

local u2 = UDim2.new
local c3 = Color3.fromRGB
local c3w = c3(255, 255, 255)

local plr = game:GetService("Players").LocalPlayer
local beamchat = plr:WaitForChild("PlayerGui"):WaitForChild("beamchat2")
local chatbar, chatbox = beamchat:WaitForChild("chatbar"), beamchat:WaitForChild("chatbox")

-- search for players/commands
lib.search = function()
	local input = chatbar.input.Text
	local lastWord

	if input ~= "" and input ~= nil then
		for result in string.gmatch(input, "[^%s]+") do
			if string.sub(input, (#input - #result) + 1) == result then
				lastWord = result
			end
		end

		if not lastWord then
			lastWord = ""
		end

		if string.sub(input, 0, 2) ~= "--" and string.sub(lastWord, 0, 1) ~= ":" then
			print("looking for emojis :)")
			-- search for players
			chatbar.input:ReleaseFocus()

			local matches = {}
			for result in string.gmatch(input, "[^%s]+") do
				if string.sub(input, (#input - #result) + 1) == result then
					-- strip @ from string
					local name = string.lower(string.gsub(result, "@", ""))
					for _,player in pairs(game.Players:GetPlayers()) do
						if string.find(string.lower(player.Name), name) then
							table.insert(matches, player.Name)
						end
					end
				end
			end

			if #matches > 1 then
				local resultsFrame = Instance.new("Frame", chatbar)
				resultsFrame.AnchorPoint = Vector2.new(0, 1)
				resultsFrame.BackgroundColor3 = c3()
				resultsFrame.BorderSizePixel = 0
				resultsFrame.BackgroundTransparency = 0.5
				resultsFrame.Name = "results"
				resultsFrame.Position = u2(0, chatbar.input.TextBounds.X, 0, 0)
				resultsFrame.ClipDescendants = true

				local highlight = Instance.new("Frame", resultsFrame)
				highlight.BackgroundTransparency = 0.85
				highlight.BackgroundColor3 = c3(255, 255, 255)
				highlight.BorderSizePixel = 0
				highlight.ZIndex = 2
				highlight.Size = u2(1, 0, 0, 26)
				highlight.Position = u2(0, 0, 0, 0)
				highlight.Name = "highlight"

				local entries = Instance.new("Frame", resultsFrame)
				entries.BorderSizePixel = 0
				entries.BackgroundTransparency = 1
				entries.Size = u2(1, 0, 1, 0)
				entries.Name = "entries"

				local padding = Instance.new("UIPadding", entries)
				padding.PaddingLeft = UDim.new(0, 5)
				padding.PaddingRight = UDim.new(0, 5)

				local listLayout = Instance.new("UIListLayout", entries)
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder

				local longest = ""
				for i = 1, #matches do
					if #matches[i] > #longest then
						longest = matches[i]
					end

					local t = Instance.new("TextLabel", entries)
					t.BackgroundTransparency = 1
					t.BorderSizePixel = 0
					t.ZIndex = 3
					t.Size = u2(1, 0, 0, 26)
					t.TextXAlignment = Enum.TextXAlignment.Left
					t.Font = Enum.Font.GothamSemibold
					t.Name = tostring(i)
					t.Text = matches[i]
					t.TextSize = 14
					t.TextColor3 = c3w
					t.TextTransparency = i == 1 and 0 or 0.2
				end

				resultsFrame:TweenSize(u2(0, txt:GetTextSize(longest, 14, Enum.Font.GothamSemibold, Vector2.new(185, 20)).X + 10, 0, #matches*26), "Out", "Quart", 0.25, true)
				lib.searching = {type = "username", selected = 1, results = matches, last = lastWord}
			elseif #matches == 1 then
				chatbar.input.Text = string.sub(input, 0, #input - #lastWord) .. matches[1] .. " "
			end
		elseif string.sub(lastWord, 0, 1) == ":" then
			if lib.searching then
				if lib.searching.type == "emoji" then
					local res = chatbar:FindFirstChild("results")
					if res then
						res:TweenSize(u2(0, res.Size.X.Offset, 0, 0), "Out", "Quart", 0.25, true)
						wait(0.25)
						res:Destroy()
					end

					lib.searching = nil
				end
			end
		elseif string.sub(input, 0, 2) == "--" then
			print("searching command")
		end

		wait()
		chatbar.input:CaptureFocus()
	else
		wait()
		chatbar.input:CaptureFocus()
	end
end

-- strip newlines and empty whitespace
lib.sanitize = function(str)
	local sanitized = string.gsub(str, "%s+", " ")
	if sanitized ~= nil and sanitized ~= "" and sanitized ~= " " then
		return sanitized
	else
		return nil
	end
end

-- toggling the chatbar/sending messages
lib.chatbar = function(sending)
	if not lib.chatbarToggle then
		lib.chatbarToggle = true

		-- chatbar effects
		effects.fade(chatbar, 0.25, {BackgroundTransparency = 0.5})
		effects.fade(chatbar.input, 0.25, {TextTransparency = 0, Active = true, Visible = true})
		effects.fade(chatbar.label, 0.25, {TextTransparency = 1, TextStrokeTransparency = 1, Active = false, Visible = false})
		chatbar.label:TweenPosition(u2(0.025, 0, 0, 0), "Out", "Quart", 0.25, true)

		-- why doesn't it take the renderstepped wait pls?????????
		wait()
		chatbar.input:CaptureFocus()
	else
		lib.chatbarToggle = false
		-- capture user input
		local msg = chatbar.input.Text

		-- reset chatbar properties
		effects.fade(chatbar, 0.25, {BackgroundTransparency = 1})
		effects.fade(chatbar.input, 0.25, {TextTransparency = 1, Active = false, Visible = false})
		effects.fade(chatbar.label, 0.25, {TextTransparency = 0, TextStrokeTransparency = 0.9, Active = true, Visible = true})
		chatbar.label:TweenPosition(u2(), "Out", "Quart", 0.25, true)

		lib.searching = nil

		if sending then
			-- reset input if sending
			chatbar.input.Text = ""
			local sanitized = lib.sanitize(msg)
			if sanitized ~= nil then
				-- she's good to go!!!!
				table.insert(lib.chatHistory, sanitized)

				lib.historyPosition = 0
				lib.chatCache = ""

				print(sanitized)
			end
		end

		local res = chatbar:FindFirstChild("results")
		if res then
			res:TweenSize(u2(0, res.Size.X.Offset, 0, 0), "Out", "Quart", 0.25, true)
			wait(0.25)
			res:Destroy()
		end

		chatbar.input:ReleaseFocus()
	end
end

return lib