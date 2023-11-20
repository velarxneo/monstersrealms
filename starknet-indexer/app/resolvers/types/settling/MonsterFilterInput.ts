// import { Prisma } from "@prisma/client";
import { Prisma } from "@prisma/client";
import { InputType, Field } from "type-graphql";
import { IntFilterInput, StringFilterInput } from "../common";

@InputType()
export class MonsterFilterInput implements Partial<Prisma.MonsterWhereInput> {
  
  @Field(() => IntFilterInput, { nullable: true })
  monsterId?: object;

  @Field(() => IntFilterInput, { nullable: true })
  realmId?: object;

  @Field(() => StringFilterInput, { nullable: true })
  owner?: object;

  @Field(() => StringFilterInput, { nullable: true })
  imageUrl?: object;

  @Field(() => StringFilterInput, { nullable: true })
  name?: object;

  @Field(() => StringFilterInput, { nullable: true })
  monster_class?: object;

  @Field(() => StringFilterInput, { nullable: true })
  rarity?: object;

  @Field(() => IntFilterInput, { nullable: true })
  level?: object;
  
  @Field(() => IntFilterInput, { nullable: true })
  xp?: object;
  
  @Field(() => IntFilterInput, { nullable: true })
  hp?: object;
  
  @Field(() => IntFilterInput, { nullable: true })
  attack_power?: object;
  
  @Field(() => IntFilterInput, { nullable: true })
  defence_power?: object;


  @Field(() => [MonsterFilterInput], { nullable: true })
  AND?: [MonsterFilterInput];
  @Field(() => [MonsterFilterInput], { nullable: true })
  OR?: [MonsterFilterInput];
  @Field(() => [MonsterFilterInput], { nullable: true })
  NOT?: [MonsterFilterInput];
}