import { Event } from "./../../entities/starknet/Event";
import { Context } from "./../../context";
import { BigNumber } from "ethers";
import BaseContractIndexer from "./../BaseContractIndexer";

const CONTRACT =
"0x058bf65283a345d04299b2c04fdba55f6a83e1f598adc809940d1ff2fb2c579c";

const overflow = 2**64;

export default class MonsterIndexer extends BaseContractIndexer {
  constructor(context: Context) {
    super(context, CONTRACT);

    this.on("TransferMonster", this.transferMonster.bind(this));
    this.on("UpdateMonsterAfterRampage", this.updateMonsterAfterRampage.bind(this));
  }

  async transferMonster(event: Event): Promise<void> {
    const params = event.parameters ?? [];

    try {

      const monsterIdx = parseInt(params[0]);
      
      const realmId = parseInt(params[1]);
      const namea = BigInt(params[2]);
      const bigName = [namea];
      const name = feltArrToStr(bigName)
      const monster_class = parseInt(params[3]);
      const rarity = parseInt(params[4]);
      const level = parseInt(params[5]);
      const xp = parseInt(params[6]);
      const hp = parseInt(params[7]);
      const attack_power = parseInt(params[8]);
      const defence_power = parseInt(params[9]);
      const owner = BigNumber.from(params[10]).toHexString();
      //const imageUrlLen = parseInt(params[11]);
      
      console.log(params[13]);
      
      let imageUrl = "";

      if (params[13] != null)
      {
        const imageUrla = BigInt(params[12]);
        const imageUrlb = BigInt(params[13]);
        const bigImageUrl = [imageUrla, imageUrlb];
        imageUrl = feltArrToStr(bigImageUrl) + monster_class + "_" + level;
      }
      
      await this.context.prisma.monster.upsert({
        where: {
          monsterId: monsterIdx
        },
        update: {
          eventIndexed: event.eventId,
        },
        create: {
          monsterId: monsterIdx,
          realmId: realmId,      
          imageUrl: imageUrl,
          owner: owner.toString(),
          name: name.toString(),
          monster_class: monster_class.toString(),
          rarity: rarity.toString(),
          level: level,
          xp: xp, 
          hp: hp, 
          attack_power: attack_power, 
          defence_power: defence_power, 
          eventIndexed: event.eventId
        }
      });


    } catch (e) {
      console.error(
        `Invalid monster update: Event: ${event.eventId}, Params: `,
        JSON.stringify(params)
      );
      throw e;
    }

    
    return;
  }


  async updateMonsterAfterRampage(event: Event): Promise<void> {
    const params = event.parameters ?? [];

    try {
      let hp = 0;
      const monsterIdx = parseInt(params[0]);  
      if (parseInt(params[2]) < overflow){
        hp = parseInt(params[2]);
      }
      const xp = parseInt(params[3]);
      
      await this.context.prisma.monster.upsert({
        where: {
          monsterId: monsterIdx
        },
        update: {
          xp: xp, 
          hp: hp, 
          eventIndexed: event.eventId,
        },
        create: {
          monsterId: monsterIdx,
          realmId: 0,      
          imageUrl: "",
          owner: "",
          name: "",
          monster_class: "",
          rarity: "",
          level: 0,
          xp: 0, 
          hp: 0, 
          attack_power: 0, 
          defence_power: 0, 
          eventIndexed: event.eventId
        }
      });


    } catch (e) {
      console.error(
        `Invalid monster update: Event: ${event.eventId}, Params: `,
        JSON.stringify(params)
      );
      throw e;
    }

    
    return;
  }

  
}


export function feltArrToStr(felts: bigint[]): string {
  return felts.reduce(
    (memo, felt) => memo + Buffer.from(felt.toString(16), "hex").toString(),
    ""
  );
}


