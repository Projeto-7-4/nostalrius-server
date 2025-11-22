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
		std::cout << "[Market DEBUG] Player is BUYING from offer (type=SELL)" << std::endl;
		
		// Check if player has enough gold
		uint64_t availableGold = player->getMoney() + player->bankBalance;
		std::cout << "[Market DEBUG] Available gold: " << availableGold << " (inventory: " << player->getMoney() << ", bank: " << player->bankBalance << ")" << std::endl;
		std::cout << "[Market DEBUG] Total price: " << totalPrice << std::endl;
		
		if (availableGold < totalPrice) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough gold.");
			return false;
		}

		// Remove gold from buyer (bank first, then inventory)
		uint64_t bankGold = player->bankBalance;
		if (bankGold >= totalPrice) {
			player->bankBalance -= totalPrice;
			std::cout << "[Market] Deducted " << totalPrice << " gp from bank. New balance: " << player->bankBalance << std::endl;
		} else {
			player->bankBalance = 0;
			uint64_t remainingCost = totalPrice - bankGold;
			if (!player->removeItemOfType(ITEM_GOLD_COIN, remainingCost, -1)) {
				player->bankBalance = bankGold; // Restore
				player->sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough gold.");
				return false;
			}
			std::cout << "[Market] Deducted " << bankGold << " from bank and " << remainingCost << " from inventory" << std::endl;
		}

		// Add items to buyer
		std::cout << "[Market DEBUG] Calling addItemsToPlayer..." << std::endl;
		if (!addItemsToPlayer(player, offer.itemId, amount)) {
			// Refund
			player->bankBalance += totalPrice;
			std::cout << "[Market ERROR] addItemsToPlayer FAILED! Refunding gold." << std::endl;
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "Failed to receive items.");
			return false;
		}

		std::cout << "[Market] ✅ Items added and gold deducted successfully!" << std::endl;

		// Send gold to seller (add to seller's bank)
		query.str("");
		query << "UPDATE `players` SET `balance` = `balance` + " << totalPrice 
			  << " WHERE `id` = " << offer.playerId;
		db->executeQuery(query.str());

	} else if (offer.type == MARKET_ACTION_BUY) {
		// Player is SELLING to the offer
		std::cout << "[Market DEBUG] Player is SELLING to offer (type=BUY)" << std::endl;
		
		// Check if player has the items
		if (!removeItemsFromPlayer(player, offer.itemId, amount)) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough items.");
			return false;
		}

		// Give gold to seller (current player) - add to bank
		player->bankBalance += totalPrice;
		std::cout << "[Market] Added " << totalPrice << " gp to bank. New balance: " << player->bankBalance << std::endl;
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



