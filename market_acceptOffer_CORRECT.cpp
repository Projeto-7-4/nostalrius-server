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
		// TODO: Handle offline players properly
		// For now, we'll update the seller's bank balance directly in DB
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



