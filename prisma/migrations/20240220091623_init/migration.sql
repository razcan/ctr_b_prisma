/*
  Warnings:

  - Made the column `partnersId` on table `Contracts` required. This step will fail if there are existing NULL values in that column.
  - Made the column `entityId` on table `Contracts` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_cashflowId_fkey";

-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_entityId_fkey";

-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_itemId_fkey";

-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_partnersId_fkey";

-- AlterTable
ALTER TABLE "Contracts" ALTER COLUMN "partnersId" SET NOT NULL,
ALTER COLUMN "entityId" SET NOT NULL,
ALTER COLUMN "cashflowId" DROP NOT NULL,
ALTER COLUMN "itemId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "ContractsAudit" ALTER COLUMN "typeId" DROP NOT NULL,
ALTER COLUMN "costcenterId" DROP NOT NULL,
ALTER COLUMN "start" DROP NOT NULL,
ALTER COLUMN "end" DROP NOT NULL,
ALTER COLUMN "sign" DROP NOT NULL,
ALTER COLUMN "completion" DROP NOT NULL,
ALTER COLUMN "remarks" DROP NOT NULL,
ALTER COLUMN "cashflowId" DROP NOT NULL,
ALTER COLUMN "itemId" DROP NOT NULL,
ALTER COLUMN "automaticRenewal" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_cashflowId_fkey" FOREIGN KEY ("cashflowId") REFERENCES "Cashflow"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES "Item"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_partnersId_fkey" FOREIGN KEY ("partnersId") REFERENCES "Partners"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_entityId_fkey" FOREIGN KEY ("entityId") REFERENCES "Partners"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
