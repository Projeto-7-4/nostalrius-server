-- Comando /train - Cria arma de treino com IDs corretos do Nostalrius
function onSay(cid, words, param)
	local player = Player(cid)
	if not player then return false end
	if not player:getGroup():getAccess() then return false end
	
	local types = {
		sword = 3264,
		club = 3270,
		axe = 3274,
		bow = 3350,
		shield = 3412
	}
	
	local weaponType = param:trim():lower()
	if weaponType == "" or weaponType == "sword" then
		weaponType = "sword" -- padrão
	end
	
	local itemId = types[weaponType]
	if not itemId then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Use: /train [type]")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Types: sword, club, axe, bow, shield")
		return false
	end
	
	-- Cria item com 500 charges
	local item = player:addItem(itemId, 1)
	if item then
		item:setAttribute(ITEM_ATTRIBUTE_CHARGES, 500)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			"Exercise " .. weaponType .. " created with 500 charges! Use on dummy.")
	else
		player:sendCancelMessage("Could not create item.")
	end
	
	return false
end
