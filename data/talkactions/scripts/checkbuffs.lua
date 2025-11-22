-- Check Buffs Command
-- Usage: /checkbuffs
-- Mostra seus Special Skills atuais

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "=== SEUS BUFFS DE COMBATE ===")
	
	-- Tenta pegar os special skills (se o método existir)
	local critChance = 0
	local critAmount = 0
	local lifeChance = 0
	local lifeAmount = 0
	local manaChance = 0
	local manaAmount = 0
	
	-- Como getSpecialSkill pode não estar disponível no Lua, vamos testar
	if player.getSpecialSkill then
		critChance = player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE) or 0
		critAmount = player:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT) or 0
		lifeChance = player:getSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE) or 0
		lifeAmount = player:getSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT) or 0
		manaChance = player:getSpecialSkill(SPECIALSKILL_MANALEECHCHANCE) or 0
		manaAmount = player:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT) or 0
	end
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Critical Hit Chance: " .. critChance .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Critical Hit Amount: " .. critAmount .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Life Leech Chance: " .. lifeChance .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Life Leech Amount: " .. lifeAmount)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Mana Leech Chance: " .. manaChance .. "%")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Mana Leech Amount: " .. manaAmount)
	
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

