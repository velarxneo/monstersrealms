// -----------------------------------
//   Module.MonsterRampage
//   Logic around Monster Rampage system

// ELI5:
//   Monster Rampage revolves around Monster fighting Defending Army in a Realm.
//   Army ID 0 is reserved for your defending Army, and it cannot move.
//   Both Monster and Defending Army must exist at the same realm in order to battle.
//   Monsters gain XP and reduce Realm's resources if rampaged successfully.
//   Outcome of battle is based on (Monster's Attack Power * 450% to 550%) vs Defending Army's Defence Statistics
//   If monster win the battle, reduce (30% divide by squareroot(monster's rarity)) of base HP,
//      and further reduce (30% divide by squareroot(monster's defence)) of base HP,
//      and further reduce (a random number from 0 to 10) of HP.
//   If monster lose the battle, reduce (60% divide by squareroot(monster's rarity)) of base HP,
//      and further reduce (60% divide by squareroot(monster's defence)) of base HP,
//      and further reduce (a random number from 0 to 10) of HP.
//   Monster dies and loses the battle if HP drops to 0.

// MIT License
// -----------------------------------

%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_lt, sqrt, assert_lt_felt, assert_nn
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.starknet.common.syscalls import get_block_timestamp
from openzeppelin.upgrades.library import Proxy
from contracts.settling_game.library.library_module import Module
from contracts.settling_game.modules.combat.library import Combat
from contracts.settling_game.modules.monsterrampage.library import MonsterRampage

from contracts.settling_game.modules.resources.interface import IResources
from contracts.settling_game.modules.Combat.interface import ICombat
from contracts.settling_game.interfaces.ixoroshiro import IXoroshiro
from contracts.settling_game.interfaces.IMonsters import IMonsters

from contracts.settling_game.modules.monsterrampage.constants import (
    HP_REDUCTION,
    ATTACK_LUCK_RANGE_MULTIPLIER,
    DEFENCE_LUCK_HP_REDUCTION_MODIFIER,
    MONSTER_XP,
)

from contracts.settling_game.utils.constants import (
    DEFENDING_ARMY_XP,
    ATTACKING_ARMY_XP,
)

from contracts.settling_game.utils.game_structs import (
    MonsterData,
    Army,
    ArmyData,
)

// hardcoded module address to simplify testing
const monsters_address = 2508856039100541254009953359129988050649979317977035860356928697654489929628;
const combat_address = 2118877636712268396913981595473669875214988212675356303776187676728991725018;
const resources_address = 1851509424302750651831290418607886736742679099696595787479661613337928470708;

// -----------------------------------
// Events
// -----------------------------------


//event emitted after rampage started
@event
func RampageStart(
    attacking_monster_id: Uint256,
    defending_army_id: felt,
    defending_realm_id: Uint256,
    defending_army: Army,
) {
}

//event emitted after rampage ended
@event
func RampageEnd(
    combat_outcome: felt,
    attacking_monster_id: Uint256,
    defending_army_id: felt,
    defending_realm_id: Uint256,
    defending_army: Army,
) {
}



// -----------------------------------
// Storage
// -----------------------------------

@storage_var
func xoroshiro_address() -> (address: felt) {
}

@storage_var
func ending_monster_data() -> (monsterData: MonsterData) {
}

// -----------------------------------
// Initialize & upgrade
// -----------------------------------

// @notice Module initializer
// @param address_of_controller: Controller/arbiter address
// @proxy_admin: Proxy admin address
@external
func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address_of_controller: felt, proxy_admin: felt
) {
    Module.initializer(address_of_controller);
    Proxy.initializer(proxy_admin);
    return ();
}

// @notice Set new proxy implementation
// @dev Can only be set by the arbiter
// @param new_implementation: New implementation contract address
@external
func upgrade{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    new_implementation: felt
) {
    Proxy.assert_only_admin();
    Proxy._set_implementation_hash(new_implementation);
    return ();
}


// -----------------------------------
// External
// -----------------------------------

