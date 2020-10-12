local bubbleChat = {}

local Thread = require(script.Parent.Thread)
local textRenderer = require(script.Parent.textRenderer)
local effects = require(script.Parent.effects)

local template = script.Parent.Parent.resources.BubbleGui:Clone()
local bubble = template.Bubble
local textService = game:GetService("TextService")
bubble.Parent = nil

local maxHeight = 250
local padding = 8
local collapseDistance = 50

bubble.UIPadding.PaddingBottom = UDim.new(0,padding)
bubble.UIPadding.PaddingLeft = UDim.new(0,padding)
bubble.UIPadding.PaddingRight = UDim.new(0,padding)
bubble.UIPadding.PaddingTop = UDim.new(0,padding)
bubble.TextContainer.Size = UDim2.new(1,0,1,padding)

function receiveChat(speaker, msg)
	local gui = getBubbleContainer(speaker)
	if not gui then return end
	
	local allBubbles = {}
	for _, b in pairs(gui:GetChildren()) do
		if b:IsA("Frame") and b.Name == "Bubble" then
			table.insert(allBubbles, b)
			b.Tail.Visible = false
		end
	end

	table.sort(allBubbles, function(a,b)
		return a.LayoutOrder > b.LayoutOrder
	end)

	if #allBubbles >= 3 then
		for _ = 1, #allBubbles-3 do
			local b = table.remove(allBubbles, 1)
			destroyBubble(b)
		end
	end
	
	local newBubble = bubble:Clone()
	local label = newBubble.TextContainer.TextLabel
	label.Text = msg
	label.TextTransparency = 1
	newBubble.Size = UDim2.new(0,padding,0,padding)
	newBubble.LayoutOrder = tick()*100
	newBubble.Parent = gui
	
	local p = workspace.CurrentCamera.CFrame:ToObjectSpace(gui.Parent.CFrame).p
	if p.Magnitude > collapseDistance then
		hideBubble(newBubble)
	else
		expandBubble(newBubble)
	end
		
	Thread.Delay(15, function()
		destroyBubble(newBubble)
	end)
end

function expandBubble(b)
	local label = b.TextContainer.TextLabel
	local size = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(224,800))
	local bigSize = UDim2.new(0,size.X+padding*2, 0, math.min(maxHeight, size.Y + padding*2))
	b.TextContainer.Gradient.Visible = size.Y > maxHeight - padding*2

	b:TweenSize(bigSize, "Out", "Quart", 0.25, true)

	
	effects.autoFade(label, 0.25, 0)
	
	-- saving this for a rainy day lol
	-- textRenderer.renderText(label)
	-- for _,child in pairs(label:GetDescendants()) do
	-- 	effects.autoFade(child, 0.25, 0)
	-- end
end

function hideBubble(b)
	local container = b:FindFirstChild("TextContainer")
	if container then
		b:TweenSize(UDim2.new(0, 30, 0, 20), "Out", "Quart", 0.25, true)
		-- effects.fadeAll(container.TextLabel, 0.15, 1)
		effects.autoFade(container.TextLabel, 0.15, 1)
	end
end

function getBubbleContainer(speaker)
	local plr = game.Players:GetPlayerByUserId(speaker)
	local char = plr.Character
	if char then
		local head = char:FindFirstChild("Head")
		if head then
			local gui = head:FindFirstChild("BubbleGui")
			if gui then
				return gui
			else
				gui = template:Clone()
				gui.Parent = head
				bindContainer(gui, head)
				return gui
			end
		end
	end
end

function bindContainer(container, adornee)
	Thread.Spawn(function()
		local near = false
		while wait(0) do
			if not adornee or not adornee.Parent then
				return
			end
			
			local p = workspace.CurrentCamera.CFrame:ToObjectSpace(adornee.CFrame).p
			if near and p.magnitude > collapseDistance then
				for _, b in pairs(container:GetChildren()) do
					if b.Name == "Bubble" then
						hideBubble(b)
					end
				end
				game:GetService("TweenService"):Create(container.UIPadding, TweenInfo.new(.15, Enum.EasingStyle.Sine), {
					PaddingBottom = UDim.new(0,padding)
				}):Play()
				near = false
			elseif not near and p.magnitude <= collapseDistance then
				for _, b in pairs(container:GetChildren()) do
					if b.Name == "Bubble" then
						expandBubble(b)
					end
				end
				game:GetService("TweenService"):Create(container.UIPadding, TweenInfo.new(.15, Enum.EasingStyle.Sine), {
					PaddingBottom = UDim.new(0,32)
				}):Play()
				near = true
			end
		end
	end)
end

function destroyBubble(b)
	if b then
		Thread.Delay(.15, function()
			b:Destroy()
		end)
		hideBubble(b)
	end
end

function bubbleChat.newBubble(user, message)
	receiveChat(user, message)
end

return bubbleChat