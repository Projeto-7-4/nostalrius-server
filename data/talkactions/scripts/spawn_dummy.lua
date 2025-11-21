-- Comando /dummy para spawnar training dummies
-- Uso: /dummy [tipo]
-- Tipos: monk (padrão), dummy

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	local dummyType = param:trim():lower()
	if dummyType == "" then
		dummyType = "monk"
	end
	
	local dummyName = "training " .. dummyType
	local position = player:getPosition()
	local frontPosition = position:getFrontPosition(player:getDirection())
	
	-- Verifica se posição está livre
	local tile = Tile(frontPosition)
	if not tile or not tile:getGround() then
		player:sendCancelMessage("You cannot spawn a dummy here.")
		return false
	end
	
	-- Spawna o dummy
	local dummy = Game.createMonster(dummyName, frontPosition, false, true)
	if dummy then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Training dummy spawned at " .. frontPosition:toString())
		frontPosition:sendMagicEffect(CONST_ME_TELEPORT)
	else
		player:sendCancelMessage("Could not spawn dummy. Make sure '" .. dummyName .. "' exists in monsters.xml")
	end
	
	return false
end

