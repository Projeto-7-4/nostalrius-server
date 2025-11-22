/**
 * =============================================
 * MARKET SYSTEM - Protocol Integration
 * =============================================
 * 
 * ADICIONAR ESTAS FUNÇÕES AO protocolgame.cpp:
 * 
 * 1. Adicionar #include "market.h" no topo
 * 2. Adicionar os opcodes no parsePacket()
 * 3. Adicionar as funções parse* e send* abaixo
 */

// =============================================
// 1. ADICIONAR NO parsePacket() - dentro do switch(recvbyte)
// =============================================
/*
	case 0xF0: parseMarketBrowse(msg); break;
	case 0xF1: parseMarketCreate(msg); break;
	case 0xF2: parseMarketCancel(msg); break;
	case 0xF3: parseMarketAccept(msg); break;
*/

// =============================================
// 2. ADICIONAR ESTAS FUNÇÕES NO protocolgame.cpp
// =============================================

void ProtocolGame::parseMarketBrowse(NetworkMessage& msg)
{
	uint8_t offerType = msg.getByte(); // 0 = buy, 1 = sell, 2 = all
	
	std::vector<MarketOffer> offers = Market::getInstance().getActiveOffers(offerType);
	sendMarketOffers(offers);
}

void ProtocolGame::parseMarketCreate(NetworkMessage& msg)
{
	uint8_t offerType = msg.getByte(); // 0 = buy, 1 = sell
	uint16_t itemId = msg.get<uint16_t>();
	uint16_t amount = msg.get<uint16_t>();
	uint32_t price = msg.get<uint32_t>();
	
	if (Market::getInstance().createOffer(player, itemId, amount, price, offerType)) {
		// Refresh offers
		uint8_t browseType = 2; // all
		std::vector<MarketOffer> offers = Market::getInstance().getActiveOffers(browseType);
		sendMarketOffers(offers);
	}
}

void ProtocolGame::parseMarketCancel(NetworkMessage& msg)
{
	uint32_t offerId = msg.get<uint32_t>();
	
	if (Market::getInstance().cancelOffer(player, offerId)) {
		// Refresh offers
		std::vector<MarketOffer> offers = Market::getInstance().getPlayerOffers(player->getGUID());
		sendMarketOffers(offers);
	}
}

void ProtocolGame::parseMarketAccept(NetworkMessage& msg)
{
	uint32_t offerId = msg.get<uint32_t>();
	uint16_t amount = msg.get<uint16_t>();
	
	if (Market::getInstance().acceptOffer(player, offerId, amount)) {
		// Refresh offers
		uint8_t browseType = 2; // all
		std::vector<MarketOffer> offers = Market::getInstance().getActiveOffers(browseType);
		sendMarketOffers(offers);
	}
}

void ProtocolGame::sendMarketOffers(const std::vector<MarketOffer>& offers)
{
	NetworkMessage msg;
	msg.addByte(0xF7); // Market offers packet
	
	msg.addByte(static_cast<uint8_t>(offers.size()));
	
	for (const MarketOffer& offer : offers) {
		msg.add<uint32_t>(offer.id);
		msg.add<uint16_t>(offer.itemId);
		msg.add<uint16_t>(offer.amount);
		msg.add<uint32_t>(offer.price);
		msg.addByte(offer.type);
		msg.addString(offer.playerName);
		
		// Calculate time remaining
		time_t now = time(nullptr);
		int32_t secondsRemaining = static_cast<int32_t>(offer.expiresAt - now);
		msg.add<uint32_t>(std::max<int32_t>(0, secondsRemaining));
	}
	
	writeToOutputBuffer(msg);
}

// =============================================
// 3. ADICIONAR NO protocolgame.h (header)
// =============================================
/*
	void parseMarketBrowse(NetworkMessage& msg);
	void parseMarketCreate(NetworkMessage& msg);
	void parseMarketCancel(NetworkMessage& msg);
	void parseMarketAccept(NetworkMessage& msg);
	void sendMarketOffers(const std::vector<MarketOffer>& offers);
*/

// =============================================
// 4. ADICIONAR NO CMakeLists.txt (src/CMakeLists.txt)
// =============================================
/*
	${CMAKE_CURRENT_LIST_DIR}/market.cpp
*/

// =============================================
// FIM DO ARQUIVO DE INTEGRAÇÃO
// =============================================



