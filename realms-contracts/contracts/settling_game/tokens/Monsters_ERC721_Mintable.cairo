// Monsters ERC721 Implementation

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.2.0 (token/erc721_enumerable/ERC721_Enumerable_Mintable_Burnable.cairo)

%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.uint256 import Uint256, uint256_check, uint256_add
from starkware.starknet.common.syscalls import get_caller_address
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.access.ownable.library import Ownable
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero, assert_nn, split_felt, assert_lt_felt

from openzeppelin.upgrades.library import Proxy
from contracts.utils.ShortString import uint256_to_ss
from contracts.utils.Array import concat_arr
from contracts.settling_game.interfaces.ixoroshiro import IXoroshiro

from contracts.settling_game.utils.general import unpack_data
from contracts.settling_game.utils.game_structs import (
    MonsterData, 
    MonsterBaseHP, 
    MonsterBaseAtt, 
    MonsterBaseDef, 
    MonsterRarity, 
    MonsterName,
)

namespace SHIFT_MONSTER{
    const _1 = 2 ** 0;
    const _2 = 2 ** 13;
    const _3 = 2 ** 18;
    const _4 = 2 ** 24;
    const _5 = 2 ** 31;
    const _6 = 2 ** 71;
    const _7 = 2 ** 101;
    const _8 = 2 ** 117;
}

const XOROSHIRO_ADDR = 0x06c4cab9afab0ce564c45e85fe9a7aa7e655a7e0fd53b7aea732814f3a64fbee;

@storage_var
func last_token_id() -> (token_id : Uint256){
}

@storage_var
func monsters_stats(token_id : Uint256) -> (packed_monster_stats : felt){
}

@storage_var
func monsters_name(token_id : Uint256) -> (monsterName : felt){
}


@storage_var
func is_breeder(breeder_address : felt) -> (is_breeder : felt){
}

@storage_var
func ERC721_base_token_uri(index: felt) -> (res: felt){
}

@storage_var
func ERC721_base_token_uri_len() -> (res: felt){
}


@storage_var
func ERC721_base_token_uri_suffix() -> (res: felt){
}

@storage_var
func ERC721_base_token_img_uri(index: felt) -> (res: felt){
}

@storage_var
func ERC721_base_token_img_uri_len() -> (res: felt){
}

@event
func TransferMonster(
    token_id : felt, realmId : felt, name : felt, monster_class : felt, rarity : felt, level : felt, xp : felt, hp : felt, attack_power : felt, defence_power : felt, sender_address : felt, base_token_img_uri_len : felt, base_token_img_uri : felt*
){
}

@event
func UpdateMonsterAfterRampage(
    token_id : Uint256, hp : felt, xp : felt
){
}


//
// Initializer
//

@external
func initializer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    name : felt, symbol : felt, owner : felt
){

    ERC721_base_token_uri_suffix.write(199354445678);

    ERC721_base_token_uri_len.write(2);
    ERC721_base_token_uri.write(2, 184555836485905370452258380672363647229256822713556100469228050863350768993);
    ERC721_base_token_uri.write(1, 139249848909153033455301423);

    ERC721_base_token_img_uri_len.write(2);
    ERC721_base_token_img_uri.write(2, 184555836485905370452258380672363647229256822713556100469228050863350768993);
    ERC721_base_token_img_uri.write(1, 139249848909153033455301423);


    ERC721.initializer(name, symbol);
    Ownable.initializer(owner);
    token_id_initializer();
    
    return ();
}

//
// Getters
//

@view
func totalSupply{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    totalSupply: Uint256
) {
    let (totalSupply: Uint256) = ERC721Enumerable.total_supply();
    return (totalSupply,);
}

@view
func tokenByIndex{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    index : Uint256
) -> (tokenId : Uint256){
    let (tokenId : Uint256) = ERC721Enumerable.token_by_index(index);
    return (tokenId,);
}

