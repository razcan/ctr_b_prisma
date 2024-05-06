/*
  Warnings:

  - You are about to drop the column `itemId` on the `Contracts` table. All the data in the column will be lost.
  - You are about to drop the column `itemId` on the `ContractsAudit` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_itemId_fkey";

-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "itemId";

-- AlterTable
ALTER TABLE "ContractsAudit" DROP COLUMN "itemId",
ADD COLUMN     "locationId" INTEGER;
