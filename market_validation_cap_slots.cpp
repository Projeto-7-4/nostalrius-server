// Adicionar ANTES de addItemsToPlayer na função acceptOffer:

		// ====================================
		// VALIDAÇÃO: CAPACITY E SLOTS
		// ====================================
		
		// 1. Verificar Capacity (Cap)
		const ItemType& it = Item::items[offer.itemId];
		uint32_t totalWeight = it.weight * amount;
		
		uint32_t freeCapacity = std::max<int32_t>(0, player->getCapacity() - player->inventoryWeight);
		
		std::cout << "[Market DEBUG] Item weight: " << it.weight << ", amount: " << amount << ", total: " << totalWeight << std::endl;
		std::cout << "[Market DEBUG] Player capacity: " << player->getCapacity() << ", used: " << player->inventoryWeight << ", free: " << freeCapacity << std::endl;
		
		if (totalWeight > freeCapacity) {
			// Refund
			player->bankBalance += totalPrice;
			std::cout << "[Market ERROR] Insufficient capacity! Refunding gold." << std::endl;
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough capacity. Purchase cancelled and refunded.");
			return false;
		}
		
		// 2. Verificar Slots (simples check se pode adicionar)
		// Vamos tentar adicionar um item de teste (sem realmente adicionar)
		Item* testItem = Item::CreateItem(offer.itemId, 1);
		if (!testItem) {
			player->bankBalance += totalPrice;
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "Invalid item. Purchase cancelled and refunded.");
			return false;
		}
		
		// Verificar se há espaço no inventário
		ReturnValue ret = g_game.internalPlayerAddItem(player, testItem, true); // true = test mode
		delete testItem; // Limpar item de teste
		
		if (ret != RETURNVALUE_NOERROR) {
			// Refund
			player->bankBalance += totalPrice;
			std::cout << "[Market ERROR] Insufficient inventory space! Refunding gold." << std::endl;
			
			std::string errorMsg = "You don't have enough space in your inventory. ";
			if (ret == RETURNVALUE_NOTENOUGHROOM) {
				errorMsg += "Please free some space in your backpack.";
			} else if (ret == RETURNVALUE_CONTAINERNOTENOUGHROOM) {
				errorMsg += "Your containers are full.";
			} else {
				errorMsg += "Error code: " + std::to_string((int)ret);
			}
			
			player->sendTextMessage(MESSAGE_STATUS_SMALL, errorMsg);
			return false;
		}
		
		std::cout << "[Market] ✅ Validation passed: Capacity and Slots OK!" << std::endl;
		
		// AGORA SIM, adicionar os itens
		std::cout << "[Market DEBUG] Calling addItemsToPlayer..." << std::endl;



