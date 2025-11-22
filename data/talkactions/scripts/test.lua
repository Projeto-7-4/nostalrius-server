function onSay(player, words, param)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Comando funcionando! Você é GM.")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	return false
end

