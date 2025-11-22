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
	local oldItem = nil
	local topItem = tile:getTopDownItem()
	if topItem and topItem:isItem() then
		oldItem = topItem
	end
	
	if not oldItem then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Não há nenhum item na sua frente!")
		return false
	end
	
	-- Pega informações do item original
	local itemId = oldItem:getId()
	local itemCount = oldItem:getCount()
	local itemName = oldItem:getName()
	
	-- Remove o item antigo
	oldItem:remove()
	
	-- Cria novo item no mesmo lugar
	local newItem = Game.createItem(itemId, itemCount, targetPos)
	if not newItem then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Erro ao criar novo item!")
		return false
	end
	
	-- Seta os novos atributos
	newItem:setAttribute(ITEM_ATTRIBUTE_ATTACK, 999)
	newItem:setAttribute(ITEM_ATTRIBUTE_DEFENSE, 999)
	newItem:setAttribute(ITEM_ATTRIBUTE_ARMOR, 999)
	
	-- Adiciona descrição customizada
	newItem:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, 
		"Um item modificado por GM.\nAttack: 999 | Defense: 999 | Armor: 999")
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "✓ " .. itemName .. " agora é SUPER PODEROSO!")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "  Attack: 999 | Defense: 999 | Armor: 999")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	targetPos:sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return false
end
