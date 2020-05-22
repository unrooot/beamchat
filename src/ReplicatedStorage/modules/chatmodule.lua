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

local sub = string.sub
local gsub = string.gsub
local gmatch = string.gmatch
local match = string.match
local len = string.len
local find = string.find
local lower = string.lower

local plr = game:GetService("Players").LocalPlayer
local beamchat = plr:WaitForChild("PlayerGui"):WaitForChild("beamchat2")
local chatbar, chatbox = beamchat:WaitForChild("chatbar"), beamchat:WaitForChild("chatbox")

local function generateResultsFrame()
	local resultsFrame = Instance.new("Frame", chatbar)
	resultsFrame.AnchorPoint = Vector2.new(0, 1)
	resultsFrame.BackgroundColor3 = c3()
	resultsFrame.BorderSizePixel = 0
	resultsFrame.BackgroundTransparency = 0.5
	resultsFrame.Name = "results"
	resultsFrame.Position = u2(0, chatbar.input.TextBounds.X, 0, 0)
	resultsFrame.ClipsDescendants = true

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

	return resultsFrame
end

local function getWidth(str)
	return txt:GetTextSize(str, 17, Enum.Font.SourceSansBold, Vector2.new(1000, 20)).X
end

lib.getLastWord = function(queryString)
	return string.gmatch(queryString, "([^%s]+)$")() -- thanks quenty :)
end

-- search for players/commands
lib.search = function()
	local input = chatbar.input.Text
	local lastWord = lib.getLastWord(input)

	if input ~= "" and input ~= nil then
		if sub(input, 0, 2) ~= "--" and sub(lastWord, 0, 1) ~= ":" then
			-- search for players
			chatbar.input:ReleaseFocus()

			local matches = {}
			for result in gmatch(input, "[^%s]+") do
				if sub(input, (#input - #result) + 1) == result then
					-- strip @ from string
					local name = lower(gsub(result, "@", ""))
					for _,player in pairs(game.Players:GetPlayers()) do
						if find(lower(player.Name), name) then
							table.insert(matches, player.Name)
						end
					end
				end
			end

			-- generate list if there are only a few results
			if #matches > 1 then
				local resultsFrame = generateResultsFrame()
				local longest = ""

				for i = 1, #matches do
					if #matches[i] > #longest then
						longest = matches[i]
					end

					local t = Instance.new("TextLabel", resultsFrame.entries)
					t.BackgroundTransparency = 1
					t.BorderSizePixel = 0
					t.ZIndex = 3
					t.Size = u2(1, 0, 0, 26)
					t.TextXAlignment = Enum.TextXAlignment.Left
					t.Font = Enum.Font.SourceSansBold
					t.Name = tostring(i)
					t.Text = matches[i]
					t.TextSize = 17
					t.TextColor3 = c3w
					t.TextTransparency = i == 1 and 0 or 0.2
				end

				resultsFrame:TweenSize(u2(0, txt:GetTextSize(longest, 17, Enum.Font.SourceSansBold, Vector2.new(185, 20)).X + 10, 0, #matches*26), "Out", "Quart", 0.25, true)
				lib.searching = {type = "username", selected = 1, results = matches, last = lastWord}
			elseif #matches == 1 then
				chatbar.input.Text = sub(input, 0, #input - #lastWord) .. matches[1] .. " "
			end
		elseif sub(lastWord, 0, 1) == ":" then
			if sub(input, (#input - #lastWord) + 1) == lastWord then
				if (sub(lastWord, 0, 1) == ":") and not (sub(lastWord, #lastWord) == ":") then
					if len(sub(lastWord, 2, 3)) >= 2 and not match(sub(lastWord, 2, len(lastWord)), "%p") then
						-- search for relevant emojis
						local query = sub(lastWord, 2, len(lastWord))
						local sorted, all = emoji.search(query)

						local longest = 0

						-- clear current entries
						local res = chatbar:FindFirstChild("results") or generateResultsFrame()
						for _,v in pairs(res:WaitForChild("entries"):GetChildren()) do
							if v:IsA("TextLabel") then
								v:Destroy()
							end
						end

						-- create results list
						local function createEmojiEntry(iteration, name, obj)
							local t = Instance.new("TextLabel", res.entries)
							t.BackgroundTransparency = 1
							t.BorderSizePixel = 0
							t.ZIndex = 3
							t.Size = u2(1, 0, 0, 26)
							t.TextXAlignment = Enum.TextXAlignment.Left
							t.Font = Enum.Font.SourceSansBold
							t.Name = iteration
							t.Text = obj .. " :" .. name .. ":"
							t.TextSize = 17
							t.TextColor3 = c3w
							t.TextTransparency = iteration == 1 and 0 or 0.4
						end

						-- iterate through results
						local c = 0
						for i,v in pairs(sorted) do
							if c <= 6 then
								c = c + 1
								-- get longest emoji name for resizing
								local lengthOfCurrent = getWidth(all[v] .. " :" .. v .. ":")
								if lengthOfCurrent > longest then
									longest = lengthOfCurrent
								end

								createEmojiEntry(i, v, all[v])
							end
						end

						-- display results
						res:TweenSize(u2(0, longest + 10, 0, #sorted*26), "Out", "Quart", 0.25, true)
						lib.searching = {type = "emoji", selected = 1, results = {sorted, all}, last = lastWord}
					end
				end
			end
		elseif sub(input, 0, 2) == "--" then
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