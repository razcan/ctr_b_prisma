/*
  Warnings:

  - You are about to drop the column `paymentTypeId` on the `Contracts` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_paymentTypeId_fkey";

-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_statusId_fkey";

-- AlterTable
ALTER TABLE "ContractStatus" ADD COLUMN     "contractId" INTEGER;

-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "paymentTypeId";

-- AddForeignKey
ALTER TABLE "ContractStatus" ADD CONSTRAINT "ContractStatus_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE SET NULL ON UPDATE CASCADE;
