import { Resolver, Arg, Mutation, Query, Ctx } from "type-graphql";
import { Context } from "../../context";
import { Monster } from "../../entities/settling";
import { MonsterInput } from "../types/settling";
import { MonsterFilterInput, MonsterOrderByInput } from "../types/settling";

@Resolver((_of) => Monster)
export class MonsterResolver {
  @Query((_returns) => Monster, { nullable: false })
  async getMonster(@Arg("monsterId") monsterId: number, @Ctx() ctx: Context) {
    return await ctx.prisma.monster.findUnique({
      where: { monsterId: monsterId }
    });
  }

 

  @Query(() => [Monster])
  async getMonsters(
    @Ctx() ctx: Context,
    @Arg("filter", { nullable: true }) filter: MonsterFilterInput,
    @Arg("orderBy", { nullable: true }) orderBy: MonsterOrderByInput,
    @Arg("take", { nullable: true, defaultValue: 100 }) take: number,
    @Arg("skip", { nullable: true, defaultValue: 0 }) skip: number
  ) {
    return await ctx.prisma.monster.findMany({
      where: filter,
     
      orderBy: orderBy
        ? Object.keys(orderBy).map((key: any) => ({
            [key]: (orderBy as any)[key]
          }))
        : undefined,
      take,
      skip
    });
  }

  @Mutation(() => Monster)
  async createOrUpdateMonster(
    @Arg("data")
    data: MonsterInput,
    @Ctx() ctx: Context
  ) {
    const updates = {
      name: data.name,
      monsterId: data.monsterId,
      realmId: data.realmId,  
      owner: data.owner,
      imageUrl: data.imageUrl,
      monster_class: data.monster_class,
      rarity: data.rarity,
      level: data.level,
      xp: data.xp,
      hp: data.hp,
      attack_power: data.attack_power,
      defence_power: data.defence_power
    };
    return ctx.prisma.monster.upsert({
      where: {
        monsterId: data.monsterId
      },
      update: {
        ...updates
      },
      create: {
        ...updates
      }
    });
  }
}