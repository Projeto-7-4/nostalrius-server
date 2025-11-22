bool Market::addItemsToPlayer(Player* player, uint16_t itemId, uint16_t amount)
{
	if (!player) {
		std::cout << "[Market ERROR] addItemsToPlayer: player is NULL!" << std::endl;
		return false;
	}

	std::cout << "[Market DEBUG] addItemsToPlayer: itemId=" << itemId << ", amount=" << amount << std::endl;

	// Add items to player
	const ItemType& it = Item::items[itemId];
	uint16_t remaining = amount;

	std::cout << "[Market DEBUG] Item name: " << it.name << std::endl;

	// VALIDAÇÃO CRÍTICA: Verificar se há ESPAÇO antes de adicionar QUALQUER item
	// Se algum item não puder ser adicionado, FALHAR TUDO
	std::vector<Item*> createdItems;
	
	while (remaining > 0) {
		uint16_t count = std::min<uint16_t>(remaining, 100); // Max stack
		std::cout << "[Market DEBUG] Creating item with count=" << count << ", remaining=" << remaining << std::endl;
		
		Item* item = Item::CreateItem(itemId, count);
		if (!item) {
			std::cout << "[Market ERROR] Failed to CreateItem!" << std::endl;
			// Limpar itens já criados
			for (Item* createdItem : createdItems) {
				delete createdItem;
			}
			return false;
		}

		// Tentar adicionar o item
		std::cout << "[Market DEBUG] Attempting to add item to player..." << std::endl;
		
		// CRÍTICO: Usar FLAG_NOLIMIT para evitar que o item caia no chão
		// Se retornar erro, significa que não há espaço
		ReturnValue ret = g_game.internalPlayerAddItem(player, item, INDEX_WHEREEVER, FLAG_NOLIMIT);
		
		std::cout << "[Market DEBUG] internalPlayerAddItem returned: " << (int)ret << std::endl;
		
		if (ret != RETURNVALUE_NOERROR) {
			std::cout << "[Market ERROR] Failed to add item! Return value: " << (int)ret << std::endl;
			delete item;
			
			// ROLLBACK: Remover todos os itens já adicionados
			for (Item* addedItem : createdItems) {
				player->removeItem(addedItem, true);
			}
			
			return false;
		}

		createdItems.push_back(item);
		std::cout << "[Market DEBUG] Item added successfully! Remaining=" << (remaining - count) << std::endl;
		remaining -= count;
	}

	std::cout << "[Market DEBUG] All items added successfully!" << std::endl;
	return true;
}



