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

#ifndef FS_CAST_H
#define FS_CAST_H

#include <set>
#include <string>
#include <vector>
#include <functional>
#include "player.h"
#include "protocolgame.h"

class Cast;
class ProtocolGame;

struct CastViewer {
    std::string name;
    std::string ip;
    ProtocolGame* protocol;
    uint32_t connectTime;
};

class Cast
{
public:
    Cast(Player* player);
    ~Cast();

    // Cast control
    bool startCast(const std::string& password = "");
    void stopCast();
    bool isCasting() const { return casting; }
    
    // Viewer management
    bool addViewer(ProtocolGame* protocol, const std::string& viewerName, const std::string& viewerIp, const std::string& password = "", Player* viewerPlayer = nullptr);
    void removeViewer(ProtocolGame* protocol, Player* viewerPlayer = nullptr);
    void removeViewer(const std::string& viewerName);
    size_t getViewerCount() const { return viewers.size(); }
    const std::vector<CastViewer>& getViewers() const { return viewers; }
    
    // Password management
    void setPassword(const std::string& newPassword);
    bool hasPassword() const { return !password.empty(); }
    bool checkPassword(const std::string& pwd) const { return password == pwd; }
    void removePassword() { password.clear(); }
    
    // Ban management
    void banViewer(const std::string& viewerName);
    void unbanViewer(const std::string& viewerName);
    bool isViewerBanned(const std::string& viewerName) const;
    
    // Broadcasting
    void broadcastToViewers(const NetworkMessage& msg);
    void broadcastToViewers(const std::function<void(ProtocolGame*)>& func);
    
    // Getters
    Player* getOwner() const { return owner; }
    const std::string& getDescription() const { return description; }
    void setDescription(const std::string& desc) { description = desc; }
    uint32_t getNextViewerNumber() { return ++viewerCounter; } // Get next viewer number

private:
    Player* owner;
    std::vector<CastViewer> viewers;
    std::set<std::string> bannedViewers;
    std::string password;
    std::string description;
    bool casting;
    time_t startTime;
    uint32_t viewerCounter; // Cast System - counter for viewer numbering
};

// Global cast manager
class CastManager
{
public:
    static CastManager& getInstance() {
        static CastManager instance;
        return instance;
    }
    
    // Cast management
    void addCast(Cast* cast);
    void removeCast(Cast* cast);
    Cast* getCastByOwner(Player* player);
    std::vector<Cast*> getAllCasts();
    
    // Statistics
    size_t getTotalCasts() const { return casts.size(); }
    size_t getTotalViewers() const;

private:
    CastManager() = default;
    std::vector<Cast*> casts;
};

#endif

