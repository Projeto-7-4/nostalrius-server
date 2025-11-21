-- Sistema de Training Dummies para Nostalrius 7.72
-- Exercise weapons que gastam charges ao treinar skills

local config = {
	-- Dummies (NPCs que podem ser atacados)
	dummyIds = {
		"training monk",
		"training dummy"
	},
	
	-- Exercise weapons e seus skills
	weapons = {
		-- Melee weapons
		[5901] = {skill = SKILL_SWORD, effect = CONST_ME_HITAREA},  -- Exercise Sword
		[5902] = {skill = SKILL_AXE, effect = CONST_ME_HITAREA},    -- Exercise Axe
		[5903] = {skill = SKILL_CLUB, effect = CONST_ME_HITAREA},   -- Exercise Club
		[5904] = {skill = SKILL_DISTANCE, effect = CONST_ME_HITBYPOISON}, -- Exercise Bow
		[5905] = {skill = SKILL_SHIELD, effect = CONST_ME_BLOCKHIT} -- Exercise Shield
	},
	
	-- Configurações de treino
	gainPerHit = 1,          -- Skill gain por hit
	hitDelay = 2000,         -- Delay entre hits (ms)
	chargesPerHit = 1,       -- Charges gastos por hit
	animationEffect = true   -- Mostrar efeitos visuais
}

local lastHit = {}

local function isDummy(creature)
	if not creature then
		return false
	end
	
	local name = creature:getName():lower()
	for _, dummyName in ipairs(config.dummyIds) do
		if name == dummyName then
			return true
		end
	end
	return false
end

local function trainSkill(player, item, target)
	local weaponConfig = config.weapons[item:getId()]
	if not weaponConfig then
		return false
	end
	
	-- Verifica se target é um dummy
	if not isDummy(target) then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can only train on training dummies.")
		return false
	end
	
	-- Verifica delay entre hits
	local playerId = player:getId()
	local now = os.time()
	if lastHit[playerId] and (now - lastHit[playerId]) < (config.hitDelay / 1000) then
		return false
	end
	lastHit[playerId] = now
	
	-- Gasta charge
	local charges = item:getAttribute(ITEM_ATTRIBUTE_CHARGES)
	if not charges or charges <= 0 then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "Your exercise weapon has broken.")
		item:remove(1)
		return false
	end
	
	-- Treina skill
	local skill = weaponConfig.skill
	local currentSkill = player:getSkillLevel(skill)
	local currentTries = player:getSkillTries(skill)
	
	-- Adiciona skill tries
	player:addSkillTries(skill, config.gainPerHit)
	
	-- Remove charge
	item:setAttribute(ITEM_ATTRIBUTE_CHARGES, charges - config.chargesPerHit)
	
	-- Efeito visual
	if config.animationEffect then
		target:getPosition():sendMagicEffect(weaponConfig.effect)
		player:getPosition():sendMagicEffect(CONST_ME_HITAREA)
	end
	
	-- Mensagem de progresso
	local newSkill = player:getSkillLevel(skill)
	if newSkill > currentSkill then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You advanced to " .. newSkill .. " in " .. 
			({[SKILL_SWORD]="sword fighting", [SKILL_AXE]="axe fighting", [SKILL_CLUB]="club fighting", 
			  [SKILL_DISTANCE]="distance fighting", [SKILL_SHIELD]="shielding"})[skill] .. "!")
	end
	
	-- Mostra charges restantes
	local remainingCharges = item:getAttribute(ITEM_ATTRIBUTE_CHARGES)
	if remainingCharges and remainingCharges > 0 then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "Training... [" .. remainingCharges .. " charges left]")
	end
	
	return true
end

-- Registra uso das exercise weapons
for itemId, _ in pairs(config.weapons) do
	local useWeapon = Action()
	
	function useWeapon.onUse(player, item, fromPosition, target, toPosition, isHotkey)
		return trainSkill(player, item, target)
	end
	
	useWeapon:id(itemId)
	useWeapon:register()
end

print(">> Training weapons system loaded!")

