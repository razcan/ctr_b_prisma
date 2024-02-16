/*
  Warnings:

  - You are about to drop the column `contractAttachmentsId` on the `Contracts` table. All the data in the column will be lost.
  - Added the required column `contractId` to the `ContractAttachments` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_contractAttachmentsId_fkey";

-- AlterTable
ALTER TABLE "ContractAttachments" ADD COLUMN     "contractId" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "contractAttachmentsId";

-- AddForeignKey
ALTER TABLE "ContractAttachments" ADD CONSTRAINT "ContractAttachments_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
