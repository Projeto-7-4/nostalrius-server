-- Check Buffs Command
-- Usage: /checkbuffs
-- Mostra seus Special Skills atuais

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "=== SEUS BUFFS DE COMBATE ===")
	
	-- Pega os special skills do player diretamente
	local critChance = player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE)
	local critAmount = player:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT)
	local lifeChance = player:getSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE)
	local lifeAmount = player:getSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT)
	local manaChance = player:getSpecialSkill(SPECIALSKILL_MANALEECHCHANCE)
	local manaAmount = player:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT)
	
	-- Debug: mostra valores brutos
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Valores brutos:")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "  critChance=" .. tostring(critChance) .. " (type: " .. type(critChance) .. ")")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "  critAmount=" .. tostring(critAmount) .. " (type: " .. type(critAmount) .. ")")
	
	-- Garantir que os valores não sejam nil (convertendo para número)
	critChance = critChance and tonumber(critChance) or 0
	critAmount = critAmount and tonumber(critAmount) or 0
	lifeChance = lifeChance and tonumber(lifeChance) or 0
	lifeAmount = lifeAmount and tonumber(lifeAmount) or 0
	manaChance = manaChance and tonumber(manaChance) or 0
	manaAmount = manaAmount and tonumber(manaAmount) or 0
	
	-- Verifica se os valores estão em centésimos (0-10000) ou porcentagem (0-100)
	-- Se estiver em centésimos, divide por 100
	if critChance > 100 then
		critChance = critChance / 100
		critAmount = critAmount / 100
		lifeChance = lifeChance / 100
		lifeAmount = lifeAmount / 100
		manaChance = manaChance / 100
		manaAmount = manaAmount / 100
	end
	
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

