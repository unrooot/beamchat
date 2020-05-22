-- beamchat2 // @unrooot
-- apr. 27th, 2020

-- services
local rs = game:GetService("ReplicatedStorage")
local sg = game:GetService("StarterGui")
local uis = game:GetService("UserInputService")

-- module memes
local beamchatRS = rs:WaitForChild("beamchat")
local modules = beamchatRS:WaitForChild("modules")
local remotes = beamchatRS:WaitForChild("remotes")

local chatModule = require(modules.chatModule)
local effects = require(modules.effects)

-- initialization
local u2 = UDim2.new
local c3 = Color3.fromRGB

local sub = string.sub
local match = string.match
local len = string.len

local plr = game:GetService("Players").LocalPlayer
local beamchat = plr:WaitForChild("PlayerGui"):WaitForChild("beamchat2")
local chatbar, chatbox = beamchat:WaitForChild("chatbar"), beamchat:WaitForChild("chatbox")

-- disable the default chat
sg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

local function finalizeSearch()
	if chatModule.searching then
		local cbInput = chatbar.input.Text
		local type, selected, results, last = chatModule.searching.type,
			chatModule.searching.selected,
			chatModule.searching.results,
			chatModule.searching.last

		chatbar.input:ReleaseFocus()

		if type == "username" then
			chatbar.input.Text = sub(cbInput, 0, #cbInput - #last) .. results[selected] .. " "
		elseif type == "emoji" then
			local endPos = #cbInput - (#last)
			if sub(last, len(last)+1) == ":" then
				endPos = #cbInput - (#last + 1)
			end

			chatbar.input.Text = sub(cbInput, 0, endPos) .. results[2][results[1][selected]]
		elseif type == "command" then
			--
		end

		chatModule.searching = nil

		local res = chatbar:FindFirstChild("results")
		if res then
			res:TweenSize(u2(0, res.Size.X.Offset, 0, 0), "Out", "Quart", 0.25, true)
			wait(0.25)
			res:Destroy()
		end

		game:GetService("RunService").RenderStepped:wait()
		chatbar.input:CaptureFocus()
	end
end

-- clicking to chat
chatbar.label.MouseButton1Click:connect(function()
	if not chatModule.chatbarToggle then
		chatModule.chatbar()
	end
end)

-- typing updates
chatbar.input:GetPropertyChangedSignal("Text"):connect(function()
	if chatModule.searching then
		if chatModule.searching.type == "username" then
			local res = chatbar:FindFirstChild("results")
			if res then
				res:TweenSize(u2(0, res.Size.X.Offset, 0, 0), "Out", "Quart", 0.25, true)
				wait(0.25)
				res:Destroy()
			end

			chatModule.searching = nil
		elseif chatModule.searching.type == "emoji" then
			local res = chatbar:FindFirstChild("results")
			if res then
				res:TweenPosition(u2(0, chatbar.input.TextBounds.X, 0, 0), "Out", "Quart", 0.25, true)
			end

			local str = chatbar.input.Text
			local lastWord = chatModule.getLastWord(str)

			if lastWord then
				if sub(str, (#str - #lastWord) + 1) == lastWord then
					if (sub(lastWord, 0, 1) == ":") and not (sub(lastWord, #lastWord) == ":") then
						if len(sub(lastWord, 2, 3)) >= 2 and not match(sub(lastWord, 2, len(lastWord)), "%p") then
							chatModule.search()
						end
					elseif sub(lastWord, #lastWord) == ":" and len(lastWord) ~= 1 then
						finalizeSearch()
					end
				end
			end
		end
	else
		local str = chatbar.input.Text
		local lastWord = chatModule.getLastWord(str)

		if lastWord then
			if sub(str, (#str - #lastWord) + 1) == lastWord then
				if (sub(lastWord, 0, 1) == ":") and not (sub(lastWord, #lastWord) == ":") then
					if len(sub(lastWord, 2, 3)) >= 2 and not match(sub(lastWord, 2, len(lastWord)), "%p") then
						chatModule.search()
					end
				elseif sub(lastWord, #lastWord) == ":" then
					finalizeSearch()
				end
			end
		end
	end
end)

-- chatbar events
chatbar.input.FocusLost:connect(function(enterPressed)
	if enterPressed then
		if not chatModule.searching then
			chatModule.chatbar(true)
		else
			chatbar.input:CaptureFocus()
		end
	end
end)

-- keyboard controls
uis.InputBegan:connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if not gpe then
			if input.KeyCode == Enum.KeyCode.Slash then
				if not chatModule.chatbarToggle then
					game:GetService("RunService").RenderStepped:wait()
					chatModule.chatbar()
				end
			end
		else
			if input.KeyCode == Enum.KeyCode.Return then
				if chatModule.searching then
					finalizeSearch()
				end
			elseif input.KeyCode == Enum.KeyCode.Tab then
				if chatModule.searching then
					finalizeSearch()
				else
					chatModule.search()
				end
			elseif input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down then
				if chatModule.searching then
					local res = chatbar:FindFirstChild("results")
					if res then
						-- we love ternaries
						local direction = input.KeyCode == Enum.KeyCode.Up and -1 or 1

						-- sorry for being lazy :'(
						local oldSelected = chatModule.searching.selected
						local selected, results = chatModule.searching.selected, chatModule.searching.results

						if selected + direction > #results then
							chatModule.searching.selected = 1
							oldSelected = #results
						elseif selected + direction > 0 then
							chatModule.searching.selected = selected + direction
						elseif selected + direction <= 0 then
							chatModule.searching.selected = #results
							oldSelected = 1
						end

						effects.fade(res:WaitForChild("entries")[oldSelected], 0.25, {TextTransparency = 0.4})
						res:WaitForChild("highlight"):TweenPosition(u2(0, 0, 0, 26*(chatModule.searching.selected-1)), "Out", "Quart", 0.25, true)
						effects.fade(res:WaitForChild("entries")[chatModule.searching.selected], 0.25, {TextTransparency = 0})
					end
				else
					if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down then
						local direction = input.KeyCode == Enum.KeyCode.Up and -1 or 1

						if #chatModule.chatHistory > 0 then
							if chatModule.historyPosition + direction < 0 then
								if chatModule.historyPosition ~= 1 then
									chatModule.chatCache = chatbar.input.Text
									chatModule.historyPosition = #chatModule.chatHistory
									chatbar.input.Text = chatModule.chatHistory[chatModule.historyPosition]
									chatbar.input.CursorPosition = #chatbar.input.Text + 1
								end
							elseif chatModule.historyPosition + direction > #chatModule.chatHistory then
								chatModule.historyPosition = 0
								chatbar.input.Text = chatModule.chatCache
								chatbar.input.CursorPosition = #chatbar.input.Text + 1
							else
								if chatModule.historyPosition + direction ~= 0 then
									if chatModule.historyPosition ~= 0 then
										chatModule.historyPosition = chatModule.historyPosition + direction
										chatbar.input.Text = chatModule.chatHistory[chatModule.historyPosition]
										chatbar.input.CursorPosition = #chatbar.input.Text + 1
									end
								end
							end
						end
					end
				end
			end
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		if not gpe then
			if chatModule.chatbarToggle then
				chatModule.chatbar(false)
			end
		end
	end
end)