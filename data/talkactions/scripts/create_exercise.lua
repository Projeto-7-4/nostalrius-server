-- Comando /exercise para criar exercise weapons
-- Uso: /exercise [tipo] [charges]
-- Tipos: sword, axe, club, bow, shield
-- Charges: quantidade de charges (padrão: 500)

function onSay(cid, words, param)
	local player = Player(cid)
	if not player then
		return false
	end
	
	if not player:getGroup():getAccess() then
		return false
	end
	
	local split = param:split(",")
	local weaponType = split[1] and split[1]:trim():lower() or ""
	local charges = tonumber(split[2]) or 500
	
	-- Mapeamento de tipos para IDs de items base (espadas, machados, etc)
	local weaponItems = {
		sword = 2376,  -- Sword
		axe = 2386,    -- Axe  
		club = 2398,   -- Mace
		bow = 2456,    -- Bow
		shield = 2513  -- Wooden Shield
	}
	
	if weaponType == "" then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			"Usage: /exercise [type],[charges]")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			"Types: sword, axe, club, bow, shield")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			"Example: /exercise sword,500")
		return false
	end
	
	local itemId = weaponItems[weaponType]
	if not itemId then
		player:sendCancelMessage("Invalid weapon type. Use: sword, axe, club, bow, or shield")
		return false
	end
	
	-- Cria o item
	local item = player:addItem(itemId, 1)
	if not item then
		player:sendCancelMessage("Could not create exercise weapon.")
		return false
	end
	
	-- Define charges
	item:setAttribute(ITEM_ATTRIBUTE_CHARGES, charges)
	
	-- Define descrição customizada
	item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, 
		"An exercise " .. weaponType .. " with " .. charges .. " charges. Use on training dummies to improve your skills.")
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
		"Exercise " .. weaponType .. " created with " .. charges .. " charges!")
	
	return false
end

