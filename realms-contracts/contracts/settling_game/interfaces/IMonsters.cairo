// Interface for Monsters ERC721 Implementation
// MIT License

%lang starknet

from starkware.cairo.common.uint256 import Uint256
from contracts.settling_game.utils.game_structs import MonsterData

@contract_interface
namespace IMonsters {
    func fetch_monster_data(token_id : Uint256) -> (monster_data : MonsterData) {
    }

    func set_monster_data_and_emit(monster_id : Uint256, monster_data : MonsterData) {
    }

    func get_base_hp(monster_class : felt) -> (base_hp : felt) {
    }
}





