-- Cast System Commands
-- /cast on [password] - Start casting
-- /cast off - Stop casting
-- /cast password <password> - Set or change password
-- /cast password off - Remove password
-- /cast ban <name> - Ban a viewer
-- /cast unban <name> - Unban a viewer
-- /cast viewers - Show viewer list
-- /cast info - Show cast information

function onSay(player, words, param)
    local args = param:split(" ")
    local command = args[1] and args[1]:lower() or ""
    
    if not command or command == "" then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Cast System Commands:")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/cast on [password] - Start casting")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/cast off - Stop casting")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/cast password <pass> - Set password")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/cast password off - Remove password")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/cast ban <name> - Ban viewer")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/cast unban <name> - Unban viewer")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/cast viewers - List viewers")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/cast info - Cast information")
        return false
    end
    
    if command == "on" then
        if player:isCasting() then
            player:sendCancelMessage("You are already casting!")
            return false
        end
        
        local password = args[2] and args[2]:trim() or ""
        if player:startCast(password) then
            if password ~= "" then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Cast started with password: " .. password)
            else
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Cast started! Your stream is public.")
            end
        else
            player:sendCancelMessage("Failed to start cast.")
        end
        return false
        
    elseif command == "off" then
        if not player:isCasting() then
            player:sendCancelMessage("You are not casting!")
            return false
        end
        
        player:stopCast()
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Cast stopped!")
        return false
        
    elseif command == "password" then
        if not player:isCasting() then
            player:sendCancelMessage("You need to start casting first!")
            return false
        end
        
        local password = args[2] and args[2]:trim()
        if not password or password == "" then
            player:sendCancelMessage("Usage: /cast password <password> or /cast password off")
            return false
        end
        
        if password:lower() == "off" then
            player:setCastPassword("")
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Cast password removed. Stream is now public.")
        else
            player:setCastPassword(password)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Cast password set to: " .. password)
        end
        return false
        
    elseif command == "ban" then
        if not player:isCasting() then
            player:sendCancelMessage("You need to start casting first!")
            return false
        end
        
        local viewerName = args[2] and args[2]:trim()
        if not viewerName or viewerName == "" then
            player:sendCancelMessage("Usage: /cast ban <viewer name>")
            return false
        end
        
        player:banCastViewer(viewerName)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Viewer '" .. viewerName .. "' has been banned.")
        return false
        
    elseif command == "unban" then
        if not player:isCasting() then
            player:sendCancelMessage("You need to start casting first!")
            return false
        end
        
        local viewerName = args[2] and args[2]:trim()
        if not viewerName or viewerName == "" then
            player:sendCancelMessage("Usage: /cast unban <viewer name>")
            return false
        end
        
        player:unbanCastViewer(viewerName)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Viewer '" .. viewerName .. "' has been unbanned.")
        return false
        
    elseif command == "viewers" then
        if not player:isCasting() then
            player:sendCancelMessage("You are not casting!")
            return false
        end
        
        local viewers = player:getCastViewers()
        if #viewers == 0 then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "No viewers watching.")
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Viewers (" .. #viewers .. "):")
            for i, viewer in ipairs(viewers) do
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, i .. ". " .. viewer.name .. " (" .. viewer.ip .. ")")
            end
        end
        return false
        
    elseif command == "info" then
        if not player:isCasting() then
            player:sendCancelMessage("You are not casting!")
            return false
        end
        
        local viewers = player:getCastViewers()
        local hasPassword = player:castHasPassword()
        
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "=== Cast Information ===")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Status: Broadcasting")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Viewers: " .. #viewers)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Type: " .. (hasPassword and "Private (password protected)" or "Public"))
        return false
    else
        player:sendCancelMessage("Unknown command. Use /cast for help.")
        return false
    end
    
    return false
end

