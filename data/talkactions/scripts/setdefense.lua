-- Set Defense Command
-- Usage: /setdefense <defense value>
-- Example: /setdefense 50

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if param == "" then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /setdefense <defense value>")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Example: /setdefense 50")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Hold the weapon/item in your hand first!")
		return false
	end

	local defenseValue = tonumber(param)
	if not defenseValue then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid defense value!")
		return false
	end

	local item = player:getSlotItem(CONST_SLOT_LEFT) or player:getSlotItem(CONST_SLOT_RIGHT)
	if not item then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You need to hold an item in your hand!")
		return false
	end

	item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, defenseValue)
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Defense of %s set to %d!", item:getName(), defenseValue))
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return false
end

