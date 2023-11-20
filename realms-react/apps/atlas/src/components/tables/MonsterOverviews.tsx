import { Tooltip } from '@bibliotheca-dao/ui-lib/base/utility';
import React, { createRef, useEffect, useRef, useState } from 'react';
import { a } from 'react-spring';
import type { MonsterFragmentFragment } from '@/generated/graphql';
import { soundSelector, useUiSounds } from '@/hooks/useUiSounds';
import { MonsterCard } from '../cards/monsters/MonsterCard';

interface MonsterOverviewsProps {
  monsters: MonsterFragmentFragment[];
  isYourMonsters?: boolean;
}

export function MonsterOverviews(props: MonsterOverviewsProps) {
  const { play } = useUiSounds(soundSelector.pageTurn);
  const filteredMonsters = props.monsters.filter((a: any) => a.hp > 0);

  const cardRefs = useRef<any>([]);

  useEffect(() => {
    // add or remove refs
    cardRefs.current = Array(filteredMonsters.length)
      .fill({})
      .map((_, i) => cardRefs.current[i] || createRef());
  }, [filteredMonsters]);

  const tabs = [];

  return (
    <div>
      <div className="flex justify-center w-full mt-4">
        {tabs.map((tab, index) => (
          <Tooltip
            key={index}
            placement="top"
            className="ml-3 text-xs"
            tooltipText={<span className="text-sm">{tabNames[index]}</span>}
          >
            <button
              className="ml-4"
              onClick={() => {
                play();
                cardRefs.current?.forEach((el) => {
                  el.selectTab(index);
                });
              }}
            >
              {tab}
            </button>
          </Tooltip>
        ))}
      </div>
      <div className="grid gap-6 p-4 sm:p-6 md:grid-cols-3 ">
        {props.monsters &&
          filteredMonsters.map((monster: MonsterFragmentFragment, index) => (
            <MonsterCard
              loading={false}
              ref={(el) => (cardRefs.current[index] = el)}
              key={monster.monsterId}
              monster={monster}
            />
          ))}
      </div>
    </div>
  );
}
