/**
 * Market System Implementation
 * Nostalrius 7.72
 */

#include "otpch.h"
#include "market.h"
#include "game.h"
#include "iologindata.h"
#include "configmanager.h"

extern Game g_game;
extern ConfigManager g_config;

// =============================================
// CREATE OFFER
// =============================================
bool Market::createOffer(Player* player, uint16_t itemId, uint16_t amount, uint32_t price, uint8_t type)
{
	if (!player) {
		return false;
	}

	// Validate offer
	if (!validateOffer(player, itemId, amount, price, type)) {
		return false;
	}

	Database* db = Database::getInstance();
	if (!db) {
		return false;
	}

	// Check player offer limit (max 50 offers per player)
	if (getPlayerOffersCount(player->getGUID()) >= 50) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "You have reached the maximum number of offers (50).");
		return false;
	}

	// For SELL offers, remove items from player
	if (type == MARKET_ACTION_SELL) {
		if (!removeItemsFromPlayer(player, itemId, amount)) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough items to create this offer.");
			return false;
		}
	}
	// For BUY offers, lock the gold
	else if (type == MARKET_ACTION_BUY) {
		uint32_t totalPrice = amount * price;
		if (player->getMoney() < totalPrice) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough gold to create this offer.");
			return false;
		}
		if (!g_game.removeMoney(player, totalPrice)) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "Failed to lock gold for this offer.");
			return false;
		}
	}

	// Insert offer into database (expires in 7 days)
	std::ostringstream query;
	query << "INSERT INTO `market_offers` (`player_id`, `item_id`, `amount`, `price`, `type`, `expires_at`) VALUES ("
		  << player->getGUID() << ", "
		  << itemId << ", "
		  << amount << ", "
		  << price << ", "
		  << static_cast<int>(type) << ", "
		  << "DATE_ADD(NOW(), INTERVAL 7 DAY))";

	if (!db->executeQuery(query.str())) {
		std::cout << "[Market] ERROR: Failed to insert offer into database" << std::endl;
		return false;
	}

	player->sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your offer has been created successfully!");
	std::cout << "[Market] Player " << player->getName() << " created offer: " 
			  << amount << "x item " << itemId << " for " << price << " gp each (" 
			  << (type == MARKET_ACTION_SELL ? "SELL" : "BUY") << ")" << std::endl;

	return true;
}

// =============================================
// CANCEL OFFER
// =============================================
bool Market::cancelOffer(Player* player, uint32_t offerId)
{
	if (!player) {
		return false;
	}

	Database* db = Database::getInstance();
	if (!db) {
		return false;
	}

	// Get offer details
	std::ostringstream query;
	query << "SELECT `player_id`, `item_id`, `amount`, `price`, `type` FROM `market_offers` "
		  << "WHERE `id` = " << offerId << " AND `is_active` = 1";

	DBResult_ptr result = db->storeQuery(query.str());
	if (!result) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "Offer not found or already cancelled.");
		return false;
	}

	uint32_t ownerId = result->getNumber<uint32_t>("player_id");
	if (ownerId != player->getGUID()) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "You can only cancel your own offers.");
		return false;
	}

	uint16_t itemId = result->getNumber<uint16_t>("item_id");
	uint16_t amount = result->getNumber<uint16_t>("amount");
	uint32_t price = result->getNumber<uint32_t>("price");
	uint8_t type = result->getNumber<uint8_t>("type");

	// Mark offer as inactive
	query.str("");
	query << "UPDATE `market_offers` SET `is_active` = 0 WHERE `id` = " << offerId;
	if (!db->executeQuery(query.str())) {
		std::cout << "[Market] ERROR: Failed to cancel offer" << std::endl;
		return false;
	}

	// Return items/gold to player
	if (type == MARKET_ACTION_SELL) {
		if (!addItemsToPlayer(player, itemId, amount)) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "Failed to return items. Contact an administrator.");
			std::cout << "[Market] ERROR: Failed to return items to player " << player->getName() 
					  << " for cancelled offer " << offerId << std::endl;
			return false;
		}
	} else if (type == MARKET_ACTION_BUY) {
		uint32_t totalPrice = amount * price;
		g_game.addMoney(player, totalPrice);
	}

	player->sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your offer has been cancelled.");
	std::cout << "[Market] Player " << player->getName() << " cancelled offer " << offerId << std::endl;

	return true;
}

