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

	-- The table of user ids that will have access to admin commands.
	admins = {4545223, 209771, 14292629, 59555685};

	-- The users who are banned from entering the server.
	banned = {};
}

return config