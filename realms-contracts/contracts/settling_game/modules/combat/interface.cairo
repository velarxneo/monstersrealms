// Module Interfaces
// MIT License

%lang starknet

from starkware.cairo.common.uint256 import Uint256
from contracts.settling_game.utils.game_structs import RealmCombatData, Cost, Squad, ArmyData

// Added for monster rampage module interactions
@contract_interface
namespace ICombat {
    func set_army_data_and_emit(army_id: felt, realm_id: Uint256, army_data: ArmyData){
    }
    func get_realm_army_combat_data(army_id: felt, realm_id: Uint256)-> (army_data: ArmyData){
    }
}


@contract_interface
namespace IL06_Combat {
    func build_squad_from_troops_in_realm(
        troop_ids_len: felt, troop_ids: felt*, realm_id: Uint256, slot: felt
    ) {
    }
    func set_troop_cost(troop_id: felt, cost: Cost) {
    }
    func view_troops(realm_id: Uint256) -> (attacking_troops: Squad, defending_troops: Squad) {
    }
    func get_realm_combat_data(realm_id: Uint256) -> (combat_data: RealmCombatData) {
    }
    
}