// =============================================
// ACCEPT OFFER
// =============================================
bool Market::acceptOffer(Player* player, uint32_t offerId, uint16_t amount)
{
	if (!player) {
		return false;
	}

	Database* db = Database::getInstance();
	if (!db) {
		return false;
	}

	// Get offer details
	std::ostringstream query;
	query << "SELECT * FROM `market_offers_view` WHERE `id` = " << offerId;

	DBResult_ptr result = db->storeQuery(query.str());
	if (!result) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "Offer not found or expired.");
		return false;
	}

	MarketOffer offer;
	offer.id = result->getNumber<uint32_t>("id");
	offer.playerId = result->getNumber<uint32_t>("player_id");
	offer.playerName = result->getString("player_name");
	offer.itemId = result->getNumber<uint16_t>("item_id");
	offer.amount = result->getNumber<uint16_t>("amount");
	offer.price = result->getNumber<uint32_t>("price");
	offer.type = result->getNumber<uint8_t>("type");

	// Validate amount
	if (amount > offer.amount) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "Invalid amount.");
		return false;
	}

	// Can't accept own offer
	if (offer.playerId == player->getGUID()) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "You can't accept your own offer.");
		return false;
	}

	uint32_t totalPrice = amount * offer.price;

	// Execute transaction based on offer type
	if (offer.type == MARKET_ACTION_SELL) {
		// Player is BUYING from the offer
		// Check if player has enough gold
		if (player->getMoney() < totalPrice) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough gold.");
			return false;
		}

		// Remove gold from buyer
		if (!g_game.removeMoney(player, totalPrice)) {
			return false;
		}

		// Add items to buyer
		if (!addItemsToPlayer(player, offer.itemId, amount)) {
			g_game.addMoney(player, totalPrice); // Refund
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "Failed to receive items.");
			return false;
		}

		// Send gold to seller (offline player handling)
		// In a real implementation, you'd need to handle offline players properly
		// For now, we'll just add it to their bank

	} else if (offer.type == MARKET_ACTION_BUY) {
		// Player is SELLING to the offer
		// Check if player has the items
		if (!removeItemsFromPlayer(player, offer.itemId, amount)) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough items.");
			return false;
		}

		// Give gold to seller (current player)
		g_game.addMoney(player, totalPrice);
	}

	// Update or remove offer
	if (amount >= offer.amount) {
		// Complete offer - mark as inactive
		query.str("");
		query << "UPDATE `market_offers` SET `is_active` = 0 WHERE `id` = " << offerId;
	} else {
		// Partial offer - reduce amount
		query.str("");
		query << "UPDATE `market_offers` SET `amount` = `amount` - " << amount 
			  << " WHERE `id` = " << offerId;
	}

	if (!db->executeQuery(query.str())) {
		std::cout << "[Market] ERROR: Failed to update offer after transaction" << std::endl;
	}

	// Log transaction
	MarketTransaction transaction;
	transaction.offerId = offerId;
	transaction.buyerId = (offer.type == MARKET_ACTION_SELL) ? player->getGUID() : offer.playerId;
	transaction.sellerId = (offer.type == MARKET_ACTION_SELL) ? offer.playerId : player->getGUID();
	transaction.itemId = offer.itemId;
	transaction.amount = amount;
	transaction.totalPrice = totalPrice;
	logTransaction(transaction);

	player->sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Transaction completed successfully!");
	std::cout << "[Market] Player " << player->getName() << " accepted offer " << offerId 
			  << " for " << amount << " items" << std::endl;

	return true;
}

// =============================================
// GET ACTIVE OFFERS
// =============================================
std::vector<MarketOffer> Market::getActiveOffers(uint8_t type)
{
	std::vector<MarketOffer> offers;

	Database* db = Database::getInstance();
	if (!db) {
		return offers;
	}

	std::ostringstream query;
	query << "SELECT * FROM `market_offers_view`";
	
	if (type != 2) { // 2 = all
		query << " WHERE `type` = " << static_cast<int>(type);
	}
	
	query << " ORDER BY `created_at` DESC LIMIT 100";

	DBResult_ptr result = db->storeQuery(query.str());
	if (!result) {
		return offers;
	}

	do {
		MarketOffer offer;
		offer.id = result->getNumber<uint32_t>("id");
		offer.playerId = result->getNumber<uint32_t>("player_id");
		offer.playerName = result->getString("player_name");
		offer.itemId = result->getNumber<uint16_t>("item_id");
		offer.amount = result->getNumber<uint16_t>("amount");
		offer.price = result->getNumber<uint32_t>("price");
		offer.type = result->getNumber<uint8_t>("type");
		offer.createdAt = result->getNumber<time_t>("created_at");
		offer.expiresAt = result->getNumber<time_t>("expires_at");
		
		offers.push_back(offer);
	} while (result->next());

	return offers;
}

