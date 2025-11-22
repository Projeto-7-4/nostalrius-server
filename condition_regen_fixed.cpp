bool ConditionRegeneration::executeCondition(Creature* creature, int32_t interval)
{
	internalHealthTicks += interval;
	internalManaTicks += interval;

	// MODIFICAÇÃO: Soft Boots regeneram SEMPRE (inclusive em PZ)
	if (internalHealthTicks >= healthTicks) {
		internalHealthTicks = 0;
		creature->changeHealth(healthGain);
	}

	if (internalManaTicks >= manaTicks) {
		internalManaTicks = 0;
		creature->changeMana(manaGain);
	}

	return ConditionGeneric::executeCondition(creature, interval);
}



