import { useEffect } from 'react';
import { toBN } from 'starknet/dist/utils/number';
import { bnToUint256 } from 'starknet/dist/utils/uint256';
import { useTransactionQueue } from '@/context/TransactionQueueContext';
import type { Realm } from '@/generated/graphql';
import { ModuleAddr } from '@/hooks/settling/stark-contracts';
import type { RealmsCall, RealmsTransactionRenderConfig } from '@/types/index';
import { uint256ToRawCalldata } from '@/util/rawCalldata';
import { useUiSounds, soundSelector } from '../useUiSounds';

export const Entrypoints = {
  breed_monster: 'breed_monster',
};

export const createMonsterCall: Record<string, (args: any) => RealmsCall> = {
  breed_monster: ({ monsterId }) => ({
    contractAddress: ModuleAddr.Monster,
    entrypoint: Entrypoints.breed_monster,
    metadata: { monsterId, action: Entrypoints.breed_monster },
  }),
};

export const renderTransaction: RealmsTransactionRenderConfig = {
  [Entrypoints.breed_monster]: (tx, ctx) => ({
    title: `${ctx.isQueued ? 'Breed' : 'Breeding'} Monster`,
    description: `Breeding monster`,
  }),
};

type Monster = {
  breed_monster: () => void;
  loading: boolean;
};

const useMonster = (): Monster => {
  const { play } = useUiSounds(soundSelector.claim);

  const txQueue = useTransactionQueue();

  return {
    breed_monster: () => {
      play();
      txQueue.add(createMonsterCall.breed_monster(2));
    },
    loading: false,
  };
};

export default useMonster;
