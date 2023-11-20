%lang starknet

// Constants used in monster rampage module

// Determine percentage of HP reduction
namespace HP_REDUCTION {
    const BY_RARITY_LOSE = 60;
    const BY_DEFENCE_LOSE = 60;

    const BY_RARITY_WIN = 30;
    const BY_DEFENCE_WIN = 30;
}

// Attack is multiplied with a range from 450% to 550%
namespace ATTACK_LUCK_RANGE_MULTIPLIER {
    const FROM = 450;
    const TO = 550;
}

// HP is reduced with a range from 0 to 10
namespace DEFENCE_LUCK_HP_REDUCTION_MODIFIER {
     const FROM = 0;
    const TO = 10;
}

// Determine monster XP gained
namespace MONSTER_XP {
    const ATTACKING_MONSTER_WIN_XP = 200;
    const ATTACKING_MONSTER_LOSE_XP = 0;
}


