import {
  useStarknet,
  useStarknetInvoke,
  useStarknetCall,
} from '@starknet-react/core';
import { useState, useEffect } from 'react';
import { toBN } from 'starknet/dist/utils/number';
import { bnToUint256, uint256ToBN } from 'starknet/dist/utils/uint256';
import { useTransactionQueue } from '@/context/TransactionQueueContext';
import {
  ModuleAddr,
  useMonsterRampageContract,
} from '@/hooks/settling/stark-contracts';
import type { RealmsCall, RealmsTransactionRenderConfig } from '@/types/index';
import { uint256ToRawCalldata } from '@/util/rawCalldata';

type MonsterRampage = {
  initiate_rampage: (
    attacking_monster_id: number,
    attacking_monster_realm_id: number,
    defending_army_id: number,
    defending_realm_id: number
  ) => void;
};

export const Entrypoints = {
  initiate_rampage: 'initiate_rampage',
};

export const createMonsterRampageCall: Record<
  string,
  (args: any) => RealmsCall
> = {
  initiate_rampage: ({
    attacking_monster_id,
    attacking_monster_realm_id,
    defending_army_id,
    defending_realm_id,
  }) => ({
    contractAddress: ModuleAddr.MonsterRampage,
    entrypoint: Entrypoints.initiate_rampage,
    calldata: [
      ...uint256ToRawCalldata(bnToUint256(attacking_monster_id)),
      ...uint256ToRawCalldata(bnToUint256(attacking_monster_realm_id)),
      defending_army_id,
      ...uint256ToRawCalldata(bnToUint256(defending_realm_id)),
    ],
    metadata: {
      attacking_monster_id,
      attacking_monster_realm_id,
      defending_army_id,
      defending_realm_id,
      action: Entrypoints.initiate_rampage,
    },
  }),
};

export const renderTransaction: RealmsTransactionRenderConfig = {
  [Entrypoints.initiate_rampage]: (tx, ctx) => ({
    title: `${ctx.isQueued ? 'Rampage' : 'Rampaging'}`,
    description: `Monster Rampage`,
  }),
};

const useMonsterRampage = (): MonsterRampage => {
  const { contract: monsterRampageContract } = useMonsterRampageContract();
  const { account } = useStarknet();

  const txQueue = useTransactionQueue();

  return {
    initiate_rampage: (
      attacking_monster_id: number,
      attacking_monster_realm_id: number,
      defending_army_id: number,
      defending_realm_id: number
    ) => {
      txQueue.add(
        createMonsterRampageCall.initiate_rampage({
          attacking_monster_id: attacking_monster_id,
          attacking_monster_realm_id: attacking_monster_realm_id,
          defending_army_id: defending_army_id,
          defending_realm_id: defending_realm_id,
        })
      );
    },
  };
};

export default useMonsterRampage;
