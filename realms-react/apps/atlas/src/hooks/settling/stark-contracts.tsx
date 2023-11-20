import { useContract } from '@starknet-react/core';
import type { Abi } from 'starknet';

import Nexus from '@/abi/nexus/SingleSidedStaking.json';
import Splitter from '@/abi/nexus/Splitter.json';
import Combat from '@/abi/settling/Combat.json';
import Exchange from '@/abi/settling/Exchange_ERC20_1155.json';
import Food from '@/abi/settling/Food.json';
import Settling from '@/abi/settling/L01_Settling.json';
import Resources from '@/abi/settling/L02_Resources.json';
import Building from '@/abi/settling/L03_Building.json';
import Calculator from '@/abi/settling/L04_Calculator.json';
import Wonder from '@/abi/settling/L05_Wonders.json';
import Lords from '@/abi/settling/Lords_ERC20_Mintable.json';
import MonsterRampage from '@/abi/settling/MonsterRampage.json';
import Monster from '@/abi/settling/Monsters_ERC721_Mintable.json';
import Realms721 from '@/abi/settling/Realms_ERC721_Mintable.json';
import Relics from '@/abi/settling/Relics.json';
import Resources1155 from '@/abi/settling/Resources_ERC1155_Mintable_Burnable.json';
import Travel from '@/abi/settling/Travel.json';

// Note: Can use process.env | static definition if needed
// Lords: process.env.LORDS_ADDR | "0x..."
export const ModuleAddr = {
  Lords: '0x0448549cccff35dc6d5df90efceda3123e4cec9fa2faff21d392c4a92e95493c',
  // ResourceGame:
  //   '0x06f0e13b23b610534484e8347f78312af6c11cced04e34bd124956a915e5c881',
  ResourceGame:
    '0x0417eacd7261266fc4657eb1a5438d0707eaeb60cdd57b4614a732a59edf10b4',
  Realms: '0x076bb5a142fa1d9c5d3a46eefaec38cc32b44e093432b1eb46466ea124f848a5',
  StakedRealms:
    '0x0332b15b95e542c2fcf17d1f30f405e60709c909d899e7e31062f9b5b818b63b',
  // StakedRealms:
  //   '0x06ffb2c4405cf08ae90759e7d1b28b8d01428b00be6a4df2cc1a24fd492019c3',
  // Settling:
  //   '0x05f2ea9fb937374c83bda664515f87a8cb33c145afac81874dacd91d47ce8cf6',
  Settling:
    '0x073dfd2c2d442636a66cc9a10d32e31db91d0ba254d22ac196e928e13e01292f',
  Exchange:
    '0x015eba242880374267dc54900b7d569a964fcd8d251a2edfb66a4ec9a78eaedc',
  ResourcesToken:
    '0x07144f39e676656e81d482dc2cc9f68c98d768fe1beaad28438b43142cc9ff9e',
  Building:
    '0x07e6ef6eae7a6d03baaace2fe8b5747ed52fa6c7ae615f3e3bd3311ac98d139a',
  // Combat: '0x04d4e010850d0df3c6fd9672a72328514acc5e1285935104a29d215184903582',
  Combat: '0x04af3e03a060739e8801676470687ec93bb1c2d1814b1cd76733cf441ea8b5da',
  Wonder: '0x0096cae38dd01a1e381c9e57db09669298fa079cfdb45e1a429c4020a6515549',
  Nexus: '0x0259f9adda2c8a7e651d03472cb603ef2c69ae9a64fd3a553415d082ddbb3061',
  Splitter:
    '0x06a60b479e9fe080fd8e0a8c4965040a25e276889c2de0cf105c410d0ac81436',
  Food: '0x03a34ef38f402d6b66b681db7905edfc48676288a7b08cd79910737c45431093',
  Relics: '0x027d0dd8dbe02f8dec5ff64b873eb78993c520f7c6f10b95f86cb061857769d0',
  Calculator:
    '0x05a74143789f2b8d2a95234318d7072062e449d37f9e882af68af663f9078ef7',
  Travel: '0x05f273c4a45dab6e8112e2370bd84f58cfd2f1ff83752c2582241c0c0acba9be',
  Monster: '0x058bf65283a345d04299b2c04fdba55f6a83e1f598adc809940d1ff2fb2c579c',
  MonsterRampage:
    '0x00280a5b7755e1f8affb6c7454050760bffeab28f9a72af301360cf7a0772474',
};

