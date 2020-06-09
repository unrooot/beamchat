local lib = {}
lib.chatbarToggle = false
lib.searching = nil
lib.emojiSearch = {}

lib.chatHistory = {}
lib.historyPosition = 0
lib.chatCache = ""

-- services
local txt = game:GetService("TextService")
local rs = game:GetService("ReplicatedStorage")
local deb = game:GetService("Debris")

-- initialization
local beamchatRS = rs:WaitForChild("beamchat")
local modules = beamchatRS:WaitForChild("modules")
local remotes = beamchatRS:WaitForChild("remotes")

local effects = require(modules:WaitForChild("effects"))
local emoji = require(modules:WaitForChild("emoji"))
local colors = require(modules:WaitForChild("chatColors"))
local config = require(modules:WaitForChild("clientConfig"))

local u2 = UDim2.new
local c3 = Color3.fromRGB
local c3w = c3(255, 255, 255)

local sub = string.sub
local gsub = string.gsub
local gmatch = string.gmatch
local len = string.len
local find = string.find
local lower = string.lower

local plr = game:GetService("Players").LocalPlayer
local beamchat = plr:WaitForChild("PlayerGui"):WaitForChild("beamchat2"):WaitForChild("main")
local chatbar, chatbox = beamchat:WaitForChild("chatbar"), beamchat:WaitForChild("chatbox")

-- Generate the frame for any possible search results.
local function generateResultsFrame()
	local resultsFrame = Instance.new("Frame", chatbar)
	resultsFrame.AnchorPoint = Vector2.new(0, 1)
	resultsFrame.BackgroundColor3 = c3()
	resultsFrame.BorderSizePixel = 0
	resultsFrame.BackgroundTransparency = 0.5
	resultsFrame.Name = "results"
	resultsFrame.Position = u2(0, -10, 0, -10)
	resultsFrame.ClipsDescendants = true
	resultsFrame.ZIndex = 3

	local highlight = Instance.new("Frame", resultsFrame)
	highlight.BackgroundTransparency = 0.85
	highlight.BackgroundColor3 = c3(255, 255, 255)
	highlight.BorderSizePixel = 0
	highlight.ZIndex = 2
	highlight.Size = u2(1, 0, 0, 26)
	highlight.Position = u2()
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

function lib.getLastWord(queryString)
	return string.gmatch(queryString, "([^%s]+)$")() -- thanks quenty :)
end

function lib.correctBounds(default)
	if default then
		chatbar:TweenSize(u2(1, 0, 0, 35), "Out", "Quart", 0.25, true)
		chatbar.input:TweenSize(u2(1, 0, 0, 17), "Out", "Quart", 0.25, true)
	else
		local bounds = txt:GetTextSize(chatbar.input.Text, 17, Enum.Font.SourceSans, Vector2.new(chatbar.input.AbsoluteSize.X, 1000))
		chatbar:TweenSize(u2(1, 0, 0, bounds.Y + 18), "Out", "Quart", 0.25, true)
		chatbar.input.Size = u2(1, 0, 0, bounds.Y)
	end
end