@view
func tokenOfOwnerByIndex{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    owner : felt, index : Uint256
) -> (tokenId : Uint256){
    let (tokenId : Uint256) = ERC721Enumerable.token_of_owner_by_index(owner, index);
    return (tokenId,);
}

@view
func supportsInterface{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    interfaceId : felt
) -> (success : felt){
    let (success) = ERC165.supports_interface(interfaceId);
    return (success,);
}

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt){
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt){
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt) -> (
    balance : Uint256
){
    let (balance : Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    tokenId : Uint256
) -> (owner : felt){
    let (owner : felt) = ERC721.owner_of(tokenId);
    return (owner,);
}

@view
func getApproved{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    tokenId : Uint256
) -> (approved : felt){
    let (approved : felt) = ERC721.get_approved(tokenId);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, operator : felt
) -> (isApproved : felt){
    let (isApproved : felt) = ERC721.is_approved_for_all(owner, operator);
    return (isApproved,);
}

func ERC721_Metadata_tokenURI{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (token_uri_len : felt, token_uri : felt*){
    alloc_locals;


    let (local base_token_uri) = alloc();
    let (local base_token_uri_len) = ERC721_base_token_uri_len.read();

    _ERC721_Metadata_baseTokenURI(base_token_uri_len, base_token_uri);

    let (token_id_ss_len, token_id_ss) = uint256_to_ss(token_id);
    let (token_uri_temp, token_uri_len_temp) = concat_arr(
        base_token_uri_len, base_token_uri, token_id_ss_len, token_id_ss
    );
    let (ERC721_base_token_uri_suffix_local) = ERC721_base_token_uri_suffix.read();
    let (local suffix) = alloc();
    [suffix] = ERC721_base_token_uri_suffix_local;
    let (token_uri, token_uri_len) = concat_arr(token_uri_len_temp, token_uri_temp, 1, suffix);

    return (token_uri_len=token_uri_len, token_uri=token_uri);
}

@view
func owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (owner : felt){
    let (owner : felt) = Ownable.owner();
    return (owner,);
}


@view
func get_monster_info{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (monster_data : felt){
    let (monster_data) = monsters_stats.read(token_id);
    return (monster_data,);
}

@view
func fetch_monster_data{

    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
    token_id : Uint256
) -> (monster_data : MonsterData){

    alloc_locals;        

    with_attr error_message("ERC721: token_id is not a valid Uint256"){
        uint256_check(token_id);
    }
    
    let (packed_monster_stats) = monsters_stats.read(token_id);    
    let (name) = monsters_name.read(token_id);
    let (realmId) = unpack_data(packed_monster_stats, 0, 8191);
    let (monster_class) = unpack_data(packed_monster_stats, 13, 31);
    let (rarity) = unpack_data(packed_monster_stats, 18, 63);
    let (level) = unpack_data(packed_monster_stats, 24, 127);
    let (xp) = unpack_data(packed_monster_stats, 31, 1099511627775);
    let (hp) = unpack_data(packed_monster_stats, 71, 1073741823);
    let (attack_power) = unpack_data(packed_monster_stats, 101, 65535);
    let (defence_power) = unpack_data(packed_monster_stats, 117, 65535);

    // with_attr error_message("monster unpacked = {realmId}" ) {
    //     assert 1=0;
    // }
    let monster = MonsterData(
        realmId=realmId,
        name=name,
        monster_class=monster_class,
        rarity=rarity,
        level=level,
        xp=xp,
        hp=hp,
        attack_power=attack_power,
        defence_power=defence_power,
    );

    return (monster_data=monster,);
}

@view
func get_is_breeder{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (is_true : felt){
    with_attr error_message("ERC721: the zero address can't be a breeder"){
        assert_not_zero(address);
    }
    let (is_true : felt) = is_breeder.read(address);
    return (is_true,);
}


//
// Externals
//

@external
func approve{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    to : felt, tokenId : Uint256
){
    ERC721.approve(to, tokenId);
    return ();
}

@external
func setApprovalForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    operator : felt, approved : felt
){
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (token_uri_len: felt, token_uri: felt*) {
    let (token_uri_len, token_uri) = ERC721_Metadata_tokenURI(token_id);
    return (token_uri_len=token_uri_len, token_uri=token_uri);
}

@view
func tokenImageURI{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (token_img_uri_len : felt, token_img_uri : felt*){
    alloc_locals;
    let (local base_token_img_uri) = alloc();
    let (local base_token_img_uri_len) = ERC721_base_token_img_uri_len.read();

    _ERC721_Metadata_baseTokenImgURI(base_token_img_uri_len, base_token_img_uri);

    return (token_img_uri_len=base_token_img_uri_len, token_img_uri=base_token_img_uri);
}

// @notice Gets base hp value
// @param monster_class: Monster Class ID
// @ returns base hp value
@view
func get_base_hp{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    monster_class: felt
) -> (hp: felt) {
    alloc_locals;

    let (type_label) = get_label_location(monster_base_hp);

    return ([type_label + monster_class - 1],);

    monster_base_hp:
    dw MonsterBaseHP.Kobold;
    dw MonsterBaseHP.Troll;
    dw MonsterBaseHP.Golem;
    dw MonsterBaseHP.Griffin;
    dw MonsterBaseHP.DeathKnight;
    dw MonsterBaseHP.Skeleton;
    dw MonsterBaseHP.Dragon;
    dw MonsterBaseHP.Arachnid;
    dw MonsterBaseHP.Phoenix;
}

@external
func transferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    from_ : felt, to : felt, tokenId : Uint256
){
    ERC721.transfer_from(from_, to, tokenId);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    from_ : felt, to : felt, tokenId : Uint256, data_len : felt, data : felt*
){
    ERC721.safe_transfer_from(from_, to, tokenId, data_len, data);
    return ();
}

@external
func mint{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    to : felt, tokenId : Uint256
){
    Ownable.assert_only_owner();
    ERC721._mint(to, tokenId);
    return ();
}

@external
func burn{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    tokenId : Uint256
){
    ERC721.assert_only_token_owner(tokenId);
    ERC721._burn(tokenId);
    return ();
}

@external
func declare_dead_monster{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    token_id : Uint256
){
    ERC721.assert_only_token_owner(token_id);
    ERC721._burn(token_id);
    return ();
}

@external
func setTokenURI{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    tokenId : Uint256, tokenURI : felt
){
    Ownable.assert_only_owner();
    ERC721._set_token_uri(tokenId, tokenURI);
    return ();
}

@external
func transferOwnership{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    newOwner : felt
){
    Ownable.transfer_ownership(newOwner);
    return ();
}

@external
func renounceOwnership{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(){
    Ownable.renounce_ownership();
    return ();
}


@external
func breed_monster{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (){
    alloc_locals;
    //assert_only_breeder()
    // Increment token id by 1
    let current_token_id : Uint256 = last_token_id.read();
    let one_as_uint256 = Uint256(1, 0);
    let (local new_token_id, _) = uint256_add(current_token_id, one_as_uint256);
 
    let (sender_address) = get_caller_address();
 
    tempvar MonsterBaseHPArr: felt* = new (MonsterBaseHP.Kobold, MonsterBaseHP.Troll, MonsterBaseHP.Golem, MonsterBaseHP.Griffin, MonsterBaseHP.DeathKnight, MonsterBaseHP.Skeleton, MonsterBaseHP.Dragon, MonsterBaseHP.Arachnid, MonsterBaseHP.Phoenix);
    tempvar MonsterBaseAttArr: felt* = new (MonsterBaseAtt.Kobold, MonsterBaseAtt.Troll, MonsterBaseAtt.Golem, MonsterBaseAtt.Griffin, MonsterBaseAtt.DeathKnight, MonsterBaseAtt.Skeleton, MonsterBaseAtt.Dragon, MonsterBaseAtt.Arachnid, MonsterBaseAtt.Phoenix);
    tempvar MonsterBaseDefArr: felt* = new (MonsterBaseDef.Kobold, MonsterBaseDef.Troll, MonsterBaseDef.Golem, MonsterBaseDef.Griffin, MonsterBaseDef.DeathKnight, MonsterBaseDef.Skeleton, MonsterBaseDef.Dragon, MonsterBaseDef.Arachnid, MonsterBaseDef.Phoenix);
    tempvar MonsterRarityArr: felt* = new (MonsterRarity.Kobold, MonsterRarity.Troll, MonsterRarity.Golem, MonsterRarity.Griffin, MonsterRarity.DeathKnight, MonsterRarity.Skeleton, MonsterRarity.Dragon, MonsterRarity.Arachnid, MonsterRarity.Phoenix);
    tempvar MonsterNameArr: felt* = new (MonsterName.Kobold, MonsterName.Troll, MonsterName.Golem, MonsterName.Griffin, MonsterName.DeathKnight, MonsterName.Skeleton, MonsterName.Dragon, MonsterName.Arachnid, MonsterName.Phoenix);


    // Mint NFT and store characteristics on-chain
    ERC721._mint(sender_address, new_token_id);

    let (dice_roll) = roll_dice(9);
    
    let (dice_roll_realms) = roll_dice(8000);
    

    let _name = MonsterNameArr[dice_roll-1];
    let _realmId = dice_roll_realms;
    let _monster_class = dice_roll;
    let _rarity = MonsterRarityArr[dice_roll-1];
    let _level = 1;
    let _xp = 0;
    let _hp = MonsterBaseHPArr[dice_roll-1];
    let _attack_power = MonsterBaseAttArr[dice_roll-1];
    let _defence_power = MonsterBaseDefArr[dice_roll-1];


    let name = _name;
    let realmId = _realmId * SHIFT_MONSTER._1; // 13
    let monster_class = _monster_class * SHIFT_MONSTER._2; // 5
    let rarity = _rarity * SHIFT_MONSTER._3;  // 4
    let level = _level * SHIFT_MONSTER._4;  // 7
    let xp = _xp * SHIFT_MONSTER._5;  // 40
    let hp = _hp * SHIFT_MONSTER._6; // 30
    let attack_power = _attack_power * SHIFT_MONSTER._7;  // 16
    let defence_power = _defence_power * SHIFT_MONSTER._8; // 16
    
    let packed_monster_stats = realmId + monster_class + rarity + level + xp + hp + attack_power + defence_power;

    monsters_stats.write(new_token_id, packed_monster_stats);
    monsters_name.write(new_token_id, name);
 
    let (local base_token_img_uri) = alloc();
    let (local base_token_img_uri_len) = ERC721_base_token_img_uri_len.read();

    _ERC721_Metadata_baseTokenImgURI(base_token_img_uri_len, base_token_img_uri);

    let (local felt_token_id: felt) = _uint_to_felt(new_token_id);

    TransferMonster.emit(felt_token_id, _realmId, _name, _monster_class, _rarity, _level, _xp, _hp, _attack_power, _defence_power, sender_address, base_token_img_uri_len, base_token_img_uri);

    // Update and return new token id
    last_token_id.write(new_token_id);

    return ();

}


func token_id_initializer{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(){
    let zero_as_uint256 : Uint256 = Uint256(0, 0);
    last_token_id.write(zero_as_uint256);
    return ();
}

@external
func add_breeder{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    breeder_address : felt
){
    Ownable.assert_only_owner();
    with_attr error_message("ERC721: the zero address can't be a breeder"){
        assert_not_zero(breeder_address);
    }
    is_breeder.write(breeder_address, 1);
    return ();
}

@external
func remove_breeder{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    breeder_address : felt
){
    Ownable.assert_only_owner();
    with_attr error_message("ERC721: the zero address can't be a breeder"){
        assert_not_zero(breeder_address);
    }
    is_breeder.write(breeder_address, 0);
    return ();
}

func assert_only_breeder{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(){
    let (sender_address) = get_caller_address();
    let (is_true) = is_breeder.read(sender_address);
    with_attr error_message("Caller is not a registered breeder"){
        assert is_true = 1;
    }
    return ();
}

func ERC721_Metadata_setBaseTokenURI{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(token_uri_len: felt, token_uri: felt*, token_uri_suffix: felt){
    _ERC721_Metadata_setBaseTokenURI(token_uri_len, token_uri);
    ERC721_base_token_uri_len.write(token_uri_len);
    ERC721_base_token_uri_suffix.write(token_uri_suffix);
    return ();
}

func _ERC721_Metadata_setBaseTokenURI{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(token_uri_len: felt, token_uri: felt*){
    assert_not_zero(token_uri_len);
    ERC721_base_token_uri.write(index=token_uri_len, value=[token_uri]);
    _ERC721_Metadata_setBaseTokenURI(token_uri_len=token_uri_len - 1, token_uri=token_uri + 1);
    return ();
}

func _ERC721_Metadata_baseTokenURI{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(base_token_uri_len : felt, base_token_uri : felt*){
    if (base_token_uri_len == 0){
        return ();
    }
    let (base) = ERC721_base_token_uri.read(base_token_uri_len);
    assert [base_token_uri] = base;
    _ERC721_Metadata_baseTokenURI(
        base_token_uri_len=base_token_uri_len - 1, base_token_uri=base_token_uri + 1
    );
    return ();
}

func _ERC721_Metadata_baseTokenImgURI{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(base_token_img_uri_len : felt, base_token_img_uri : felt*){
    if (base_token_img_uri_len == 0){
        return ();
    }
    let (base) = ERC721_base_token_img_uri.read(base_token_img_uri_len);
    assert [base_token_img_uri] = base;
    _ERC721_Metadata_baseTokenImgURI(
        base_token_img_uri_len=base_token_img_uri_len - 1, base_token_img_uri=base_token_img_uri + 1
    );
    return ();
}

// @notice Perform a 9 sided dice roll
// @return Dice roll value, from 1 to 9 (inclusive)
func roll_dice{range_check_ptr, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*}(max_number : felt) -> (
    dice_roll : felt
){
    alloc_locals;
    let xoroshiro_address_ = XOROSHIRO_ADDR;
    let (rnd) = IXoroshiro.next(xoroshiro_address_);

  
    let (_, r) = unsigned_div_rem(rnd, max_number);
    return (r + 1,);  // values from 1 to 12 inclusive
}

func _uint_to_felt{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    value: Uint256
) -> (value: felt) {
    assert_lt_felt(value.high, 2 ** 123);
    return (value.high * (2 ** 128) + value.low,);
}

@external
func set_monster_data_and_emit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    monster_id : Uint256, monster_data : MonsterData
) -> () {

    let (packed_monster_data) = pack_monster_data(monster_data);
    monsters_stats.write(monster_id, packed_monster_data);
    UpdateMonsterAfterRampage.emit(monster_id, monster_data.hp, monster_data.xp);

    return ();
}

func pack_monster_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    monster_data : MonsterData
) -> (packed_monster_data: felt) {

    let name = monster_data.name;
    let realmId = monster_data.realmId * SHIFT_MONSTER._1; // 13
    let monster_class = monster_data.monster_class * SHIFT_MONSTER._2; // 5
    let rarity = monster_data.rarity * SHIFT_MONSTER._3;  // 4
    let level = monster_data.level * SHIFT_MONSTER._4;  // 7
    let xp = monster_data.xp * SHIFT_MONSTER._5;  // 40
    let hp = monster_data.hp * SHIFT_MONSTER._6; // 30
    let attack_power = monster_data.attack_power * SHIFT_MONSTER._7;  // 16
    let defence_power = monster_data.defence_power * SHIFT_MONSTER._8; // 16
    
    let packed_monster_data = realmId + monster_class + rarity + level + xp + hp + attack_power + defence_power;

    return (packed_monster_data,);
}



