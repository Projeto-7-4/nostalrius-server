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

	-- Tenta pegar item da mão esquerda primeiro
	local item = player:getSlotItem(CONST_SLOT_LEFT)
	if not item then
		-- Se não tem na esquerda, tenta direita
		item = player:getSlotItem(CONST_SLOT_RIGHT)
	end

	if not item then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "❌ Você precisa segurar um item na mão!")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "💡 Coloque a Magic Sword (ou outra arma) na mão esquerda ou direita.")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "💡 Magic Sword ID: 3288 - Use /i 3288 para criar uma.")
		return false
	end
	
	-- Verifica se é uma arma (tem attack)
	if not item:isWeapon() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "⚠️ Este item não é uma arma!")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "💡 Use uma arma (sword, axe, club, etc.)")
		return false
	end

	-- Debug: mostra info do item
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Item encontrado: " .. item:getName())
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Ataque atual: " .. item:getAttack())

	-- Tenta setar o atributo
	local success = item:setAttribute(ITEM_ATTRIBUTE_ATTACK, attackValue)
	
	if success then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "✓ Ataque de " .. item:getName() .. " alterado para " .. attackValue .. "!")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "✗ Erro ao alterar ataque!")
	end

	return false
end
