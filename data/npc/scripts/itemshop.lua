local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

-- Categoria keywords
keywordHandler:addKeyword({'axes'}, StdModule.say, {npcHandler = npcHandler, text = 'I am selling: Orcish Axe, Dwarven Axe, Knight Axe, Beastslayer Axe, Fire Axe, Stonecutter Axe, Great Axe (2H).'})
keywordHandler:addKeyword({'swords'}, StdModule.say, {npcHandler = npcHandler, text = 'I am selling: Longsword, Scimitar, Serpent Sword, Spike Sword, Templar Scytheblade, Fire Sword, Bright Sword, Djinn Blade, Pharaoh Sword, Magic Sword.'})
keywordHandler:addKeyword({'shields'}, StdModule.say, {npcHandler = npcHandler, text = 'I am selling: Dwarven Shield, Tusk Shield, Beholder Shield, Griffin Shield, Guardian Shield, Dragon Shield, Tower Shield, Crown Shield, Medusa Shield, Vampire Shield, Demon Shield, Tempest Shield, Mastermind Shield, Great Shield, Blessed Shield.'})
keywordHandler:addKeyword({'helmets'}, StdModule.say, {npcHandler = npcHandler, text = 'I am selling: Steel Helmet, Devil Helmet, Crown Helmet, Warrior Helmet, Royal Helmet, Demon Helmet, Winged Helmet, Helmet of the Ancients, Golden Helmet.'})
keywordHandler:addKeyword({'armors'}, StdModule.say, {npcHandler = npcHandler, text = 'I am selling: Brass Armor, Scale Armor, Leopard Armor, Plate Armor, Noble Armor, Blue Robe, Knight Armor, Amazon Armor, Crown Armor, Golden Armor, Dragon Scale Mail, Demon Armor, Magic Plate Armor.'})
keywordHandler:addKeyword({'legs'}, StdModule.say, {npcHandler = npcHandler, text = 'I am selling: Brass Legs, Plate Legs, Knight Legs, Crown Legs, Golden Legs, Demon Legs, Dragon Scale Legs.'})
keywordHandler:addKeyword({'boots'}, StdModule.say, {npcHandler = npcHandler, text = 'I am selling: Crocodile Boots, Boots of Haste, Steel Boots, Golden Boots.'})
keywordHandler:addKeyword({'amulets'}, StdModule.say, {npcHandler = npcHandler, text = 'I am selling: Scarf, Platinum Amulet, Amulet of Loss.'})

npcHandler:addModule(FocusModule:new())

