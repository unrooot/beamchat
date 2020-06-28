-- module for chatting, text rendering, etc.
-- @unrooot

local lib = {}

-- user & emoji searching
lib.chatbarToggle = false
lib.searching = nil
lib.emojiSearch = {}

-- chat history
lib.chatHistory = {}
lib.historyPosition = 0
lib.chatCache = ""

-- used for hovering effects
lib.inContainer = false

-- table of locally muted players
lib.muted = {}

-- services
local chat = game:GetService("Chat")
local deb = game:GetService("Debris")
local players = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local txt = game:GetService("TextService")

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
	resultsFrame.BackgroundTransparency = 0.15
	resultsFrame.Name = "results"
	resultsFrame.Position = u2(0, -10, 0, -10)
	resultsFrame.ClipsDescendants = true

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

function lib.fadeOut()
	effects.fade(chatbar.label, 0.25, {TextTransparency = 1, TextStrokeTransparency = 1})
end

-- Clear the search results.
function lib.clearResults()
	lib.searching = nil
	local res = chatbar:FindFirstChild("results")
	if res then
		res:TweenSize(u2(1, 20, 0, 0), "Out", "Quart", 0.25, true)
		wait(0.25)
		res:Destroy()
	end
end

-- Get the last word in a string.
-- @param {string} queryString - The string to strip the last word from.
function lib.getLastWord(queryString)
	return string.gmatch(queryString, "([^%s]+)$")() -- thanks quenty :)
end

-- Dynamically resize the bounds of the chatbar when typing.
-- @param {boolean} default - Whether or not the chatbar should reset to its default size.
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
		-- strip starting and trailing spaces
		if sub(sanitized, 0, 1) == " " then
			sanitized = sub(sanitized, 2, len(sanitized))
		end

		if sub(sanitized, len(sanitized)) == " " then
			sanitized = sub(sanitized, 0, len(sanitized)-1)
		end

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
		effects.fade(chatbox, 0.25, {BackgroundTransparency = 0.5})
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
		effects.fade(chatbox, 0.25, {BackgroundTransparency = 1})
		effects.fade(chatbar, 0.25, {BackgroundTransparency = 1})
		effects.fade(chatbar.input, 0.25, {TextTransparency = 1, Active = false, Visible = false})
		effects.fade(chatbar.label, 0.25, {TextTransparency = 0, TextStrokeTransparency = 0.85, Active = true, Visible = true})
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

				local lowerS = lower(sanitized)

				-- local chat commands!
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
				elseif sub(lowerS, 0, 9) == "/mutelist" then
					if #lib.muted == 0 then
						lib.newSystemMessage("You haven't muted anyone.")
					else
						local mutelist = ""
						for i,v in pairs(lib.muted) do
							local properCase
							for _,x in pairs(game.Players:GetPlayers()) do
								if lower(x.Name) == v then
									properCase = x.Name
								end
							end

							-- more than 2 players muted
							if #lib.muted > 1 and #lib.muted ~= 2 and #lib.muted ~= 0 then
								if i == 1 then
									mutelist = ("You have muted %s, "):format(properCase)
								elseif i ~= #lib.muted then
									mutelist = mutelist .. ("%s, "):format(properCase)
								else
									mutelist = mutelist .. ("and %s."):format(properCase)
								end
							-- only two players muted
							elseif #lib.muted == 2 then
								if i == 1 then
									mutelist = ("You have muted %s"):format(properCase)
								else
									mutelist = mutelist .. (" and %s."):format(properCase)
								end
							-- only 1 player muted
							else
								mutelist = ("You have only muted %s."):format(properCase)
							end
						end

						lib.newSystemMessage(mutelist)
					end
				elseif sub(lowerS, 0, 5) == "/mute" then
					local target = lib.sanitize(sub(lowerS, 7))

					if target == "[system]" then
						lib.newSystemMessage("no 👺")
					else
						if target ~= lower(plr.Name) and len(target) >= 3 then
							local found
							for _,v in pairs(game.Players:GetPlayers()) do
								if find(lower(v.Name), target) then
									found = v.Name
								end
							end

							if found and not table.find(lib.muted, lower(found)) then
								table.insert(lib.muted, lower(found))
								lib.newSystemMessage(("Muted %s."):format(found))
							else
								lib.newSystemMessage("Player not found.")
							end
						elseif target == lower(plr.Name) then
							lib.newSystemMessage("You can't mute yourself, silly.")
						else
							lib.newSystemMessage("Player invalid.")
						end
					end
				elseif sub(lowerS, 0, 7) == "/unmute" then
					local target = sub(lowerS, 9)
					local inTable = table.find(lib.muted, target)

					if inTable then
						table.remove(lib.muted, inTable)
						lib.newSystemMessage("Player unmuted.")
					else
						lib.newSystemMessage("You do not have that player muted.")
					end
				elseif sub(lowerS, 0, 2) == "/?" or sub(lowerS, 0, 5) == "/help" then
					--[[
						beamchat2, by moonbeam (v2.1.1)
						—————
						/emojis - See the list of custom emojis.
						/mute {plr} or /unmute {plr} - Mute/unmute a player.
						/mutelist - See the players who you have muted.
						/w {plr} {msg} - Whisper to a player.
						:emoji: - Search for emojis.
						(desktop) TAB key - Autocomplete usernames.
					]]

					local helpMessage = "beamchat2, by moonbeam (v2.1.1)\n—————\n/emotes - See the list of custom emotes.\n/mute {plr} or /unmute {plr} - Mute/unmute a player.\n/mutelist - See the players who you have muted.\n/w {plr} {msg} - Whisper to a player.\n:emoji: - Search for emojis.\n(desktop) TAB key - Autocomplete usernames."
					lib.newSystemMessage(helpMessage)
				elseif sub(lowerS, 0, 7) == "/emotes" then
					lib.newSystemMessage("This feature is not currently enabled.")
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
	local msgSize = txt:GetTextSize(message:WaitForChild("message").Text, 18, Enum.Font.SourceSansBold, Vector2.new(chatbox.AbsoluteSize.X, 1000))
	message.Size = u2(1, 20, 0, msgSize.Y == 18 and 22 or msgSize.Y+2)
