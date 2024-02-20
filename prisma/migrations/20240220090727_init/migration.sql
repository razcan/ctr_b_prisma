/*
  Warnings:

  - You are about to drop the column `contractId` on the `ContractStatus` table. All the data in the column will be lost.
  - You are about to drop the column `contractId` on the `ContractType` table. All the data in the column will be lost.
  - Made the column `sign` on table `ContractsAudit` required. This step will fail if there are existing NULL values in that column.
  - Made the column `completion` on table `ContractsAudit` required. This step will fail if there are existing NULL values in that column.
  - Made the column `remarks` on table `ContractsAudit` required. This step will fail if there are existing NULL values in that column.
  - Made the column `cashflowId` on table `ContractsAudit` required. This step will fail if there are existing NULL values in that column.
  - Made the column `itemId` on table `ContractsAudit` required. This step will fail if there are existing NULL values in that column.
  - Made the column `automaticRenewal` on table `ContractsAudit` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "ContractStatus" DROP CONSTRAINT "ContractStatus_contractId_fkey";

-- DropForeignKey
ALTER TABLE "ContractType" DROP CONSTRAINT "ContractType_contractId_fkey";

-- AlterTable
ALTER TABLE "ContractStatus" DROP COLUMN "contractId";

-- AlterTable
ALTER TABLE "ContractType" DROP COLUMN "contractId";

-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "paymentTypeId" INTEGER;

-- AlterTable
ALTER TABLE "ContractsAudit" ALTER COLUMN "sign" SET NOT NULL,
ALTER COLUMN "completion" SET NOT NULL,
ALTER COLUMN "remarks" SET NOT NULL,
ALTER COLUMN "cashflowId" SET NOT NULL,
ALTER COLUMN "itemId" SET NOT NULL,
ALTER COLUMN "automaticRenewal" SET NOT NULL;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "ContractType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES "ContractStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_paymentTypeId_fkey" FOREIGN KEY ("paymentTypeId") REFERENCES "PaymentType"("id") ON DELETE SET NULL ON UPDATE CASCADE;
