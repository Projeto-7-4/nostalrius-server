-- Check Buffs Command
-- Usage: /checkbuffs
-- Mostra seus Special Skills atuais (somados dos itens equipados)

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "=== SEUS BUFFS DE COMBATE ===")
	
	-- Pega os special skills diretamente dos itens equipados (via função C++)
	local critChance = player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE)
	local critAmount = player:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT)
	local lifeChance = player:getSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE)
	local lifeAmount = player:getSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT)
	local manaChance = player:getSpecialSkill(SPECIALSKILL_MANALEECHCHANCE)
	local manaAmount = player:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT)
	
	-- Garantir que os valores não sejam nil (convertendo para número)
	critChance = tonumber(critChance) or 0
	critAmount = tonumber(critAmount) or 0
	lifeChance = tonumber(lifeChance) or 0
	lifeAmount = tonumber(lifeAmount) or 0
	manaChance = tonumber(manaChance) or 0
	manaAmount = tonumber(manaAmount) or 0
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Critical Hit Chance: " .. critChance .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Critical Hit Amount: " .. critAmount .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Life Leech Chance: " .. lifeChance .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Life Leech Amount: " .. lifeAmount .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Mana Leech Chance: " .. manaChance .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Mana Leech Amount: " .. manaAmount .. "%")
	
	-- Mostra conditions ativas (removido temporariamente para evitar erro)
	-- player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "")
	-- player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Conditions ativas:")

	return false
end

