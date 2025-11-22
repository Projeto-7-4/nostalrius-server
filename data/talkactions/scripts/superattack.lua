-- Super Attack Command (sem parâmetros)
-- Usage: /superattack

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	-- Pega item da mão
	local item = player:getSlotItem(CONST_SLOT_LEFT) or player:getSlotItem(CONST_SLOT_RIGHT)
	
	if not item then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Segure uma arma na mão!")
		return false
	end

	-- Seta ataque para 999 direto
	item:setAttribute(ITEM_ATTRIBUTE_ATTACK, 999)
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "✓ " .. item:getName() .. " agora tem 999 de ataque!")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return false
end

