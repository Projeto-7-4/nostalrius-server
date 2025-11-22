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

	while (remaining > 0) {
		uint16_t count = std::min<uint16_t>(remaining, 100); // Max stack
		std::cout << "[Market DEBUG] Creating item with count=" << count << ", remaining=" << remaining << std::endl;
		
		Item* item = Item::CreateItem(itemId, count);
		if (!item) {
			std::cout << "[Market ERROR] Failed to CreateItem!" << std::endl;
			return false;
		}

		std::cout << "[Market DEBUG] Item created, adding to player..." << std::endl;

		ReturnValue ret = g_game.internalPlayerAddItem(player, item);
		if (ret != RETURNVALUE_NOERROR) {
			std::cout << "[Market ERROR] internalPlayerAddItem failed with ret=" << (int)ret << std::endl;
			delete item;
			return false;
		}

		std::cout << "[Market DEBUG] Item added successfully! Remaining=" << (remaining - count) << std::endl;
		remaining -= count;
	}

	std::cout << "[Market DEBUG] All items added successfully!" << std::endl;
	return true;
}



