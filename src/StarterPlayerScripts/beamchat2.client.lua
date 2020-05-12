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

local chatmodule = require(modules.chatmodule)

-- initialization
local u2 = UDim2.new
local c3 = Color3.fromRGB

local plr = game:GetService("Players").LocalPlayer
local beamchat = plr:WaitForChild("PlayerGui"):WaitForChild("beamchat2")
local chatbar, chatbox = beamchat:WaitForChild("chatbar"), beamchat:WaitForChild("chatbox")

-- disable the default chat
sg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

-- clicking to chat
chatbar.label.MouseButton1Click:connect(function()
	print("i was clicked hehe")
	if not chatmodule.chatbarToggle then
		chatmodule.chatbar()
	else
		print("she's active")
	end
end)

-- typing updates
chatbar.input:GetPropertyChangedSignal("Text"):connect(function()
	if chatmodule.searching then
		local res = chatbar:FindFirstChild("results")
		if res then
			res:TweenPosition(u2(0, chatbar.input.TextBounds.X, 0, 0), "Out", "Quart", 0.25, true)
		end
	end
end)

-- chatbar events
chatbar.input.FocusLost:connect(function(enterPressed)
	if enterPressed then
		if not chatmodule.searching then
			chatmodule.chatbar(true)
		else
			chatbar.input:CaptureFocus()
		end
	end
end)

local function finalizeSearch()
	local cbInput = chatbar.input.Text
	local type, selected, results, last = chatmodule.searching.type,
		chatmodule.searching.selected,
		chatmodule.searching.results,
		chatmodule.searching.last

	if type == "username" then
		chatbar.input.Text = string.sub(cbInput, 0, #cbInput - #last) .. results[selected] .. " "
	elseif type == "emoji" then
		--
	elseif type == "command" then
		--
	end

	chatmodule.searching = nil

	local res = chatbar:FindFirstChild("results")
	if res then
		res:TweenSize(u2(0, res.Size.X.Offset, 0, 0), "Out", "Quart", 0.25, true)
		wait(0.25)
		res:Destroy()
	end
end

-- keyboard controls
uis.InputBegan:connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if not gpe then
			if input.KeyCode == Enum.KeyCode.Slash then
				if not chatmodule.chatbarToggle then
					wait()
					chatmodule.chatbar()
				end
			end
		else
			if input.KeyCode == Enum.KeyCode.Return then
				if chatmodule.searching then
					finalizeSearch()
				end
			elseif input.KeyCode == Enum.KeyCode.Tab then
				if chatmodule.searching then
					finalizeSearch()
				else
					chatmodule.search()
				end
			elseif input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down then
				if chatmodule.searching then
					local res = chatbar:FindFirstChild("results")
					if res then
						-- we love ternaries
						local direction = input.KeyCode == Enum.KeyCode.Up and -1 or 1
						local selected, results = chatmodule.searching.selected, chatmodule.searching.results

						if selected + direction > #results then
							chatmodule.searching.selected = 1
						elseif selected + direction > 0 then
							chatmodule.searching.selected = selected + direction
						elseif selected + direction <= 0 then
							chatmodule.searching.selected = #results
						end

						res:WaitForChild("highlight"):TweenPosition(u2(0, 0, 0, 26*(chatmodule.searching.selected-1)), "Out", "Quart", 0.25, true)
					end
				end
			end
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		if not gpe then
			if chatmodule.chatbarToggle then
				chatmodule.chatbar(false)
			end
		end
	end
end)