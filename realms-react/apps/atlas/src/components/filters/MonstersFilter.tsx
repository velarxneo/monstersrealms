import { Button } from '@bibliotheca-dao/ui-lib';
import { SearchFilter } from '@/components/filters/SearchFilter';
import { useMonsterContext } from '@/context/MonsterContext';
import { BaseFilter } from './BaseFilter';

type MonstersFilterProps = {
  isYourMonsters: boolean;
};

export function MonstersFilter(props: MonstersFilterProps) {
  const { state, actions } = useMonsterContext();
  return (
    <BaseFilter>
      <div className="md:ml-4"></div>
    </BaseFilter>
  );
}
