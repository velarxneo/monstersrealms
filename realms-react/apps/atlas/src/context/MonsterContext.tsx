import type { Dispatch } from 'react';
import { createContext, useContext, useReducer } from 'react';
import { storage } from '@/util/localStorage';
export const MonsterFavoriteLocalStorageKey = 'monster.favourites';

interface MonsterState {
  favouriteMonsters: number[];
  searchIdFilter: string;
  selectedMonsters: number[];
}

type MonsterAction =
  | { type: 'clearFilfters' }
  | { type: 'addFavouriteMonster'; payload: number }
  | { type: 'removeFavouriteMonster'; payload: number }
  | { type: 'updateSearchIdFilter'; payload: string }
  | { type: 'toggleMonsterSelection'; payload: number }
  | { type: 'toggleSelectAllMonsters'; payload: number[] };

interface MonsterActions {
  clearFilters(): void;
  addFavouriteMonster(monsterId: number): void;
  removeFavouriteMonster(monsterId: number): void;
  updateSearchIdFilter(monsterId: string): void;
}

const defaultFilters = {
  searchIdFilter: '',
};

const defaultMonsterState = {
  ...defaultFilters,
  favouriteMonsters: [] as number[],
  selectedMonsters: [] as number[],
};

function monsterReducer(
  state: MonsterState,
  action: MonsterAction
): MonsterState {
  switch (action.type) {
    case 'updateSearchIdFilter':
      return { ...state, searchIdFilter: action.payload };
    case 'clearFilfters':
      return { ...state, ...defaultFilters };
    case 'addFavouriteMonster':
      storage<number[]>(MonsterFavoriteLocalStorageKey, []).set([
        ...state.favouriteMonsters,
        action.payload,
      ]);
      return {
        ...state,
        favouriteMonsters: [...state.favouriteMonsters, action.payload],
      };
    case 'removeFavouriteMonster':
      storage<number[]>(MonsterFavoriteLocalStorageKey, []).set(
        state.favouriteMonsters.filter(
          (monsterId: number) => monsterId !== action.payload
        )
      );
      return {
        ...state,
        favouriteMonsters: state.favouriteMonsters.filter(
          (monsterId: number) => monsterId !== action.payload
        ),
      };
    default:
      return state;
  }
}

// Actions
const mapActions = (dispatch: Dispatch<MonsterAction>): MonsterActions => ({
  updateSearchIdFilter: (monsterId: string) =>
    dispatch({ type: 'updateSearchIdFilter', payload: monsterId }),
  clearFilters: () => dispatch({ type: 'clearFilfters' }),
  addFavouriteMonster: (monsterId: number) =>
    dispatch({ type: 'addFavouriteMonster', payload: monsterId }),
  removeFavouriteMonster: (monsterId: number) =>
    dispatch({ type: 'removeFavouriteMonster', payload: monsterId }),
});

const MonsterContext = createContext<{
  state: MonsterState;
  dispatch: Dispatch<MonsterAction>;
  actions: MonsterActions;
}>(null!);

export function useMonsterContext() {
  return useContext(MonsterContext);
}

export function MonsterProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(monsterReducer, {
    ...defaultMonsterState,
    favouriteMonsters: storage<number[]>(
      MonsterFavoriteLocalStorageKey,
      []
    ).get(),
  });

  return (
    <MonsterContext.Provider
      value={{ state, dispatch, actions: mapActions(dispatch) }}
    >
      {children}
    </MonsterContext.Provider>
  );
}
