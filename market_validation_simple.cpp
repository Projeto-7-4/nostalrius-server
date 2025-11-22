// Adicionar ANTES de chamar addItemsToPlayer em acceptOffer:

		// ====================================
		// VALIDAÇÃO CRÍTICA: VERIFICAR ESPAÇO NO INVENTÁRIO
		// ====================================
		
		// Verificar se player tem pelo menos 1 container (backpack/bag) para receber items
		bool hasContainer = false;
		Container* mainContainer = nullptr;
		
		for (int32_t slot = CONST_SLOT_FIRST; slot <= CONST_SLOT_LAST; ++slot) {
			Item* item = player->getInventoryItem((slots_t)slot);
			if (item && item->getContainer()) {
				Container* container = item->getContainer();
				// Verificar se há pelo menos 1 slot livre
				if (container->capacity() > container->size()) {
					hasContainer = true;
					mainContainer = container;
					std::cout << "[Market] Found container in slot " << slot << " with " << (container->capacity() - container->size()) << " free slots" << std::endl;
					break;
				}
			}
		}
		
		if (!hasContainer) {
			// Refund
			player->bankBalance += totalPrice;
			std::cout << "[Market ERROR] No container with free space! Refunding gold." << std::endl;
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You need to have a backpack/bag with free space to receive items. Purchase cancelled and refunded.");
			return false;
		}
		
		// Verificar se há espaço suficiente para TODOS os items
		uint16_t slotsNeeded = (amount + 99) / 100; // Arredondar para cima (max stack = 100)
		uint16_t freeSlots = mainContainer->capacity() - mainContainer->size();
		
		std::cout << "[Market DEBUG] Slots needed: " << slotsNeeded << ", free slots: " << freeSlots << std::endl;
		
		if (slotsNeeded > freeSlots) {
			// Refund
			player->bankBalance += totalPrice;
			std::cout << "[Market ERROR] Not enough free slots! Refunding gold." << std::endl;
			std::ostringstream ss;
			ss << "You need " << slotsNeeded << " free slots in your backpack, but only have " << freeSlots << ". Purchase cancelled and refunded.";
			player->sendTextMessage(MESSAGE_STATUS_SMALL, ss.str());
			return false;
		}
		
		std::cout << "[Market] ✅ Container validation passed!" << std::endl;



