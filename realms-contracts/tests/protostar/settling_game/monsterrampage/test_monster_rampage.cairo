%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem, assert_lt, sqrt, assert_le
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256

from contracts.settling_game.modules.monsterrampage.constants import (
    HP_REDUCTION,
    ATTACK_LUCK_RANGE_MULTIPLIER,
    DEFENCE_LUCK_HP_REDUCTION_MODIFIER,
)

@external
func test_remaining_hp{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    } () -> (remaining_hp : felt) {

         alloc_locals;
        let base_hp = 400;
        let rarity = 20;
        let defence = 40;
        let outcome = TRUE;

        //passed: debugger(outcome);

        let defence_luck=5;

        if (outcome == TRUE){
            let (hp_reduction) = hp_reduction_helper(HP_REDUCTION.BY_RARITY_WIN,base_hp,rarity) ;
            let (hp_further_reduction) = hp_reduction_helper(HP_REDUCTION.BY_DEFENCE_WIN,base_hp,defence) ;
            let final_hp = base_hp - hp_reduction - hp_further_reduction - defence_luck;
            debugger(final_hp);
            return (final_hp,);

        } else {
            let (hp_reduction) = hp_reduction_helper(HP_REDUCTION.BY_RARITY_LOSE,base_hp,rarity) ;
            let (hp_further_reduction) = hp_reduction_helper(HP_REDUCTION.BY_DEFENCE_LOSE,base_hp,defence) ;
            let final_hp = base_hp - hp_reduction - hp_further_reduction - defence_luck;
            debugger(final_hp);
            return (final_hp,);
        }
        
    }

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

//@notice to print out variable contents in error message
//@param variable: the contents to print
func debugger{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(variable: felt){
    alloc_locals;

    with_attr error_message("tester = {variable}" ) {
        assert 1 = 0;
    }
    return ();
}