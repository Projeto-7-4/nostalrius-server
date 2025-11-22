/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2024  Mark Samman <mark.samman@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "otpch.h"
#include "cast.h"
#include "game.h"
#include "outputmessage.h"
#include "chat.h"
#include "iologindata.h"

extern Game g_game;
extern Chat* g_chat;

Cast::Cast(Player* player) :
    owner(player),
    casting(false),
    startTime(0),
    viewerCounter(0)
{
}

Cast::~Cast()
{
    stopCast();
}

bool Cast::startCast(const std::string& pwd)
{
    if (casting) {
        return false;
    }
    
    password = pwd;
    casting = true;
    startTime = time(nullptr);
    
    CastManager::getInstance().addCast(this);
    
    // Cast System - update database
    if (owner) {
        IOLoginData::updateCastStatus(owner->getGUID(), true, 0);
    }
    
    // Cast System - create Cast Channel and add broadcaster
    if (owner && g_chat) {
        ChatChannel* channel = g_chat->createChannel(*owner, CHANNEL_CAST);
        if (channel) {
            channel->addUser(*owner);
            // Send channel to broadcaster's client
            owner->sendChannel(CHANNEL_CAST, "Cast Channel");
            
            // Send welcome message in Cast Channel (in orange)
            std::ostringstream welcomeMsg;
            welcomeMsg << "Cast started! " << (password.empty() ? "Public stream" : "Private stream (password protected)");
            owner->sendToChannel(owner, TALKTYPE_CHANNEL_O, welcomeMsg.str(), CHANNEL_CAST);
        }
    }
    
    return true;
}

void Cast::stopCast()
{
    if (!casting) {
        return;
    }
    
    casting = false;
    
    // Cast System - update database
    if (owner) {
        std::cout << "[Cast] stopCast() - Removing cast from database for player: " << owner->getName() << " (GUID: " << owner->getGUID() << ")" << std::endl;
        IOLoginData::updateCastStatus(owner->getGUID(), false, 0);
        std::cout << "[Cast] stopCast() - Database updated (cast removed)" << std::endl;
    }
    
    // Kick all viewers (they will be removed from Cast Channel automatically in their logout())
    for (auto it = viewers.begin(); it != viewers.end(); ) {
        if (it->protocol) {
            it->protocol->disconnect();
        }
        it = viewers.erase(it);
    }
    
    // Cast System - send stop message and remove broadcaster from Cast Channel
    if (owner && g_chat) {
        ChatChannel* channel = g_chat->getChannel(*owner, CHANNEL_CAST);
        if (channel) {
            // Send stop message to Cast Channel before closing
            owner->sendToChannel(owner, TALKTYPE_CHANNEL_O, "Cast stopped!", CHANNEL_CAST);
            
            // Remove broadcaster from channel
            g_chat->removeUserFromChannel(*owner, CHANNEL_CAST);
            // Delete the channel
            g_chat->deleteChannel(*owner, CHANNEL_CAST);
        }
    }
    
    CastManager::getInstance().removeCast(this);
}

bool Cast::addViewer(ProtocolGame* protocol, const std::string& viewerName, const std::string& viewerIp, const std::string& pwd, Player* viewerPlayer)
{
    if (!casting || !protocol) {
        std::cout << "[Cast] addViewer failed: casting=" << casting << " protocol=" << (protocol != nullptr) << std::endl;
        return false;
    }
    
    // Check if viewer is banned
    if (isViewerBanned(viewerName)) {
        std::cout << "[Cast] addViewer failed: viewer '" << viewerName << "' is banned" << std::endl;
        return false;
    }
    
    // Check password
    if (hasPassword() && password != pwd) {
        std::cout << "[Cast] addViewer failed: incorrect password for '" << viewerName << "'" << std::endl;
        return false;
    }
    
    // Check if viewer already exists
    std::cout << "[Cast] Checking for existing viewers... Current count: " << viewers.size() << std::endl;
    for (const auto& viewer : viewers) {
        std::cout << "[Cast]   Existing viewer: name='" << viewer.name << "', protocol=" << viewer.protocol << std::endl;
        if (viewer.name == viewerName) {
            std::cout << "[Cast] addViewer FAILED: viewer name '" << viewerName << "' already exists" << std::endl;
            return false;
        }
        if (viewer.protocol == protocol) {
            std::cout << "[Cast] addViewer FAILED: protocol " << protocol << " already in use" << std::endl;
            return false;
        }
    }
    
    std::cout << "[Cast] ✅ No conflicts found! Adding viewer '" << viewerName << "' (current viewers: " << viewers.size() << ")" << std::endl;
    
    CastViewer viewer;
    viewer.name = viewerName;
    viewer.ip = viewerIp;
    viewer.protocol = protocol;
    viewer.connectTime = time(nullptr);
    
    viewers.push_back(viewer);
    
    // Update database and broadcast join message to Cast Channel only
    if (owner) {
        IOLoginData::updateCastStatus(owner->getGUID(), true, viewers.size());
        
        // Broadcast join message to Cast Channel (in orange) - NO console message
        if (g_chat && viewerPlayer) {
            ChatChannel* channel = g_chat->getChannel(*owner, CHANNEL_CAST);
            if (channel) {
                std::ostringstream joinMsg;
                joinMsg << "has joined the cast (" << viewers.size() << " viewer" << (viewers.size() > 1 ? "s" : "") << " watching)";
                // Use channel->talk() to broadcast to all users once
                channel->talk(*viewerPlayer, TALKTYPE_CHANNEL_O, joinMsg.str());
            }
        }
    }
    
    return true;
}

