/*
  Warnings:

  - You are about to drop the column `contractContentId` on the `Contracts` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_contractContentId_fkey";

-- AlterTable
ALTER TABLE "ContractContent" ADD COLUMN     "contractId" INTEGER;

-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "contractContentId";

-- AddForeignKey
ALTER TABLE "ContractContent" ADD CONSTRAINT "ContractContent_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE SET NULL ON UPDATE CASCADE;
