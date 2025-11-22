-- Combat System Test Script
-- Usage: /testcombat

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	-- Create a condition with critical hit and leech bonuses
	local condition = Condition(CONDITION_ATTRIBUTES)
	condition:setParameter(CONDITION_PARAM_TICKS, 60000) -- 60 seconds

	-- Critical Hit: 20% chance, 50% extra damage
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 20)
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 50)

	-- Life Leech: 100% chance, 10% of damage as life
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE, 100)
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT, 1000) -- 10% = 1000/10000

	-- Mana Leech: 100% chance, 5% of damage as mana
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE, 100)
	condition:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT, 500) -- 5% = 500/10000

	player:addCondition(condition)

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Combat System Test Activated!")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Buffs for 60 seconds:")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "- Critical Hit: 20% chance, +50% damage")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "- Life Leech: 100% chance, 10% of damage")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "- Mana Leech: 100% chance, 5% of damage")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Attack monsters to see the effects!")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return false
end

