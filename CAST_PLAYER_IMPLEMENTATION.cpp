// ADD THIS TO THE END OF player.cpp (before the last closing brace)
// Also add #include "cast.h" at the top

// Cast System Implementation
bool Player::startCast(const std::string& password)
{
	if (cast) {
		return false; // Already casting
	}
	
	cast = new Cast(this);
	return cast->startCast(password);
}

void Player::stopCast()
{
	if (!cast) {
		return;
	}
	
	cast->stopCast();
	delete cast;
	cast = nullptr;
}

bool Player::isCasting() const
{
	return cast != nullptr && cast->isCasting();
}

void Player::setCastPassword(const std::string& password)
{
	if (cast) {
		cast->setPassword(password);
	}
}

bool Player::castHasPassword() const
{
	return cast && cast->hasPassword();
}

void Player::banCastViewer(const std::string& viewerName)
{
	if (cast) {
		cast->banViewer(viewerName);
	}
}

void Player::unbanCastViewer(const std::string& viewerName)
{
	if (cast) {
		cast->unbanViewer(viewerName);
	}
}

std::vector<std::string> Player::getCastViewers() const
{
	std::vector<std::string> viewerNames;
	
	if (cast) {
		const auto& viewers = cast->getViewers();
		for (const auto& viewer : viewers) {
			viewerNames.push_back(viewer.name);
		}
	}
	
	return viewerNames;
}

// Also need to modify Player destructor to cleanup cast:
// In Player::~Player(), add before the last line:
//
// if (cast) {
//     stopCast();
// }


