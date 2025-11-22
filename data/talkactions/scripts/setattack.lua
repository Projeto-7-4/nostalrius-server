-- Set Attack Command
-- Usage: /setattack <attack value>
-- Example: /setattack 100

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if param == "" then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /setattack <attack value>")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Example: /setattack 100")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Hold the weapon/item in your hand first!")
		return false
	end

	local attackValue = tonumber(param)
	if not attackValue then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid attack value!")
		return false
	end

	local item = player:getSlotItem(CONST_SLOT_LEFT) or player:getSlotItem(CONST_SLOT_RIGHT)
	if not item then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You need to hold an item in your hand!")
		return false
	end

	item:setAttribute(ITEM_ATTRIBUTE_ATTACK, attackValue)
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Attack of %s set to %d!", item:getName(), attackValue))
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return false
end

