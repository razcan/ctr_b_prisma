/*
  Warnings:

  - Made the column `statusId` on table `Contracts` required. This step will fail if there are existing NULL values in that column.
  - Made the column `typeId` on table `Contracts` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_statusId_fkey";

-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_typeId_fkey";

-- AlterTable
ALTER TABLE "Contracts" ALTER COLUMN "statusId" SET NOT NULL,
ALTER COLUMN "typeId" SET NOT NULL;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "ContractType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES "ContractStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
