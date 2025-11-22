-- Super Attack Command
-- Usage: /superattack
-- Modifica o item que está NA SUA FRENTE (no chão)

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	-- Pega a posição do player
	local playerPos = player:getPosition()
	
	-- Pega a direção que o player está olhando
	local direction = player:getDirection()
	
	-- Calcula a posição na frente do player
	local targetPos = Position(playerPos.x, playerPos.y, playerPos.z)
	if direction == DIRECTION_NORTH then
		targetPos.y = targetPos.y - 1
	elseif direction == DIRECTION_SOUTH then
		targetPos.y = targetPos.y + 1
	elseif direction == DIRECTION_WEST then
		targetPos.x = targetPos.x - 1
	elseif direction == DIRECTION_EAST then
		targetPos.x = targetPos.x + 1
	end
	
	-- Pega o tile na posição
	local tile = Tile(targetPos)
	if not tile then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Não há nada na sua frente!")
		return false
	end
	
	-- Procura por um item no tile
	local item = nil
	local topItem = tile:getTopDownItem()
	if topItem and topItem:isItem() then
		item = topItem
	end
	
	if not item then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Não há nenhum item na sua frente!")
		return false
	end
	
	-- Seta ataque para 999
	item:setAttribute(ITEM_ATTRIBUTE_ATTACK, 999)
	item:setAttribute(ITEM_ATTRIBUTE_DEFENSE, 999)
	item:setAttribute(ITEM_ATTRIBUTE_ARMOR, 999)
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "✓ " .. item:getName() .. " agora é SUPER PODEROSO!")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "  Attack: 999 | Defense: 999 | Armor: 999")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	targetPos:sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return false
end
