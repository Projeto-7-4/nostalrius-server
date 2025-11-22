-- Set Armor Command
-- Usage: /setarmor <armor value>
-- Example: /setarmor 20

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if param == "" then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /setarmor <armor value>")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Example: /setarmor 20")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Hold the armor/item in your hand first!")
		return false
	end

	local armorValue = tonumber(param)
	if not armorValue then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid armor value!")
		return false
	end

	local item = player:getSlotItem(CONST_SLOT_LEFT) or player:getSlotItem(CONST_SLOT_RIGHT)
	if not item then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You need to hold an item in your hand!")
		return false
	end

	item:setAttribute(ITEM_ATTRIBUTE_ARMOR, armorValue)
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Armor of %s set to %d!", item:getName(), armorValue))
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return false
end