-- Search for players/commands.
function lib.search()
	local input = chatbar.input.Text
	local lastWord = lib.getLastWord(input)

	if input ~= "" and input ~= nil then
		pcall(function()
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

				-- generate list if there are multiple results
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

					resultsFrame:TweenSize(u2(1, 20, 0, #matches*26), "Out", "Quart", 0.25, true)
					lib.searching = {type = "username", selected = 1, results = matches, last = lastWord}
				elseif #matches == 1 then
					local finalStr = sub(input, 0, #input - #lastWord) .. matches[1] .. " "

					if sub(lastWord, 0, 1) == "@" then
						finalStr = sub(input, 0, #input - #lastWord) .. "@" .. matches[1] .. " "
					end

					chatbar.input.Text = finalStr
				end

				wait()
				chatbar.input:CaptureFocus()
			elseif sub(lastWord, 0, 1) == ":" then
				if sub(input, (#input - #lastWord) + 1) == lastWord then
					if (sub(lastWord, 0, 1) == ":") and not (sub(lastWord, #lastWord) == ":") then
						if len(sub(lastWord, 2, 3)) >= 2 then
							-- search for relevant emojis
							local query = sub(lastWord, 2, len(lastWord))
							local results = emoji.search(query)

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
							for i,v in pairs(results) do
								if c <= 6 then
									c = c + 1
									createEmojiEntry(i, v[1], v[2])
								end
							end

							-- display results
							res:TweenSize(u2(1, 20, 0, #results*26), "Out", "Quart", 0.25, true)
							lib.searching = {type = "emoji", selected = 1, results = results, last = lastWord}
						end
					end
				end
			elseif sub(input, 0, 2) == "--" then
				print("searching command")
			end
		end)
	else
		wait()
		chatbar.input:CaptureFocus()
	end
end

-- Strip newlines and empty whitespace from the string.
-- @param {string} str - the string to sanitize.
function lib.sanitize(str)
	local sanitized = string.gsub(str, "%s+", " ")
	if sanitized ~= nil and sanitized ~= "" and sanitized ~= " " then
		return sanitized
	else
		return nil
	end
end

-- Toggle the chatbar & message sending.
-- @param {boolean} sending - Whether or not the message will be sent.
function lib.chatbar(sending)
	if not lib.chatbarToggle then
		lib.correctBounds()
		lib.chatbarToggle = true

		-- chatbar effects
		effects.fade(chatbar, 0.25, {BackgroundTransparency = 0.3})
		effects.fade(chatbar.input, 0.25, {TextTransparency = 0, Active = true, Visible = true})
		effects.fade(chatbar.label, 0.25, {TextTransparency = 1, TextStrokeTransparency = 1, Active = false, Visible = false})
		chatbar.label:TweenPosition(u2(0.1, 0, 0, -10), "Out", "Quart", 0.25, true)

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
		chatbar.label:TweenPosition(u2(0, 0, 0, -10), "Out", "Quart", 0.25, true)

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

				if sub(sanitized, 0, 2) == "/e" then
					local emoteName = lower(sub(sanitized, 4))

					-- lowercase emote map
					local emotes = {}
					local desc = plr.Character.Humanoid:FindFirstChildOfClass("HumanoidDescription")

					for x,_ in pairs(desc:GetEmotes()) do
						emotes[lower(x)] = x
					end

					-- try playing animation
					pcall(function()
						plr.Character.Animate.PlayEmote:Invoke(emoteName)
						plr.Character.Humanoid:PlayEmote(emotes[emoteName])
					end)
				else
					remotes:WaitForChild("chat"):FireServer(sanitized)
				end
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

-- Correct the chat entry sizes if the user resizes their screen.
function lib.correctSize(message)
	assert(message.ClassName == "Frame", "[chatModule] [correctSize] parameter message must be a frame.")

	-- get the new size of the message and resize accordingly
	local msgSize = txt:GetTextSize(message.message, 18, Enum.Font.SourceSansBold, Vector2.new(chatbox.AbsoluteSize.X, 1000))
	message.Size = u2(1, 0, 0, msgSize.Y == 18 and 22 or msgSize.Y+2)
end

-- Create a new message in the chatbox.
-- @param {table} chatData
-- 		{
-- 			user = [string] user, -- the user that sent the message
--			message = [string] message, -- the filtered contents of the user's message.
--			type = [string] type, -- the type of message (can be general or whisper)
-- 			optional target = [string] target -- the person who is receiving the whisper.
-- 		}
function lib.newMessage(chatData)
	local user = chatData.user
	local msg = chatData.message
	local type = chatData.type

	local container = Instance.new("Frame")
	container.Parent = chatbox
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.AnchorPoint = Vector2.new(0, 1)
	container.Name = "1"

	local posY = Instance.new("NumberValue")
	posY.Parent = container
	posY.Name = "posY"

	local userSize = txt:GetTextSize(user .. ":", 18, Enum.Font.SourceSansBold, Vector2.new(chatbox.AbsoluteSize.X, 22))
	local ulabel = Instance.new("TextLabel")
	ulabel.Parent = container
	ulabel.BackgroundTransparency = 1
	ulabel.BorderSizePixel = 0
	ulabel.Font = Enum.Font.SourceSansBold
	ulabel.TextSize = 18
	ulabel.TextColor3 = colors.getColor(user)

	-- set the username after getting the color for formatting
	if type == "whisper" then
		local target = chatData.target
		if target == plr.Name then
			user = "{whisper from} " .. user
		else
			user = "{whisper to} " .. target
		end
	end

	ulabel.Text = user .. ":"
	ulabel.Size = u2(0, userSize.X, 0, 22)
	ulabel.TextTransparency = 1
	ulabel.Name = "user"

	local msgSize = txt:GetTextSize(msg, 18, Enum.Font.SourceSansBold, Vector2.new(chatbox.AbsoluteSize.X, 1000))
	local msgLabel = Instance.new("TextLabel")
	msgLabel.Parent = container
	msgLabel.BackgroundTransparency = 1
	msgLabel.BorderSizePixel = 0
	msgLabel.Font = Enum.Font.SourceSans
	msgLabel.TextSize = 18
	msgLabel.TextColor3 = c3(255, 255, 255)
	msgLabel.Size = u2(1, 0, 1, 0)
	msgLabel.Position = u2(0, 0, 0, 2)
	msgLabel.Text = string.rep(" ", math.floor(userSize.X/3)+2) .. msg
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.TextTransparency = 1
	msgLabel.TextWrapped = true
	msgLabel.TextYAlignment = Enum.TextYAlignment.Top
	msgLabel.Name = "message"

	-- resize container
	container.Size = u2(1, 0, 0, msgSize.Y == 18 and 22 or msgSize.Y+2)

	for _,v in pairs(chatbox:GetChildren()) do
		if v:IsA("Frame") and v ~= container then
			v.posY.Value = v.posY.Value - container.Size.Y.Offset
			v.Name = tonumber(v.Name) + 1
			if config.chatAnimation == "modern" then
				v:TweenPosition(u2(0, 0, 1, (v.posY and v.posY.Value or (v.Position.Y.Offset - container.Size.Y.Offset))), "Out", "Quart", 0.25, true)
			elseif config.chatAnimation == "classic" then
				v.Position = u2(0, 0, 1, (v.posY and v.posY.Value or (v.Position.Y.Offset - container.Size.Y.Offset)))
			end
			if tonumber(v.Name) > config.chatLimit then
				effects.fade(v.message.label, 0.25, {TextTransparency = 1, TextStrokeTransparency = 1})
				effects.fade(v.user.label, 0.25, {TextTransparency = 1, TextStrokeTransparency = 1})

				deb:AddItem(v, 1)
			end
		end
	end

	container.Position = u2(0, 0, 1, container.Size.Y.Offset)
	container.Visible  = true

	effects.fade(ulabel, 0.25, {TextTransparency = 0, TextStrokeTransparency = 0.7})
	effects.fade(msgLabel, 0.25, {TextTransparency = 0, TextStrokeTransparency = 0.7})

	if config.chatAnimation == "modern" then
		container:TweenPosition(u2(0, 0, 1, 0), "Out", "Quart", 0.25, true)
	elseif config.chatAnimation == "classic" then
		container.Position = u2(0, 0, 1, 0)
	end

	local heightSum = 0
	for _,v in pairs(chatbox:GetChildren()) do
		if v:IsA("Frame") then
			heightSum = heightSum + v.AbsoluteSize.Y + 2
		end
	end

	chatbox.CanvasSize = u2(0, 0, 0, heightSum)

	-- if not inContainer then
		chatbox.CanvasPosition = Vector2.new(0, chatbox.CanvasSize.Y.Offset)
	-- end
end

return lib