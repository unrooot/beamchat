local config = {
	-- Send a message in the chat when a player joins/leaves the game.
	playerEvents = true;

	-- Enable/disable bubble chat.
	bubbleChat = true;

	-- The amount of messages a player can send in rapid succession before
	-- being flagged by the anti-spam filter.
	maxSpam = 5;

	-- The lifespan of each message that is stored in the anti-spam table.
	spamLife = 5;
}

return config