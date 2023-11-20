### SUBMISSION FOR MATCHBOXDAO HACKATHON on 09-OCT-2022

Background

We are proposing to build an expansion module named “Monsters” on Realms Eternum.


Features Completed
1. Monsters can be minted and it spawns randomly across the 8000 realms.    
2. Monster can attack the realm which it is spawned on and reduce the realms' raidable resources<br>
    2.1 Monster fights the defending army of the realm<br>
    2.2 Monster reduces its HP and increases its XP depending on the battle outcome<br>
    2.3 Monster is dead when HP reduces below zero<br>
3. All game state (Monsters' statistics) and game logic are on-chain
4. All game state changes are accompanied with Events being emited
5. View the demo video at https://youtu.be/GusnqytZNB8
6. Visit http://202.172.56.233:3000/ for the demo site

Additional learnings:
1. Implemented imageUrl as a long string for our Monsters' pictures
2. Modified random number generator method for a random value based on minimum and maximum parameters
3. Made use of protostar test (/realms-contracts/tests/protostar/settling_game/monsterrampage/test_monster_combat.cairo) 
    by returning the value of a variable instead of just an assert statement


Files added for various repositories:

Repository 1

realms-contracts<br>
├── contracts<br>
│   ├── settling_game<br>
│   │   ├── interfaces<br>
│   │   │   └── IMonsters.cairo   (interface contract to Monsters_ERC721_Mintable.cairo)<br>
│   │   ├── modules<br>
│   │   |   ├── monsterrampage<br>
│   │   │   |   └── constants.cairo         (constants used in Monster Rampage module)<br>
│   │   │   |   └── library.cairo           (library which contains the logic in Monster Rampage module)<br>
│   │   │   |   └── MonsterRampage.cairo    (contract for Monster Rampage module)<br>
│   │   ├── tokens<br>
│   │   │   └── Monsters_ERC721_Mintable.cairo  (contract which stores the game state for our Monsters statistics)<br>
├── tests<br>
│   ├── protostar<br>
│   │   ├── settling_game<br>
│   │   |   ├── monsterrampage<br>
│   │   │   |   └── test_monster_rampage.cairo  (test file used in Monster Rampage module)<br>
└── Monsters-README.txt                 (readme file detailing work done for this hackathon)<br>
└── Monsters-Contract-Interaction.pdf   (diagram showing the interaction between the various contracts)<br>


Repository 2

realms-react<br>
├── atlas<br>
│   ├── src<br>
│   │   ├── components<br>
│   │   |   ├── cards<br>
│   │   |   |   ├── monsters<br>
│   │   │   |   |   └── MonsterCard.tsx   (monster details showing its statistics)<br>
│   │   |   ├── filters<br>
│   │   │   |   └── MonstersFilter.tsx<br>
│   │   |   ├── panels<br>
│   │   |   |   ├── Monsters<br>
│   │   |   |   |   ├── details<br>
│   │   │   |   |   |   └── index.tsx<br>
│   │   │   |   |   |   └── Overview.tsx<br>
│   │   │   |   └── MonstersPanel.tsx<br>
│   │   |   ├── tables<br>
│   │   │   |   └── MonsterOverviews.tsx<br>
│   │   ├── constants<br>
│   │   |   └── monster.ts<br>
│   │   ├── context<br>
│   │   |   └── MonsterContext.tsx<br>
│   │   ├── graphql<br>
│   │   |   ├── Monster<br>
│   │   |   |    └── GetMonster.graphql<br>
│   │   |   |    └── GetMonsters.graphql<br>
│   │   |   |    └── Monster.fragment.graphql<br>
│   │   ├── hooks<br>
│   │   |   ├── settling<br>
│   │   |   |    └── useMonsterRampage.tsx<br>
│   │   |   |    └── useMonsters.tsx<br>
│   │   ├── pages<br>
│   │   |   ├── monster<br>
│   │   |   |    └── index.tsx<br>
│   │   ├── shared<br>
│   │   |   ├── Getters<br>
│   │   |   |    └── Monster.tsx<br>


Repository 3

starknet-indexer<br>
├── app<br>
│   ├── entities<br>
│   │   ├── settling<br>
│   │   │   └── Monsters.ts   (monster model)<br>
│   ├── indexer<br>
│   │   ├── settling<br>
│   │   │   └── MonsterIndexer.ts   (listener for all monster events and update graphql database)<br>
│   ├── resolver<br>
│   │   ├── settling<br>
│   │   │   └── MonsterResolver.ts  (populate the data for fields in the schema)<br>
│   │   ├── types<br>
│   │   |   ├── settling<br>
│   │   │   |   └── MonstersFilterInput.ts<br>
│   │   │   |   └── MonsterInputs.ts<br>
│   │   │   |   └── MonsterOrderByInput.ts<br>


Additional features which can be implemented:
1. Monsters have the ability to regenerate HP over time
2. Monsters able to move to adjacent realms to attack
3. Instead of user-controlled Monsters, we can introduce auto minting of Monsters and Monsters roam across the realms randomly based on radius to rampage resources
4. Monsters can be summoned (using VRGDA) and the monster is spawned only on opposing Orders to raid their resources
5. World Boss can be resurrected from the depths of Hell
    5.1 Armies and Adventurers band together to fight the World Boss regardless of which Order they belong to.
    5.2 Slayers of the World Boss will be bestowed an Ancient Relic.


Any questions please contact Aralekor#0010 or velarXneo#8711 in Discord.

Thank you.