/**
 * Load the Travel contract.
 * @returns The `Travel` contract or undefined.
 */
export function useTravelContract() {
  return useContract({
    abi: Travel as Abi,
    address: ModuleAddr.Travel,
  });
}

/**
 * Load the Calculator contract.
 * @returns The `Calculator` contract or undefined.
 */
export function useCalculatorContract() {
  return useContract({
    abi: Calculator as Abi,
    address: ModuleAddr.Calculator,
  });
}

/**
 * Load the Food contract.
 * @returns The `Food` contract or undefined.
 */
export function useFoodContract() {
  return useContract({
    abi: Food as Abi,
    address: ModuleAddr.Food,
  });
}

/**
 * Load the Relic contract.
 * @returns The `Relic` contract or undefined.
 */
export function useRelicContract() {
  return useContract({
    abi: Relics as Abi,
    address: ModuleAddr.Relics,
  });
}

/**
 * Load the Nexus contract.
 * @returns The `Settling` contract or undefined.
 */
export function useNexusContract() {
  return useContract({
    abi: Nexus as Abi,
    address: ModuleAddr.Nexus,
  });
}

/**
 * Load the Splitter contract.
 * @returns The `Settling` contract or undefined.
 */
export function useSplitterContract() {
  return useContract({
    abi: Splitter as Abi,
    address: ModuleAddr.Splitter,
  });
}
/**
 * Load the Realms Settling contract.
 * @returns The `Settling` contract or undefined.
 */
export function useSettlingContract() {
  return useContract({
    abi: Settling as Abi,
    address: ModuleAddr.Settling,
  });
}

/**
 * Load the Realms Resources contract.
 * @returns The `Resources` contract or undefined.
 */
export function useResourcesContract() {
  return useContract({
    abi: Resources as Abi,
    address: ModuleAddr.ResourceGame,
  });
}

/**
 * Load the Realms Buildings contract.
 * @returns The `Buildings` contract or undefined.
 */
export function useBuildingContract() {
  return useContract({
    abi: Building as Abi,
    address: ModuleAddr.Building,
  });
}

/**
 * Load the Realms Wonder contract.
 * @returns The `Wonder` contract or undefined.
 */
export function useWonderContract() {
  return useContract({
    abi: Wonder as Abi,
    address: ModuleAddr.Wonder,
  });
}

/**
 * Load the Realms Combat contract.
 * @returns The `Combat` contract or undefined.
 */
export function useCombatContract() {
  return useContract({
    abi: Combat as Abi,
    address: ModuleAddr.Combat,
  });
}

/**
 * Load the Realms Resources ERC1155 contract.
 * @returns The `Resources` contract or undefined.
 */
export function useResources1155Contract() {
  return useContract({
    abi: Resources1155 as Abi,
    address: ModuleAddr.ResourcesToken,
  });
}

/**
 * Load the Lords ERC20 contract.
 * @returns The `Resources` contract or undefined.
 */
export function useLordsContract() {
  return useContract({
    abi: Lords as Abi,
    address: ModuleAddr.Lords,
  });
}
/**
 * Load the Realms Resources ERC721 contract.
 * @returns The `Realms` contract or undefined.
 */
export function useRealms721Contract() {
  return useContract({
    abi: Realms721 as Abi,
    address: ModuleAddr.Realms,
  });
}

/**
 * Load the Exchange ERC20_1155 contract.
 * @returns The `Exchange` contract or undefined.
 */
export function useExchangeContract() {
  return useContract({
    abi: Exchange as Abi,
    address: ModuleAddr.Exchange,
  });
}

export function useMonsterContract() {
  return useContract({
    abi: Monster as Abi,
    address: ModuleAddr.Monster,
  });
}

export function useMonsterRampageContract() {
  return useContract({
    abi: MonsterRampage as Abi,
    address: ModuleAddr.MonsterRampage,
  });
}
