-- Comando simplificado: /exercise
-- Cria exercise weapons com charges automaticamente

function onSay(cid, words, param)
	local player = Player(cid)
	if not player then return false end
	
	if not player:getGroup():getAccess() then return false end
	
	local types = {
		sword = 2376,
		axe = 2386,
		club = 2398,
		bow = 2456,
		shield = 2513
	}
	
	local weaponType = param:trim():lower()
	if weaponType == "" then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Use: /exercise [type]")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Types: sword, axe, club, bow, shield")
		return false
	end
	
	local itemId = types[weaponType]
	if not itemId then
		player:sendCancelMessage("Invalid type! Use: sword, axe, club, bow, or shield")
		return false
	end
	
	-- Cria item com charges
	local item = player:addItem(itemId, 1)
	if item then
		item:setAttribute(ITEM_ATTRIBUTE_CHARGES, 500)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			"Exercise " .. weaponType .. " created with 500 charges!")
	else
		player:sendCancelMessage("Could not create item.")
	end
	
	return false
end



