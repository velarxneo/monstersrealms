import { InputType, Field, Int } from "type-graphql";

@InputType()
export class MonsterInput {
  @Field(() => Int, { nullable: false })
  monsterId: number;

  @Field(() => Int, { nullable: false })
  realmId: number;

  @Field(() => String, { nullable: false })
  owner: string;
  
  @Field(() => String, { nullable: false })
  imageUrl: string;

  @Field(() => String, { nullable: false })
  name: string;

  @Field(() => String, { nullable: false })
  monster_class: string;

  @Field(() => String, { nullable: false })
  rarity: string;

  @Field(() => Int, { nullable: false })
  level: number;

  @Field(() => Int, { nullable: false })
  xp: number;

  @Field(() => Int, { nullable: false })
  hp: number;

  @Field(() => Int, { nullable: false })
  attack_power: number;
  
  @Field(() => Int, { nullable: false })
  defence_power: number;

}