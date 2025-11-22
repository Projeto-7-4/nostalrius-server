function onSay(player, words, param)
    if not player:isWatchingCast() then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You are not watching any cast.")
        return false
    end
    
    player:stopWatchingCast()
    
    return false
end


