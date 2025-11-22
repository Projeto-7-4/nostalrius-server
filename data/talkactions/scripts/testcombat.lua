-- Combat System Test Script
-- Usage: /testcombat
-- Adiciona special skills DIRETO no player para teste

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	-- Método 1: Tentar com condition (como antes)
	local condition = Condition(CONDITION_ATTRIBUTES)
	condition:setParameter(CONDITION_PARAM_TICKS, 60000) -- 60 seconds
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 20)
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 50)
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE, 100)
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT, 1000)
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE, 100)
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT, 500)
	
	local conditionAdded = player:addCondition(condition)

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Combat System Test Activated!")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Condition added: " .. tostring(conditionAdded))
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Buffs for 60 seconds:")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "- Critical Hit: 20% chance, +50% damage")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "- Life Leech: 100% chance, 10% of damage")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "- Mana Leech: 100% chance, 5% of damage")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "DEBUG: Verifique com /checkbuffs")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Se ainda estiver 0%, o problema é com ConditionAttributes!")
	
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return false
end
