import { Field, InputType, Int } from "type-graphql";
import { __Type } from "graphql";

@InputType()
export class BuildingCostInput {
  @Field(() => Int, { nullable: false })
  buildingId: number;

  @Field(() => Int, { nullable: false })
  resourceId: number;

  @Field({ nullable: false })
  qty: number;
}
