/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2019  Mark Samman <mark.samman@gmail.com>
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

#ifndef FS_MARKET_H
#define FS_MARKET_H

#include "player.h"
#include "database.h"

enum MarketAction_t {
	MARKET_ACTION_BUY = 0,
	MARKET_ACTION_SELL = 1
};

enum MarketOfferState_t {
	OFFER_STATE_ACTIVE = 1,
	OFFER_STATE_CANCELLED = 2,
	OFFER_STATE_EXPIRED = 3,
	OFFER_STATE_ACCEPTED = 4
};

struct MarketOffer {
	uint32_t id;
	uint32_t playerId;
	std::string playerName;
	uint16_t itemId;
	uint16_t amount;
	uint32_t price;
	uint8_t type; // 0 = buy, 1 = sell
	time_t createdAt;
	time_t expiresAt;
	
	MarketOffer() : id(0), playerId(0), itemId(0), amount(0), price(0), type(0), createdAt(0), expiresAt(0) {}
};

struct MarketTransaction {
	uint32_t offerId;
	uint32_t buyerId;
	uint32_t sellerId;
	uint16_t itemId;
	uint16_t amount;
	uint32_t totalPrice;
	time_t timestamp;
};

class Market
{
public:
	Market() = default;
	~Market() = default;

	// Non-copyable
	Market(const Market&) = delete;
	Market& operator=(const Market&) = delete;

	static Market& getInstance() {
		static Market instance;
		return instance;
	}

	// Offer Management
	bool createOffer(Player* player, uint16_t itemId, uint16_t amount, uint32_t price, uint8_t type);
	bool cancelOffer(Player* player, uint32_t offerId);
	bool acceptOffer(Player* player, uint32_t offerId, uint16_t amount);
	
	// Query Functions
	std::vector<MarketOffer> getActiveOffers(uint8_t type = 2); // 2 = all
	std::vector<MarketOffer> getPlayerOffers(uint32_t playerId);
	std::vector<MarketTransaction> getPlayerHistory(uint32_t playerId, uint32_t limit = 20);
	MarketOffer* getOfferById(uint32_t offerId);
	
	// Utility
	uint32_t getPlayerOffersCount(uint32_t playerId);
	void cleanExpiredOffers();
	
private:
	bool validateOffer(Player* player, uint16_t itemId, uint16_t amount, uint32_t price, uint8_t type);
	bool executeTransaction(Player* buyer, Player* seller, const MarketOffer& offer, uint16_t amount);
	bool removeItemsFromPlayer(Player* player, uint16_t itemId, uint16_t amount);
	bool addItemsToPlayer(Player* player, uint16_t itemId, uint16_t amount);
	bool transferGold(Player* from, Player* to, uint32_t amount);
	void logTransaction(const MarketTransaction& transaction);
};

#endif // FS_MARKET_H
