import { Event } from "./../../entities/starknet/Event";
import { Context } from "./../../context";
import BaseContractIndexer from "./../BaseContractIndexer";
import { ResourceNameById } from "./../../utils/game_constants";

const CONTRACT =
  "0x0417eacd7261266fc4657eb1a5438d0707eaeb60cdd57b4614a732a59edf10b4";
export default class ResourceIndexer extends BaseContractIndexer {
  constructor(context: Context) {
    super(context, CONTRACT);

    this.on("ResourceUpgraded", this.upgradeResource.bind(this));
  }

  async upgradeResource(event: Event): Promise<void> {
    const params = event.parameters ?? [];
    const eventId = event.eventId;
    const realmId = parseInt(params[0]);
    let resourceId = 0;
    let where = {};
    let resource;
    try {
      resourceId = parseInt(params[2]);
      where = {
        resourceId_realmId: {
          realmId,
          resourceId
        }
      };
      resource = await this.context.prisma.resource.findUnique({
        where
      });
    } catch (e) {
      console.error(
        `Invalid resource upgrade: Event: ${event.eventId}, Params: `,
        JSON.stringify(params)
      );
      throw e;
    }

    if (resource) {
      let upgrades = resource.upgrades ?? [];
      const timestamp = event.timestamp.toISOString();
      if (upgrades.indexOf(timestamp) === -1) {
        upgrades.push(timestamp);
      }
      const level = parseInt(params[3]);
      await this.context.prisma.resource.update({
        where,
        data: {
          level,
          upgrades: [...upgrades]
        }
      });

      await this.saveRealmHistory({
        realmId,
        eventId,
        eventType: "realm_resource_upgraded",
        timestamp: event.timestamp,
        transactionHash: event.txHash,
        data: {
          resourceId,
          resourceName: ResourceNameById[resourceId + ""],
          level
        }
      });
    }
  }
}
