-- Sistema de Training Dummies SIMPLIFICADO para Nostalrius 7.72
-- Funciona com QUALQUER item que tenha charges

local config = {
	dummyNames = {"training monk", "training dummy"},
	gainPerHit = 100,
	hitDelay = 2000,
	effect = CONST_ME_HITAREA
}

local lastHit = {}

local function isDummy(creature)
	if not creature then return false end
	local name = creature:getName():lower()
	for _, dummyName in ipairs(config.dummyNames) do
		if name == dummyName then return true end
	end
	return false
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	if not player then return false end
	
	local target = Creature(itemEx.uid)
	if not target or not isDummy(target) then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can only train on training dummies.")
		return false
	end
	
	-- Verifica charges
	local charges = item:getAttribute(ITEM_ATTRIBUTE_CHARGES) or 0
	if charges <= 0 then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "This item has no charges.")
		return false
	end
	
	-- Verifica delay
	local pid = player:getId()
	local now = os.time()
	if lastHit[pid] and (now - lastHit[pid]) < 2 then
		return false
	end
	lastHit[pid] = now
	
	-- Treina skill baseado no item
	local skill = SKILL_SWORD -- padrão
	local itemType = item:getType()
	if itemType then
		local itemName = itemType:getName():lower()
		if itemName:find("sword") then skill = SKILL_SWORD
		elseif itemName:find("axe") then skill = SKILL_AXE
		elseif itemName:find("club") or itemName:find("mace") then skill = SKILL_CLUB
		elseif itemName:find("bow") or itemName:find("arrow") then skill = SKILL_DISTANCE
		elseif itemName:find("shield") then skill = SKILL_SHIELD
		end
	end
	
	local currentSkill = player:getSkillLevel(skill)
	player:addSkillTries(skill, config.gainPerHit)
	
	-- Remove charge
	item:setAttribute(ITEM_ATTRIBUTE_CHARGES, charges - 1)
	
	-- Efeito
	toPosition:sendMagicEffect(config.effect)
	
	-- Mensagem
	local newSkill = player:getSkillLevel(skill)
	if newSkill > currentSkill then
		local skillNames = {[SKILL_SWORD]="sword", [SKILL_AXE]="axe", [SKILL_CLUB]="club", [SKILL_DISTANCE]="distance", [SKILL_SHIELD]="shielding"}
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You advanced to " .. newSkill .. " in " .. skillNames[skill] .. " fighting!")
	else
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "Training... [" .. (charges-1) .. " charges left]")
	end
	
	return true
end

print(">> Training weapons system loaded!")
