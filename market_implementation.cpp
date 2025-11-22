// =============================================
// IMPLEMENTAÇÕES PARA ADICIONAR NO FINAL DE protocolgame.cpp
// =============================================
// 
// COPIAR ESTE BLOCO INTEIRO E COLAR NO FINAL DO protocolgame.cpp

#include "market.h"

void ProtocolGame::parseMarketRequestOffers(NetworkMessage& msg)
{
	if (!player) {
		return;
	}

	uint8_t offerType = 2; // All offers
	std::vector<MarketOffer> offers = Market::getInstance().getActiveOffers(offerType);
	sendMarketOffers(offers);
	
	std::cout << "[Market] Player " << player->getName() << " requested offers" << std::endl;
}

void ProtocolGame::parseMarketBuy(NetworkMessage& msg)
{
	if (!player) {
		return;
	}

	uint32_t offerId = msg.get<uint32_t>();
	uint16_t amount = msg.get<uint16_t>();
	
	if (Market::getInstance().acceptOffer(player, offerId, amount)) {
		std::vector<MarketOffer> offers = Market::getInstance().getActiveOffers(2);
		sendMarketOffers(offers);
	}
	
	std::cout << "[Market] Player " << player->getName() << " buying offer " << offerId << std::endl;
}

void ProtocolGame::parseMarketSell(NetworkMessage& msg)
{
	if (!player) {
		return;
	}

	uint16_t itemId = msg.get<uint16_t>();
	uint16_t amount = msg.get<uint16_t>();
	uint32_t price = msg.get<uint32_t>();
	
	if (Market::getInstance().createOffer(player, itemId, amount, price, MARKET_ACTION_SELL)) {
		std::vector<MarketOffer> offers = Market::getInstance().getActiveOffers(2);
		sendMarketOffers(offers);
	}
	
	std::cout << "[Market] Player " << player->getName() << " creating SELL offer" << std::endl;
}

void ProtocolGame::parseMarketCancel(NetworkMessage& msg)
{
	if (!player) {
		return;
	}

	uint32_t offerId = msg.get<uint32_t>();
	
	if (Market::getInstance().cancelOffer(player, offerId)) {
		std::vector<MarketOffer> offers = Market::getInstance().getPlayerOffers(player->getGUID());
		sendMarketOffers(offers);
	}
	
	std::cout << "[Market] Player " << player->getName() << " cancelling offer " << offerId << std::endl;
}

void ProtocolGame::parseMarketMyOffers(NetworkMessage& msg)
{
	if (!player) {
		return;
	}

	std::vector<MarketOffer> offers = Market::getInstance().getPlayerOffers(player->getGUID());
	sendMarketOffers(offers);
	
	std::cout << "[Market] Player " << player->getName() << " viewing own offers" << std::endl;
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



