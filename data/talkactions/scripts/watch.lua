function onSay(player, words, param)
    if not param or param == "" then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /watch PlayerName [password]")
        return false
    end
    
    local args = param:split(" ")
    local targetName = args[1]:trim()
    local password = args[2] and args[2]:trim() or ""
    
    -- Buscar o player que está castando
    local targetPlayer = Player(targetName)
    if not targetPlayer then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Player '" .. targetName .. "' is not online.")
        return false
    end
    
    -- Verificar se o player está castando
    local cast = targetPlayer:getCast()
    if not cast then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, targetName .. " is not casting. They need to use /cast on first.")
        return false
    end
    
    -- Verificar senha se necessário
    if cast:castHasPassword() then
        if password == "" then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "This cast is password protected. Usage: /watch " .. targetName .. " password")
            return false
        end
        
        if not cast:checkPassword(password) then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Incorrect password.")
            return false
        end
    end
    
    -- Verificar se já está assistindo
    if player:isWatchingCast() then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You are already watching a cast. Use /stopwatch first.")
        return false
    end
    
    -- Conectar como viewer
    if player:watchCast(targetPlayer, password) then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Successfully connected to " .. targetName .. "'s cast!")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Use /stopwatch to stop watching.")
    else
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Failed to connect to the cast. Please try again.")
    end
    
    return false
end

