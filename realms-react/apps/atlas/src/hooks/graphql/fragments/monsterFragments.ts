/* eslint-disable @typescript-eslint/naming-convention */

import { gql, useQuery } from '@apollo/client';

export const MonsterFragment = gql`
  fragment MonsterData on Monster {
    attack_power
    defence_power
    hp
    imageUrl
    level
    monsterId
    monster_class
    name
    owner
    rarity
    monsterId
    xp
  }
`;