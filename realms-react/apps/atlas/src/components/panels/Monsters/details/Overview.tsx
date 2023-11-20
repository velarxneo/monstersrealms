import { ResourceIcon, Button, Menu } from '@bibliotheca-dao/ui-lib';

import { Transition } from '@headlessui/react';
import { useStarknet } from '@starknet-react/core';
import clsx from 'clsx';
import Image from 'next/image';
import { useRouter } from 'next/router';
import type { ReactElement } from 'react';
import React, { useState } from 'react';
import { monsterInformation } from '@/constants/monster';
import { findResourceById } from '@/constants/resources';
import { useAtlasContext } from '@/context/AtlasContext';
import useMonsterRampage from '@/hooks/settling/useMonsterRampage';
import { useWalletContext } from '@/hooks/useWalletContext';
import { DownloadAssets } from '@/shared/DownloadAssets';
import { isYourMonster } from '@/shared/Getters/Monster';
import { MarketplaceByPanel } from '@/shared/MarketplaceByPanel';

import type { MonstersCardProps } from '@/types/index';

const variantMaps: any = {
  small: { heading: 'lg:text-4xl', regions: 'lg:text-xl' },
};
const menuItems = ['Render', 'Map'];

export function MonsterOverview(props: MonstersCardProps): ReactElement {
  const router = useRouter();
  const { account } = useWalletContext();
  const { account: starkAccount } = useStarknet();
  const {
    mapContext: { navigateToAsset },
  } = useAtlasContext();
  const [imageView, setImageView] = useState(menuItems[0]);

  const keyStr =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

  const triplet = (e1: number, e2: number, e3: number) =>
    keyStr.charAt(e1 >> 2) +
    keyStr.charAt(((e1 & 3) << 4) | (e2 >> 4)) +
    keyStr.charAt(((e2 & 15) << 2) | (e3 >> 6)) +
    keyStr.charAt(e3 & 63);

  const rgbDataURL = (r: number, g: number, b: number) =>
    `data:image/gif;base64,R0lGODlhAQABAPAA${
      triplet(0, r, g) + triplet(b, 255, 255)
    }/yH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==`;
  const { initiate_rampage } = useMonsterRampage();
  const monsterBaseData = monsterInformation.find(
    (a) => a.classID === props.monster.monster_class
  );
  return (
    <>
      <div className="relative w-auto">
        <Menu className="!absolute z-10 !w-auto right-1 top-1">
          <Menu.Button
            variant="outline"
            className={clsx(imageView === '3D' && 'text-red-600/60')}
            size="xs"
          >
            View
          </Menu.Button>
          <Transition
            enter="transition duration-100 ease-out"
            enterFrom="transform scale-95 opacity-0"
            enterTo="transform scale-100 opacity-100"
            leave="transition duration-75 ease-out"
            leaveFrom="transform scale-100 opacity-100"
            leaveTo="transform scale-95 opacity-0"
          >
            <Menu.Items className="right-0 w-48 bg-black border border-cta-100/60">
              <Menu.Group className="flex">
                {menuItems.map((menuItem) => {
                  return (
                    <Menu.Item key={menuItem}>
                      {({ active }) => (
                        <Button
                          variant="unstyled"
                          size="xs"
                          className={clsx(
                            'block flex-1 font-display',
                            active ? 'text-red-900' : 'text-gray-500',
                            imageView === menuItem && 'text-red-500/60'
                          )}
                          fullWidth
                          onClick={() => setImageView(menuItem)}
                        >
                          {menuItem}
                        </Button>
                      )}
                    </Menu.Item>
                  );
                })}
              </Menu.Group>
            </Menu.Items>
          </Transition>
        </Menu>
        {imageView === 'Render' && (
          <Image
            src={`${props.monster.imageUrl}.png`}
            alt="map"
            className="w-full mt-4 rounded-xl -scale-x-80"
            width={400}
            placeholder="blur"
            blurDataURL={rgbDataURL(20, 20, 20)}
            height={400}
            loading="lazy"
            layout={'responsive'}
          />
        )}
      </div>
      <div className="flex flex-col justify-between py-2 mt-auto uppercase rounded shadow-inner sm:flex-row font-display">
        <span>
          Level:
          <span className="">{props.monster.level}</span>
        </span>
        <span>
          Class:
          <span className=""> {monsterBaseData?.className}</span>
        </span>
      </div>
      <div className="flex flex-wrap py-2 mb-2 border-t border-b font-display border-white/30">
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">XP</span>
        </div>
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">{props.monster.xp}</span>
        </div>
      </div>
      <div className="flex flex-wrap py-2 mb-2 border-t border-b font-display border-white/30">
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">HP</span>
        </div>
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">
            {props.monster.hp} / {monsterBaseData?.baseHP}
          </span>
        </div>
      </div>
      <div className="flex flex-wrap py-2 mb-2 border-t border-b font-display border-white/30">
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">Attack Power</span>
        </div>
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">{props.monster.attack_power}</span>
        </div>
      </div>
      <div className="flex flex-wrap py-2 mb-2 border-t border-b font-display border-white/30">
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">Defence Power</span>
        </div>
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">
            {props.monster.defence_power}
          </span>
        </div>
      </div>
      <div className="flex flex-wrap py-2 mb-2 border-t border-b font-display border-white/30">
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">Current Realm</span>
        </div>
        <div className="z-10 flex px-2 mb-1 mr-4 text-lg uppercase rounded bg-gray-1000">
          <span className="self-center ml-2">{props.monster.realmId}</span>
        </div>
      </div>

      <div className="w-full pt-4 bg-black shadow-inner">
        <div className="flex w-full mt-auto space-x-2">
          <div className="w-full">
            <Button
              onClick={() => {
                initiate_rampage(
                  props.monster.monsterId,
                  props.monster.realmId,
                  0,
                  props.monster.realmId
                );
              }}
              variant="primary"
              size="xs"
              className="w-full"
            >
              {isYourMonster(props.monster, account, starkAccount || '')
                ? 'Attack'
                : 'details'}
            </Button>
          </div>
          <div className="flex self-center space-x-2">
            <div>
              <Button
                onClick={() => {
                  navigateToAsset(props.monster.realmId, 'realm');
                }}
                variant="outline"
                size="xs"
                className="w-full uppercase"
              >
                Move
              </Button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
