local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local PlatformUtils = {}

function PlatformUtils:ClientIsMobile()
	return UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled
		and not UserInputService.MouseEnabled
		and not GuiService:IsTenFootInterface()
end

return PlatformUtils