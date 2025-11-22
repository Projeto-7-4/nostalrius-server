-- Set Attack Command
-- Usage: /setattack <attack value>
-- Example: /setattack 100

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você não tem permissão!")
		return true
	end

	if param == "" then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Uso: /setattack <valor>")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Exemplo: /setattack 100")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Segure a arma na mão primeiro!")
		return false
	end

	local attackValue = tonumber(param)
	if not attackValue then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Valor inválido! Use apenas números.")
		return false
	end

	local item = nil
	
	-- Primeiro tenta pegar item na frente do player
	local playerPos = player:getPosition()
	local direction = player:getDirection()
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
	
	local tile = Tile(targetPos)
	if tile then
		local topItem = tile:getTopDownItem()
		if topItem and topItem:isItem() then
			item = topItem
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "📦 Item encontrado na sua frente: " .. item:getName())
		end
	end
	
	-- Se não encontrou na frente, tenta pegar item da mão esquerda
	if not item then
		item = player:getSlotItem(CONST_SLOT_LEFT)
		if item then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "📦 Item encontrado na mão esquerda: " .. item:getName())
		end
	end
	
	-- Se não encontrou na esquerda, tenta direita
	if not item then
		item = player:getSlotItem(CONST_SLOT_RIGHT)
		if item then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "📦 Item encontrado na mão direita: " .. item:getName())
		end
	end

	if not item then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "❌ Nenhum item encontrado!")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "💡 Coloque um item na sua frente ou segure na mão.")
		return false
	end
	
	-- Verifica se o item tem atributo de attack (pode ser arma ou item com attack customizado)
	local currentAttack = item:getAttack()
	if currentAttack == nil then
		-- Tenta verificar se é uma arma
		if not item:isWeapon() then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "⚠️ Este item não possui atributo de attack!")
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "💡 Use uma arma ou item que tenha attack.")
			return false
		end
	end

	-- Debug: mostra info do item
	local currentAttack = item:getAttack() or 0
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Item encontrado: " .. item:getName() .. " (ID: " .. item:getId() .. ")")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Ataque atual: " .. currentAttack)

	-- Tenta setar o atributo
	item:setAttribute(ITEM_ATTRIBUTE_ATTACK, attackValue)
	
	-- Verifica se foi setado corretamente
	local newAttack = item:getAttack()
	
	if newAttack == attackValue then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "✓ Ataque de " .. item:getName() .. " alterado de " .. currentAttack .. " para " .. attackValue .. "!")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		if item:getPosition() then
			item:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		end
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "⚠️ Ataque setado, mas valor verificado: " .. (newAttack or "nil"))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "💡 Tente pegar o item e usar novamente, ou use /superattack para forçar.")
	end

	return false
end
