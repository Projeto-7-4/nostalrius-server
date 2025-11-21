-- Sistema de Training Dummies para Nostalrius 7.72 (API antiga)
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
		[5901] = {skill = SKILL_SWORD, effect = CONST_ME_HITAREA},
		[5902] = {skill = SKILL_AXE, effect = CONST_ME_HITAREA},
		[5903] = {skill = SKILL_CLUB, effect = CONST_ME_HITAREA},
		[5904] = {skill = SKILL_DISTANCE, effect = CONST_ME_HITBYPOISON},
		[5905] = {skill = SKILL_SHIELD, effect = CONST_ME_BLOCKHIT}
	},
	
	-- Configurações de treino
	gainPerHit = 100,         -- Skill tries por hit (ajuste conforme necessário)
	hitDelay = 2000,          -- Delay entre hits (ms)
	animationEffect = true    -- Mostrar efeitos visuais
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

local function getSkillName(skillId)
	local names = {
		[SKILL_SWORD] = "sword fighting",
		[SKILL_AXE] = "axe fighting",
		[SKILL_CLUB] = "club fighting",
		[SKILL_DISTANCE] = "distance fighting",
		[SKILL_SHIELD] = "shielding"
	}
	return names[skillId] or "unknown"
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	if not player then
		return false
	end
	
	local target = Creature(itemEx.uid)
	if not target then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can only use this on creatures.")
		return false
	end
	
	-- Verifica se é um dummy
	if not isDummy(target) then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can only train on training dummies.")
		return false
	end
	
	-- Configuração da arma
	local weaponConfig = config.weapons[item.itemid]
	if not weaponConfig then
		return false
	end
	
	-- Verifica delay entre hits
	local playerId = player:getId()
	local now = os.time()
	if lastHit[playerId] and (now - lastHit[playerId]) < (config.hitDelay / 1000) then
		return false
	end
	lastHit[playerId] = now
	
	-- Verifica charges
	local charges = item:getCharges()
	if charges <= 0 then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "Your exercise weapon has broken.")
		item:remove(1)
		return true
	end
	
	-- Treina skill
	local skill = weaponConfig.skill
	local currentSkill = player:getSkillLevel(skill)
	
	-- Adiciona skill tries
	player:addSkillTries(skill, config.gainPerHit)
	
	-- Remove charge
	item:setAttribute(ITEM_ATTRIBUTE_CHARGES, charges - 1)
	
	-- Efeito visual
	if config.animationEffect then
		toPosition:sendMagicEffect(weaponConfig.effect)
		fromPosition:sendMagicEffect(CONST_ME_HITAREA)
	end
	
	-- Verifica se upou skill
	local newSkill = player:getSkillLevel(skill)
	if newSkill > currentSkill then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 
			"You advanced to " .. newSkill .. " in " .. getSkillName(skill) .. "!")
	end
	
	-- Mostra charges restantes
	local remainingCharges = charges - 1
	if remainingCharges > 0 then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, 
			"Training... [" .. remainingCharges .. " charges left]")
	else
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "Your exercise weapon has broken.")
		item:remove(1)
	end
	
	return true
end

print(">> Training weapons system loaded!")