// @notice initiate monster rampage
// @param attacking_monster_id: monster id
// @param attacking_monster_realm_id: settled realm id (S_Realm)
// @param defending_army_id: defending army id
// @param defending_realm_id: defending realm id (S_Realm)
// @return: combat_outcome: TRUE if monster win, FALSE if lose
@external
func initiate_rampage{
    range_check_ptr, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*
}(
    attacking_monster_id: Uint256,
    attacking_monster_realm_id: Uint256,
    defending_army_id: felt,
    defending_realm_id: Uint256,
) -> (combat_outcome: felt) {
    alloc_locals;
    
    // Check monster and army in same realm
    with_attr error_message("Rampage: Monster and Army not in same Realm") {
        let (is_equal) = uint256_eq(attacking_monster_realm_id, defending_realm_id);
        assert is_equal = TRUE;
    }

    //Fetch monster data
    let (starting_monster_data: MonsterData) = IMonsters.fetch_monster_data(
        contract_address=monsters_address, token_id=attacking_monster_id);

    // Check monster is alive (HP more than 0)
    with_attr error_message("Rampage: Monster is dead") {
        assert_nn(starting_monster_data.hp - 1);
    }

    let (defending_realm_data: ArmyData) = ICombat.get_realm_army_combat_data(
        contract_address=combat_address, army_id=defending_army_id, realm_id=defending_realm_id
    );

    // unpack starting defending army
    let (starting_defending_army: Army) = Combat.unpack_army(defending_realm_data.ArmyPacked);

    // emit Rampage Start event
    RampageStart.emit(
        attacking_monster_id,
        defending_army_id,
        defending_realm_id,
        starting_defending_army,
    );

    // Calculate winner
    let (combat_outcome, ending_defending_army_packed
    ) = MonsterRampage.calculate_winner(
        starting_monster_data, 
        defending_realm_data.ArmyPacked
    );

    // unpack ending defending army
    let (ending_defending_army: Army) = Combat.unpack_army(ending_defending_army_packed);

    let (now) = get_block_timestamp();
    
    // rampage only if monster wins
    if (combat_outcome == TRUE) {
        
        // Monster Win - Reduce defending realm resource
        IResources.rampage_resources(resources_address, defending_realm_id);
        
        //Monster Win - calculate monster remaining hp         
        let (base_hp) = IMonsters.get_base_hp(monsters_address, starting_monster_data.monster_class);                
        let (remaining_hp) = MonsterRampage.calculate_remaining_hp(base_hp, 
                                                                starting_monster_data, 
                                                                TRUE);
      
        let ending_monster_data = MonsterData(
            realmId=starting_monster_data.realmId,
            name=starting_monster_data.name,
            monster_class=starting_monster_data.monster_class,
            rarity=starting_monster_data.rarity,
            level=starting_monster_data.level,
            xp=starting_monster_data.xp + MONSTER_XP.ATTACKING_MONSTER_WIN_XP,
            hp=remaining_hp,
            attack_power=starting_monster_data.attack_power,
            defence_power=starting_monster_data.defence_power,
        );

        //update monster with reduced HP and added XP       
        set_monster_data_and_emit(attacking_monster_id, ending_monster_data);
    
        //store new army values with added XP
        let new_defending_army_xp = defending_realm_data.XP + DEFENDING_ARMY_XP;   //30
        
        //update army state
        set_army_data_and_emit(
            defending_army_id,
            defending_realm_id,
            ArmyData(ending_defending_army_packed, 
                    now, 
                    new_defending_army_xp, 
                    defending_realm_data.Level, 
                    defending_realm_data.CallSign),
        );

        //emit Rampage end event
        RampageEnd.emit(
            combat_outcome,
            attacking_monster_id,
            defending_army_id,
            defending_realm_id,
            ending_defending_army,
        );

        return (combat_outcome,);

    } else {

        //Monster Lost - calculate monster remaining hp
        let (base_hp) = IMonsters.get_base_hp(monsters_address, starting_monster_data.monster_class);
        let (remaining_hp) = MonsterRampage.calculate_remaining_hp(base_hp, 
                                                                starting_monster_data, 
                                                                FALSE);
                                                                
        let ending_monster_data = MonsterData(
            realmId=starting_monster_data.realmId,
            name=starting_monster_data.name,
            monster_class=starting_monster_data.monster_class,
            rarity=starting_monster_data.rarity,
            level=starting_monster_data.level,
            xp=starting_monster_data.xp + MONSTER_XP.ATTACKING_MONSTER_LOSE_XP,
            hp=remaining_hp,
            attack_power=starting_monster_data.attack_power,
            defence_power=starting_monster_data.defence_power,
        );

        //update monster with reduced HP and added XP       
        set_monster_data_and_emit(attacking_monster_id, ending_monster_data);
    
        //store new army values with added XP
        let new_defending_army_xp = defending_realm_data.XP + ATTACKING_ARMY_XP;   //100
        
        //update army state
        set_army_data_and_emit(
            defending_army_id,
            defending_realm_id,
            ArmyData(ending_defending_army_packed, 
                    now, 
                    new_defending_army_xp, 
                    defending_realm_data.Level, 
                    defending_realm_data.CallSign),
        );

        //emit Rampage end event
        RampageEnd.emit(
            combat_outcome,
            attacking_monster_id,
            defending_army_id,
            defending_realm_id,
            ending_defending_army,
        );

        return (combat_outcome,);
    }
    
}

// -----------------------------------
// Internal
// -----------------------------------


// @notice saves data and emits the changed metadata for cache
// @param army_id: Army ID
// @param realm_id: Realm ID
// @param army_data: Army metadata
func set_army_data_and_emit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    army_id: felt, realm_id: Uint256, army_data: ArmyData
) -> () {
    alloc_locals;

    ICombat.set_army_data_and_emit(
        combat_address, army_id, realm_id, army_data
    );
    return ();
}

// @notice update moster state
// @param monster_id: monster id
// @param monster_data: monster metadata
func set_monster_data_and_emit{
    range_check_ptr, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, bitwise_ptr: BitwiseBuiltin*}(
    monster_id: Uint256, monster_data: MonsterData
) -> () {
    alloc_locals;

    IMonsters.set_monster_data_and_emit(
        monsters_address, monster_id, monster_data
    );

    return ();
}

// -----------------------------------
// Getters
// -----------------------------------
