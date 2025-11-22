-- Comando /dummy para spawnar training dummies (API antiga)
-- Uso: /dummy [tipo]
-- Tipos: monk (padrão), dummy

function onSay(cid, words, param)
	local player = Player(cid)
	if not player then
		return false
	end
	
	if not player:getGroup():getAccess() then
		return false
	end
	
	local dummyType = param:trim():lower()
	if dummyType == "" then
		dummyType = "monk"
	end
	
	local dummyName = "training " .. dummyType
	local position = player:getPosition()
	local direction = player:getDirection()
	
	-- Calcula posição frontal
	local frontPosition = Position(position.x, position.y, position.z)
	if direction == DIRECTION_NORTH then
		frontPosition.y = frontPosition.y - 1
	elseif direction == DIRECTION_SOUTH then
		frontPosition.y = frontPosition.y + 1
	elseif direction == DIRECTION_WEST then
		frontPosition.x = frontPosition.x - 1
	elseif direction == DIRECTION_EAST then
		frontPosition.x = frontPosition.x + 1
	end
	
	-- Verifica se posição está livre
	local tile = Tile(frontPosition)
	if not tile or not tile:getGround() then
		player:sendCancelMessage("You cannot spawn a dummy here.")
		return false
	end
	
	-- Spawna o dummy
	local dummy = Game.createMonster(dummyName, frontPosition, false, true)
	if dummy then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			"Training dummy spawned at " .. frontPosition.x .. "," .. frontPosition.y .. "," .. frontPosition.z)
		frontPosition:sendMagicEffect(CONST_ME_TELEPORT)
	else
		player:sendCancelMessage("Could not spawn dummy. Make sure '" .. dummyName .. "' exists in monsters.xml")
	end
	
	return false
end