end

-- Create a new message in the chatbox.
-- @param {table} chatData
-- {
-- 		user = [string] user, -- the user that sent the message
--		message = [string] message, -- the filtered contents of the user's message.
--		type = [string] type, -- the type of message (can be general or whisper)
-- 		(optional) target = [string] target -- the person who is receiving the whisper.
-- }
function lib.newMessage(chatData)
	local user = chatData.user
	local msg = chatData.message
	local type = chatData.type

	local muted = false
	for _,v in pairs(lib.muted) do
		if v == lower(user) then
			muted = true
		end
	end

	if not muted then
		local container = Instance.new("Frame")
		container.Parent = chatbox
		container.BackgroundTransparency = 1
		container.BorderSizePixel = 0
		container.AnchorPoint = Vector2.new(0, 1)
		container.Name = "1"
		container.BackgroundColor3 = c3(150, 150, 150)

		local padding = Instance.new("UIPadding")
		padding.Parent = container
		padding.PaddingLeft = UDim.new(0, 10)
		padding.PaddingRight = UDim.new(0, 10)

		local posY = Instance.new("NumberValue")
		posY.Parent = container
		posY.Name = "posY"


		local ulabel = Instance.new("TextLabel")
		ulabel.Parent = container
		ulabel.BackgroundTransparency = 1
		ulabel.BorderSizePixel = 0
		ulabel.Font = Enum.Font.SourceSansBold
		ulabel.TextSize = 18
		ulabel.TextColor3 = colors.getColor(user)

		-- set the username after getting the color for formatting & handle chat bubbles
		local userMsg = user
		if type == "whisper" then
			local target = chatData.target
			if target == plr.Name then
				userMsg = "{whisper from} " .. user
			else
				userMsg = "{whisper to} " .. target
			end
		end

		local userSize = txt:GetTextSize(userMsg .. ":", 18, Enum.Font.SourceSansBold, Vector2.new(chatbox.AbsoluteSize.X, 22))
		ulabel.Text = userMsg .. ":"
		ulabel.Size = u2(0, userSize.X, 0, 22)
		ulabel.TextTransparency = 1
		ulabel.Name = "user"

		local font = Enum.Font.SourceSans
		if type == "system" then
			font = Enum.Font.SourceSansBold
		else
			-- just in case ?
			pcall(function()
				if chatData.bubbleChat then
					chat:Chat(players[user].Character.Head, msg, 3)
				end
			end)
		end

		local msgSize = txt:GetTextSize(msg, 18, font, Vector2.new(chatbox.AbsoluteSize.X, 1000))
		local msgLabel = Instance.new("TextLabel")
		msgLabel.Parent = container
		msgLabel.BackgroundTransparency = 1
		msgLabel.BorderSizePixel = 0
		msgLabel.Font = font
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

		if find(msg, lower(plr.Name)) then
			container.BackgroundTransparency = 0.6
		end

		-- resize container
		container.Size = u2(1, 20, 0, msgSize.Y == 18 and 22 or msgSize.Y+2)

		for _,v in pairs(chatbox:GetChildren()) do
			if v:IsA("Frame") and v ~= container then
				v.posY.Value = v.posY.Value - container.Size.Y.Offset
				v.Name = tonumber(v.Name) + 1
				if config.chatAnimation == "modern" then
					v:TweenPosition(u2(0, -10, 1, (v.posY and v.posY.Value or (v.Position.Y.Offset - container.Size.Y.Offset))), "Out", "Quart", 0.25, true)
				elseif config.chatAnimation == "classic" then
					v.Position = u2(0, -10, 1, (v.posY and v.posY.Value or (v.Position.Y.Offset - container.Size.Y.Offset)))
				end
				if tonumber(v.Name) > config.chatLimit then
					effects.fade(v.message, 0.25, {TextTransparency = 1, TextStrokeTransparency = 1})
					effects.fade(v.user, 0.25, {TextTransparency = 1, TextStrokeTransparency = 1})

					deb:AddItem(v, 1)
				end
			end
		end

		container.Position = u2(0, -10, 1, container.Size.Y.Offset)
		container.Visible  = true

		effects.fade(ulabel, 0.25, {TextTransparency = 0, TextStrokeTransparency = 0.7})
		effects.fade(msgLabel, 0.25, {TextTransparency = 0, TextStrokeTransparency = 0.7})

		if config.chatAnimation == "modern" then
			container:TweenPosition(u2(0, -10, 1, 0), "Out", "Quart", 0.25, true)
		elseif config.chatAnimation == "classic" then
			container.Position = u2(0, -10, 1, 0)
		end

		local heightSum = 0
		for _,v in pairs(chatbox:GetChildren()) do
			if v:IsA("Frame") then
				heightSum = heightSum + v.AbsoluteSize.Y + 2
			end
		end

		chatbox.CanvasSize = u2(0, 0, 0, heightSum)

		if not lib.inContainer then
			chatbox.CanvasPosition = Vector2.new(0, chatbox.CanvasSize.Y.Offset)
		end
	end
end

-- Create a new system message.
-- @param {string} - The contents of the system's message.
function lib.newSystemMessage(contents)
	lib.newMessage({user = "[system]", message = contents, type = "system"})
end

return lib