void Cast::removeViewer(ProtocolGame* protocol, Player* viewerPlayer)
{
    for (auto it = viewers.begin(); it != viewers.end(); ++it) {
        if (it->protocol == protocol) {
            std::string viewerName = it->name;
            viewers.erase(it);
            
            // Update database and broadcast leave message to Cast Channel only
            if (owner) {
                IOLoginData::updateCastStatus(owner->getGUID(), true, viewers.size());
                
                // Broadcast leave message to Cast Channel (in orange) - NO console message
                if (g_chat && viewerPlayer) {
                    ChatChannel* channel = g_chat->getChannel(*owner, CHANNEL_CAST);
                    if (channel) {
                        std::ostringstream leaveMsg;
                        leaveMsg << "has left the cast (" << viewers.size() << " viewer" << (viewers.size() > 1 ? "s" : "") << " watching)";
                        // Use channel->talk() to broadcast to all users once
                        channel->talk(*viewerPlayer, TALKTYPE_CHANNEL_O, leaveMsg.str());
                    }
                }
            }
            break;
        }
    }
}

void Cast::removeViewer(const std::string& viewerName)
{
    for (auto it = viewers.begin(); it != viewers.end(); ++it) {
        if (it->name == viewerName) {
            if (it->protocol) {
                it->protocol->disconnect();
            }
            viewers.erase(it);
            // Update database
            if (owner) {
                IOLoginData::updateCastStatus(owner->getGUID(), true, viewers.size());
            }
            break;
        }
    }
}

void Cast::setPassword(const std::string& newPassword)
{
    password = newPassword;
    
    if (owner) {
        std::ostringstream ss;
        if (password.empty()) {
            ss << "Cast password removed. Stream is now public.";
        } else {
            ss << "Cast password set. Stream is now private.";
        }
        owner->sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, ss.str());
    }
}

void Cast::banViewer(const std::string& viewerName)
{
    bannedViewers.insert(viewerName);
    removeViewer(viewerName);
    
    if (owner) {
        std::ostringstream ss;
        ss << "Viewer '" << viewerName << "' has been banned from your cast.";
        owner->sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, ss.str());
    }
}

void Cast::unbanViewer(const std::string& viewerName)
{
    bannedViewers.erase(viewerName);
    
    if (owner) {
        std::ostringstream ss;
        ss << "Viewer '" << viewerName << "' has been unbanned from your cast.";
        owner->sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, ss.str());
    }
}

bool Cast::isViewerBanned(const std::string& viewerName) const
{
    return bannedViewers.find(viewerName) != bannedViewers.end();
}

void Cast::broadcastToViewers(const NetworkMessage& msg)
{
	for (const auto& viewer : viewers) {
		if (viewer.protocol) {
			auto out = viewer.protocol->getOutputBuffer(msg.getLength());
			out->append(msg);
		}
	}
}

void Cast::broadcastToViewers(const std::function<void(ProtocolGame*)>& func)
{
    for (const auto& viewer : viewers) {
        if (viewer.protocol) {
            func(viewer.protocol);
        }
    }
}

// CastManager implementation
void CastManager::addCast(Cast* cast)
{
    casts.push_back(cast);
}

void CastManager::removeCast(Cast* cast)
{
    auto it = std::find(casts.begin(), casts.end(), cast);
    if (it != casts.end()) {
        casts.erase(it);
    }
}

Cast* CastManager::getCastByOwner(Player* player)
{
    for (Cast* cast : casts) {
        if (cast->getOwner() == player) {
            return cast;
        }
    }
    return nullptr;
}

std::vector<Cast*> CastManager::getAllCasts()
{
    return casts;
}

size_t CastManager::getTotalViewers() const
{
    size_t total = 0;
    for (const Cast* cast : casts) {
        total += cast->getViewerCount();
    }
    return total;
}

