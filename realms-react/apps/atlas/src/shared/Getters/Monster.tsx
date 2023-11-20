import { ResourceIcon } from '@bibliotheca-dao/ui-lib/base';
import { formatEther } from '@ethersproject/units';
import { useStarknet } from '@starknet-react/core';
import { ethers, BigNumber } from 'ethers';
import { DAY, MAX_DAYS_ACCURED, SECONDS_PER_KM } from '@/constants/buildings';
import { findResourceById } from '@/constants/resources';
// import MonstersData from '@/data/Monsters.json';
import type { MonsterFragmentFragment } from '@/generated/graphql';
import { useGameConstants } from '@/hooks/settling/useGameConstants';
import { useWalletContext } from '@/hooks/useWalletContext';
import type { BuildingDetail } from '@/types/index';
import { shortenAddress } from '@/util/formatters';

export const MonsterStatus = (Monster: MonsterFragmentFragment) => {
  return [MonsterStateStatus(Monster), MonsterVaultStatus(Monster)]
    .filter(Boolean)
    .join(', ');
};

export const MonsterOwner = (Monster: MonsterFragmentFragment) => {
  return Monster?.owner || '0';
};

export const IsOwner = (owner?: string | null) => {
  const { account } = useStarknet();
  const starknetWallet = account ? BigNumber.from(account).toHexString() : '';

  if (account) {
    return starknetWallet == owner ? true : false;
  } else {
    return false;
  }
};

export const getAccountHex = (account: string) => {
  return ethers.BigNumber.from(account).toHexString();
};

export const resourcePillaged = (resources: any) => {
  return (
    <div className="w-full my-4">
      {resources.length ? (
        resources?.map((resource, index) => {
          const info = findResourceById(resource.resourceId);
          return (
            <div
              className="flex justify-between my-1 font-display "
              key={index}
            >
              <div className="flex">
                <ResourceIcon
                  size="sm"
                  className="self-center"
                  resource={info?.trait?.replace('_', '') as string}
                />{' '}
                <span className="self-center ml-4 font-semibold tracking-widest uppercase">
                  {info?.trait}
                </span>
              </div>

              <div className="self-center font-semibold uppercase">
                {(+formatEther(resource.amount)).toLocaleString()}
              </div>
            </div>
          );
        })
      ) : (
        <span>No Resources pillaged</span>
      )}
    </div>
  );
};

export const isYourMonster = (
  Monster: MonsterFragmentFragment,
  account: string,
  starkAccount: string
) =>
  starkAccount &&
  starkAccount.toLowerCase().substring(starkAccount.length - 63) ===
    Monster.owner?.toLowerCase().substring(Monster.owner?.length - 63);

export const isFavourite = (
  Monster: MonsterFragmentFragment,
  favouriteMonsters: number[]
) => favouriteMonsters.indexOf(Monster.monsterId) > -1;
