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
	if not chatmodule.chatbarToggle then
		chatmodule.chatbar()
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
		chatmodule.chatbar(true)
	end
end)

-- keyboard controls
uis.InputBegan:connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if not gpe then
			if input.KeyCode == Enum.KeyCode.Slash then
				wait()
				chatmodule.chatbar()
			end
		else
			if input.KeyCode == Enum.KeyCode.Return then
				if chatmodule.searching then
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
			elseif input.KeyCode == Enum.KeyCode.Tab then
				chatmodule.search()
			elseif input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down then
				if chatmodule.searching then
					local res = chatbar:FindFirstChild("results")
					if res then
						-- we love ternaries
						local direction = input.KeyCode == Enum.KeyCode.Up and -1 or 1
						local selected, results = chatmodule.searching.selected, chatmodule.searching.results

						-- the first time lua tables starting at 1 has bothered me
						local position = 0

						print(direction, selected, results, position)

						if selected - direction == 0 then
							chatmodule.searching.selected = #results
							position = #results - 1
						elseif selected + direction > #results then
							chatmodule.searching.selected = 1
							position = 0
						else
							chatmodule.searching.selected = chatmodule.searching.selected + direction
							position = chatmodule.searching.selected - 1
						end

						res:WaitForChild("highlight"):TweenPosition(u2(0, 0, 0, 26*position), "Out", "Quart", 0.25, true)
					end
				end
			end
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		if gpe then
			if chatmodule.chatbarToggle then
				chatmodule.chatbar()
			end
		end
	end
end)