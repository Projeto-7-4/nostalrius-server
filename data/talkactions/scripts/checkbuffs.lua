-- Check Buffs Command
-- Usage: /checkbuffs
-- Mostra seus Special Skills atuais

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "=== SEUS BUFFS DE COMBATE ===")
	
	-- Pega os special skills do player
	local critChance = player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE)
	local critAmount = player:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT)
	local lifeChance = player:getSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE)
	local lifeAmount = player:getSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT)
	local manaChance = player:getSpecialSkill(SPECIALSKILL_MANALEECHCHANCE)
	local manaAmount = player:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT)
	
	-- Garantir que os valores não sejam nil
	if critChance == nil then critChance = 0 end
	if critAmount == nil then critAmount = 0 end
	if lifeChance == nil then lifeChance = 0 end
	if lifeAmount == nil then lifeAmount = 0 end
	if manaChance == nil then manaChance = 0 end
	if manaAmount == nil then manaAmount = 0 end
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Critical Hit Chance: " .. critChance .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Critical Hit Amount: " .. critAmount .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Life Leech Chance: " .. lifeChance .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Life Leech Amount: " .. lifeAmount .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Mana Leech Chance: " .. manaChance .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Mana Leech Amount: " .. manaAmount .. "%")
	
	-- Mostra conditions ativas
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Conditions ativas:")
	
	-- Lista conditions
	local hasConditions = false
	for i = CONDITION_FIRST, CONDITION_LAST do
		local condition = player:getCondition(i)
		if condition then
			hasConditions = true
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "  - Type: " .. i .. " | Ticks: " .. condition:getTicks())
		end
	end
	
	if not hasConditions then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "  Nenhuma condition ativa")
	end

	return false
end

