local BeamchatSettings = {}

BeamchatSettings._settings = {
	CHATBAR_LABEL_TEXT = "press / or click here to start typing";
	CHATBAR_LABEL_TEXT_MOBILE = "tap here to start typing";
	HIDE_AFTER_SECONDS = 3;

	-- CHAT_FONT = Enum.Font.GothamBold; -- Changes the default font of the chat.
	-- CHAT_LABEL_OFFSET = UDim2.new(0, 0, 0, 2); -- Optional offset for message labels. Useful for fonts that aren't centered. Set to UDim2.new() if not using.
	-- CHAT_COLOR_THEME = "Default"; -- Changes the color pallete for usernames. Refer to chatColors.lua for options.

	-- -- Message Mentions
	-- GRADIENT_TRANSPARENCY = 0.8; -- The gradient's transparency
	-- OUTLINE_TRANSPARENCY = 0.5; -- The outline's transparency
	-- MENTION_MATCHES_USERCOLOR = true; -- Set to true to make the mention color the user's color
	-- MENTION_COLOR = Color3.fromRGB(255, 208, 112); -- Defaults to this value if MENTION_MATCHES_USERCOLOR is false
}

function BeamchatSettings:Get(settingName)
	return self._settings[settingName]
end

return BeamchatSettings