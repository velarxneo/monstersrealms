// -----------------------------------
//   MonsterRampage Library
//   Library to help with the MonsterRampage mechanics.
//
// MIT License
// -----------------------------------

%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero, assert_lt, sqrt
from starkware.cairo.common.math_cmp import is_nn_le, is_nn, is_le
from starkware.cairo.lang.compiler.lib.registers import get_fp_and_pc
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.memset import memset
from contracts.settling_game.utils.general import unpack_data
from contracts.settling_game.interfaces.ixoroshiro import IXoroshiro
from contracts.settling_game.modules.combat.library import Combat

from contracts.settling_game.modules.combat.constants import (
    BattalionStatistics,
    SHIFT_ARMY,
    BattalionIds,
)

from contracts.settling_game.modules.monsterrampage.constants import (
    HP_REDUCTION,
    ATTACK_LUCK_RANGE_MULTIPLIER,
    DEFENCE_LUCK_HP_REDUCTION_MODIFIER,
)

from contracts.settling_game.utils.game_structs import (
    Battalion,
    Army,
    ArmyStatistics,
    MonsterData,
    MonsterBaseHP,
)

// hardcoded random number contract address to simplify testing
const XOROSHIRO_ADDR = 0x06c4cab9afab0ce564c45e85fe9a7aa7e655a7e0fd53b7aea732814f3a64fbee;

namespace MonsterRampage {   

    // @notice calculates the winner of monster rampage
    // @param monster_data: attacking monster's statistics
    // @param defending_army_packed: packed defending army
    // @return outcome: TRUE if monster win, FALSE if monster loses
    // @return defending_army_packed: packed defending army
    func calculate_winner{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr,
        bitwise_ptr: BitwiseBuiltin*,
    }(monster_data : MonsterData, defending_army_packed: felt) -> (
        outcome: felt, defending_army_packed : felt
    ) {
        alloc_locals;

        let monster_attack = monster_data.attack_power;
    
        let (defending_army_statistics: ArmyStatistics) = Combat.calculate_army_statistics(
            defending_army_packed
        );

        //multiply monster's attack power by 450% to 550% to battle against defending army' statistics
        let (luck) = roll_dice(ATTACK_LUCK_RANGE_MULTIPLIER.FROM, ATTACK_LUCK_RANGE_MULTIPLIER.TO);
        
        let (cavalry_outcome) = calculate_luck_outcome(
            luck, monster_attack, defending_army_statistics.CavalryDefence
        );
        let (archery_outcome) = calculate_luck_outcome(
            luck, monster_attack, defending_army_statistics.ArcheryDefence
        );
        let (magic_outcome) = calculate_luck_outcome(
            luck, monster_attack, defending_army_statistics.MagicDefence
        );
        let (infantry_outcome) = calculate_luck_outcome(
            luck, monster_attack, defending_army_statistics.InfantryDefence
        );

        //monster wins if multiplied monster's attack power is bigger than the sum of defending army's statistics
        let final_outcome = cavalry_outcome + archery_outcome + magic_outcome + infantry_outcome;

        let successful = is_nn(final_outcome);

        if (successful == TRUE) {
        
            return (TRUE, defending_army_packed);
        }

        return (FALSE, defending_army_packed);
    }

    // @notice calculates value after applying luck. All units use this.
    // @param attacking_statistics: Attacker statistics
    // @param defending_statistics: Defender statistics
    // @return luck outcome
    func calculate_luck_outcome{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        luck: felt, attacking_statistics: felt, defending_statistics: felt
    ) -> (outcome: felt) {
        alloc_locals;

        let (luck, _) = unsigned_div_rem(attacking_statistics * luck, 100);

        return (luck - defending_statistics,);
    }


    // @notice calculate monster's remaining HP
    //      If monster win the battle, reduce (30% of base hp divide by squareroot(monster's rarity))
    //          and further reduce (30% of base hp divide by squareroot(monster's defence))
    //          and further reduce (random number from 0 to 10)
    //      If monster lose the battle, reduce (60% of base hp divide by squareroot(monster's rarity))
    //          and further reduce (60% of base hp divide by squareroot(monster's defence))
    //          and further reduce (random number from 0 to 10)
    // @param base_hp: attacking monster's base HP based on monster class
    // @param monster_data: attacking monster's statistics
    // @param outcome: TRUE if monster win, FALSE if monster loses
    // @return remaining_hp: remaining hp of monster after the rampage
    func calculate_remaining_hp{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(base_hp : felt, monster_data : MonsterData, outcome : felt) -> (remaining_hp : felt){
        alloc_locals;     
       
        //HP is further reduced with a range from 0 to 10
        let (defence_luck)=roll_dice(DEFENCE_LUCK_HP_REDUCTION_MODIFIER.FROM, DEFENCE_LUCK_HP_REDUCTION_MODIFIER.TO);

        if (outcome == TRUE){
            //monster wins the rampage
            //reduce hp (30% of base hp divide by squareroot(monster's rarity))
            let (hp_reduction) = hp_reduction_helper(HP_REDUCTION.BY_RARITY_WIN, base_hp, monster_data.rarity) ;
            
            //further reduce hp (30% of base hp divide by squareroot(monster's defence))
            let (hp_further_reduction) = hp_reduction_helper(HP_REDUCTION.BY_DEFENCE_WIN, base_hp, monster_data.defence_power) ;
            
            //further reduce HP with a range from 0 to 10
            return (monster_data.hp - hp_reduction - hp_further_reduction - defence_luck,);

        } else {
            //monster loses the rampage
            //reduce hp (60% of base hp divide by squareroot(monster's rarity))
            let (hp_reduction) = hp_reduction_helper(HP_REDUCTION.BY_RARITY_LOSE, base_hp,  monster_data.rarity) ;
            
            //further reduce hp (60% of base hp divide by squareroot(monster's defence))
            let (hp_further_reduction) = hp_reduction_helper(HP_REDUCTION.BY_DEFENCE_LOSE, base_hp, monster_data.defence_power) ;             
            
            //further reduce HP with a range from 0 to 10
            return (monster_data.hp - hp_reduction - hp_further_reduction - defence_luck,);
        }
    }

    // @notice helper method to reduce hp
    // @param reduce_percent: percentage of reduction
    // @param base_hp: attacking monster's base hp
    // @param factor: reduction factor (e.g. based on rarity or defence power)
    // @return hp_reduction: hp to reduce
    func hp_reduction_helper{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(reduce_percent: felt, base_hp : felt, factor : felt)->(hp_reduction: felt){
        alloc_locals;

        let (_, percent) = unsigned_div_rem(reduce_percent, 100);
        let (reduce_based_on_factor, _) = unsigned_div_rem(reduce_percent, sqrt(factor));
        let (hp_to_reduce, _) = unsigned_div_rem(base_hp*reduce_based_on_factor, 100);

        return (hp_to_reduce,);
    }

    // @notice roll dice method to generate a random number based on a mininum and maximum value
    // @param dice_roll_from: minimum value
    // @param dice_roll_to: maximum value
    // @return result: random number
    func roll_dice{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(dice_roll_from : felt, dice_roll_to : felt) -> (result : felt) {
        alloc_locals;
        let xoroshiro_address_ = XOROSHIRO_ADDR;
        let (rnd) = IXoroshiro.next(xoroshiro_address_);
    
        let (_, r) = unsigned_div_rem(rnd, dice_roll_to-dice_roll_from);
        return (r + dice_roll_from,); 
    }
}
