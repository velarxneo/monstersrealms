-- AlterTable
ALTER TABLE "RealmHistory" ADD COLUMN     "realmName" TEXT NOT NULL DEFAULT E'',
ADD COLUMN     "realmOrder" "OrderType",
ADD COLUMN     "realmOwner" TEXT NOT NULL DEFAULT E'';