// =============================================
// GET PLAYER OFFERS
// =============================================
std::vector<MarketOffer> Market::getPlayerOffers(uint32_t playerId)
{
	std::vector<MarketOffer> offers;

	Database* db = Database::getInstance();
	if (!db) {
		return offers;
	}

	std::ostringstream query;
	query << "SELECT * FROM `market_offers_view` WHERE `player_id` = " << playerId 
		  << " ORDER BY `created_at` DESC";

	DBResult_ptr result = db->storeQuery(query.str());
	if (!result) {
		return offers;
	}

	do {
		MarketOffer offer;
		offer.id = result->getNumber<uint32_t>("id");
		offer.playerId = result->getNumber<uint32_t>("player_id");
		offer.playerName = result->getString("player_name");
		offer.itemId = result->getNumber<uint16_t>("item_id");
		offer.amount = result->getNumber<uint16_t>("amount");
		offer.price = result->getNumber<uint32_t>("price");
		offer.type = result->getNumber<uint8_t>("type");
		offer.createdAt = result->getNumber<time_t>("created_at");
		offer.expiresAt = result->getNumber<time_t>("expires_at");
		
		offers.push_back(offer);
	} while (result->next());

	return offers;
}

// =============================================
// UTILITY FUNCTIONS
// =============================================
bool Market::validateOffer(Player* player, uint16_t itemId, uint16_t amount, uint32_t price, uint8_t type)
{
	if (!player || amount == 0 || price == 0) {
		return false;
	}

	// Check if item exists
	const ItemType& it = Item::items[itemId];
	if (it.id == 0) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "Invalid item.");
		return false;
	}

	// Check if item is tradeable
	if (it.disguise || itemId > 8000) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "This item cannot be traded in the market.");
		return false;
	}

	return true;
}

bool Market::removeItemsFromPlayer(Player* player, uint16_t itemId, uint16_t amount)
{
	if (!player) {
		return false;
	}

	// Check if player has the items
	if (player->getItemTypeCount(itemId) < amount) {
		return false;
	}

	// Remove items
	return player->removeItemOfType(itemId, amount);
}

bool Market::addItemsToPlayer(Player* player, uint16_t itemId, uint16_t amount)
{
	if (!player) {
		return false;
	}

	// Add items to player
	const ItemType& it = Item::items[itemId];
	uint16_t remaining = amount;

	while (remaining > 0) {
		uint16_t count = std::min<uint16_t>(remaining, 100); // Max stack
		Item* item = Item::CreateItem(itemId, count);
		if (!item) {
			return false;
		}

		ReturnValue ret = g_game.internalPlayerAddItem(player, item);
		if (ret != RET_NOERROR) {
			delete item;
			return false;
		}

		remaining -= count;
	}

	return true;
}

uint32_t Market::getPlayerOffersCount(uint32_t playerId)
{
	Database* db = Database::getInstance();
	if (!db) {
		return 0;
	}

	std::ostringstream query;
	query << "SELECT COUNT(*) as `count` FROM `market_offers` "
		  << "WHERE `player_id` = " << playerId << " AND `is_active` = 1";

	DBResult_ptr result = db->storeQuery(query.str());
	if (!result) {
		return 0;
	}

	return result->getNumber<uint32_t>("count");
}

void Market::logTransaction(const MarketTransaction& transaction)
{
	Database* db = Database::getInstance();
	if (!db) {
		return;
	}

	std::ostringstream query;
	query << "INSERT INTO `market_history` "
		  << "(`offer_id`, `buyer_id`, `seller_id`, `item_id`, `amount`, `price`) VALUES ("
		  << transaction.offerId << ", "
		  << transaction.buyerId << ", "
		  << transaction.sellerId << ", "
		  << transaction.itemId << ", "
		  << transaction.amount << ", "
		  << transaction.totalPrice << ")";

	db->executeQuery(query.str());
}

void Market::cleanExpiredOffers()
{
	Database* db = Database::getInstance();
	if (!db) {
		return;
	}

	db->executeQuery("CALL clean_expired_offers()");
	std::cout << "[Market] Cleaned expired offers" << std::endl;
}
