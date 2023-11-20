%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem, assert_lt, sqrt, assert_le
from contracts.settling_game.modules.combat.library import Combat, Army, Battalion, ArmyStatistics
from contracts.settling_game.modules.combat.constants import BattalionStatistics, BattalionIds
from contracts.settling_game.interfaces.ixoroshiro import IXoroshiro

const XOROSHIRO_ADDR = 0x06c4cab9afab0ce564c45e85fe9a7aa7e655a7e0fd53b7aea732814f3a64fbee;

@external
func test_final_hp{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    alloc_locals;
    let reduce_percent=60;
    let further_reduce_percent=60;

    let defence_luck=5;

    // Dragon
    // let base_hp=500;
    // let rarity=25;
    // let defence=50;
    
    // Kobold
    let base_hp=100;
    let rarity=1;
    let defence=10;

    // DeathKnight
    // let base_hp=20;
    // let rarity=1;
    // let defence=8;

    let defence_luck_multiplier=120;
   
    let (_, percent) = unsigned_div_rem(reduce_percent, 100);
    let (s, _) = unsigned_div_rem(reduce_percent, sqrt(rarity));
    let (hp_to_reduce, _) = unsigned_div_rem(base_hp*s, 100);

    let (_, percent) = unsigned_div_rem(further_reduce_percent, 100);
    let (s, _) = unsigned_div_rem(further_reduce_percent, sqrt(defence));
    let (hp_to_further_reduce, _) = unsigned_div_rem(base_hp*s, 100);
    let (defence_luck, _) = unsigned_div_rem(defence*defence_luck, 100);
    let hp_remaining = base_hp-hp_to_reduce-hp_to_further_reduce-defence_luck;
    
    assert_hp(hp_remaining);
    return ();
}



func assert_hp{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(hp: felt){
    alloc_locals;

    with_attr error_message("hp_remaining is {hp}" ) {
        assert_le(hp, 0);
    }
    return ();
}
