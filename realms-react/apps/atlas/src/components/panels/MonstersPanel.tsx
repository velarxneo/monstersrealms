import {
  Button,
  Card,
  CardBody,
  CardTitle,
  CardStats,
  ResourceIcon,
  Tabs,
} from '@bibliotheca-dao/ui-lib';

import Ouroboros from '@bibliotheca-dao/ui-lib/icons/ouroboros.svg';
import { useStarknet } from '@starknet-react/core';
import { BigNumber } from 'ethers';
import { useRouter } from 'next/router';
import { useEffect, useMemo, useState } from 'react';

import { MonstersFilter } from '@/components/filters/MonstersFilter';
import { MonsterOverviews } from '@/components/tables/MonsterOverviews';
import { useMonsterContext } from '@/context/MonsterContext';
import { useGetMonstersQuery } from '@/generated/graphql';
import useMonster from '@/hooks/settling/useMonsters';
import { useWalletContext } from '@/hooks/useWalletContext';
import { SearchFilter } from '../filters/SearchFilter';
import { BasePanel } from './BasePanel';

const TABS = [
  { key: 'Your', name: 'Your Monsters' },
  { key: 'All', name: 'All Monsters' },
  { key: 'Favourite', name: 'Favourite Monsters' },
];

function useMonstersQueryVariables(
  selectedTabIndex: number,
  page: number,
  limit: number
) {
  const { account } = useWalletContext();
  const { account: starkAccount } = useStarknet();

  const { state } = useMonsterContext();
  const starknetWallet = starkAccount
    ? BigNumber.from(starkAccount).toHexString()
    : '';
  return useMemo(() => {
    const filter = {} as any;
    const orderBy = {} as any;

    if (state.searchIdFilter) {
      filter.monsterId = { equals: parseInt(state.searchIdFilter) };
    } else {
      // Your monsters
      if (selectedTabIndex === 0) {
        filter.OR = [{ owner: { equals: starknetWallet } }];
      } else if (selectedTabIndex === 2) {
        filter.monsterId = { in: [...state.favouriteMonsters] };
      }
    }

    return {
      filter,
      take: limit,
      orderBy,
      skip: limit * (page - 1),
    };
  }, [account, state.searchIdFilter, page, selectedTabIndex, starknetWallet]);
}

function useMonstersPanelPagination() {
  const limit = 20;
  const [page, setPage] = useState(1);
  const goBack = () => setPage(page - 1);
  const goForward = () => setPage(page + 1);

  return {
    page,
    setPage,
    limit,
    goBack,
    goForward,
  };
}

function useMonstersPanelTabs() {
  const router = useRouter();
  const selectedTabKey = (router.query['tab'] as string) ?? TABS[1].key;
  const selectedTabIndex = TABS.findIndex(
    ({ key }) => key.toLowerCase() === selectedTabKey.toLowerCase()
  );

  function onTabChange(index: number) {
    router.push(
      {
        pathname: router.pathname,
        query: {
          ...router.query,
          tab: TABS[index].key,
        },
      },
      undefined,
      { shallow: true }
    );
  }

  return {
    selectedTabIndex,
    onTabChange,
  };
}

export const MonstersPanel = () => {
  const { state, actions } = useMonsterContext();
  const pagination = useMonstersPanelPagination();
  const { breed_monster } = useMonster();
  const { selectedTabIndex, onTabChange } = useMonstersPanelTabs();

  // Reset page on filter change. UseEffect doesn't do a deep compare
  useEffect(() => {
    pagination.setPage(1);
  }, [state.searchIdFilter, selectedTabIndex]);

  const variables = useMonstersQueryVariables(
    selectedTabIndex,
    pagination.page,
    pagination.limit
  );

  const { data, loading, startPolling, stopPolling } = useGetMonstersQuery({
    variables,
  });

  useEffect(() => {
    if (loading) stopPolling();
    else startPolling(5000);

    return stopPolling;
  }, [loading, data]);

  const showPagination = () =>
    selectedTabIndex === 1 &&
    (pagination.page > 1 ||
      (data?.getMonsters?.length ?? 0) === pagination.limit);

  const hasNoResults = () => !loading && (data?.getMonsters?.length ?? 0) === 0;

  return (
    <BasePanel open={true} style="lg:w-12/12 ">
      <div className="flex flex-wrap justify-between px-3 pt-16 sm:px-6">
        <h1>Monsters</h1>
        <div className="w-full my-1 sm:w-auto">
          <SearchFilter
            placeholder="SEARCH BY ID"
            onSubmit={(value) => {
              actions.updateSearchIdFilter(parseInt(value) ? value : '');
            }}
            defaultValue={state.searchIdFilter + ''}
          />
        </div>
      </div>
      <Tabs
        key={selectedTabIndex}
        selectedIndex={selectedTabIndex}
        onChange={onTabChange as any}
      >
        <Tabs.List>
          {TABS.map((tab) => (
            <Tabs.Tab key={tab.key}>{tab.name}</Tabs.Tab>
          ))}
        </Tabs.List>
      </Tabs>
      <div>
        {/* <MonstersFilter isYourMonsters={selectedTabIndex === 0} /> */}
        <Card className="col-span-12 sm:col-start-1 sm:col-end-4">
          <CardTitle>Quick Actions</CardTitle>
          <CardBody>
            <Button variant="primary" size="xs" onClick={() => breed_monster()}>
              Breed Monster
            </Button>
          </CardBody>
        </Card>

        {loading && (
          <div className="flex flex-col items-center w-20 gap-2 mx-auto my-40 animate-pulse">
            <Ouroboros className="block w-20 fill-current" />
            <h2>Loading</h2>
          </div>
        )}
        <MonsterOverviews
          key={selectedTabIndex}
          monsters={data?.getMonsters ?? []}
          isYourMonsters={selectedTabIndex === 0}
        />
      </div>

      {hasNoResults() && (
        <div className="flex flex-col items-center justify-center gap-8 py-8">
          <h2>No results... Try remove some filters</h2>
          <div className="flex gap-4">
            {selectedTabIndex !== 1 && (
              <Button
                className="whitespace-nowrap"
                variant="outline"
                onClick={() => onTabChange(1)}
              >
                See All Monsters
              </Button>
            )}
          </div>
        </div>
      )}

      {showPagination() && (
        <div className="flex justify-center w-full gap-2 py-8">
          <Button
            variant="outline"
            onClick={pagination.goBack}
            disabled={pagination.page === 1}
          >
            Previous
          </Button>
          <Button
            variant="outline"
            onClick={pagination.goForward}
            disabled={data?.getMonsters?.length !== pagination.limit}
          >
            Next
          </Button>
        </div>
      )}
    </BasePanel>
  );
};
