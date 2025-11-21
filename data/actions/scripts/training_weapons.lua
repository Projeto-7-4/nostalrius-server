-- Sistema de Training Dummies para Nostalrius 7.72
-- Funciona com QUALQUER arma que tenha charges!

local config = {
	-- Dummies (NPCs que podem ser atacados)
	dummyIds = {
		"training monk",
		"training dummy"
	},
	
	-- Mapeamento de weapon types para skills
	skillByWeaponType = {
		[WEAPON_SWORD] = SKILL_SWORD,
		[WEAPON_AXE] = SKILL_AXE,
		[WEAPON_CLUB] = SKILL_CLUB,
		[WEAPON_DIST] = SKILL_DISTANCE,
		[WEAPON_SHIELD] = SKILL_SHIELD
	},
	
	-- Configurações de treino
	gainPerHit = 100,         -- Skill tries por hit
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
	return names[skillId] or "skill"
end

local function getWeaponSkill(item)
	local weaponType = item:getType():getWeaponType()
	return config.skillByWeaponType[weaponType]
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
	
	-- Verifica se item tem charges
	local charges = item:getAttribute(ITEM_ATTRIBUTE_CHARGES)
	if not charges or charges <= 0 then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "This item has no charges left.")
		return false
	end
	
	-- Identifica skill baseado no tipo de arma
	local skill = getWeaponSkill(item)
	if not skill then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You cannot train with this item.")
		return false
	end
	
	-- Verifica delay entre hits
	local playerId = player:getId()
	local now = os.time()
	if lastHit[playerId] and (now - lastHit[playerId]) < (config.hitDelay / 1000) then
		return false
	end
	lastHit[playerId] = now
	
	-- Salva skill atual
	local currentSkill = player:getSkillLevel(skill)
	
	-- Adiciona skill tries
	player:addSkillTries(skill, config.gainPerHit)
	
	-- Remove charge
	item:setAttribute(ITEM_ATTRIBUTE_CHARGES, charges - 1)
	
	-- Efeito visual
	if config.animationEffect then
		toPosition:sendMagicEffect(CONST_ME_HITAREA)
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
			"Training " .. getSkillName(skill) .. "... [" .. remainingCharges .. " charges left]")
	else
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "Your training weapon has no more charges.")
		item:remove(1)
	end
	
	return true
end

print(">> Training weapons system loaded (universal)!")
