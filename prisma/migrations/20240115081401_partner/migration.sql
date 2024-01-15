/*
  Warnings:

  - You are about to drop the column `partner_id` on the `Contracts` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_partner_id_fkey";

-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "partner_id",
ADD COLUMN     "partnersId" INTEGER;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_partnersId_fkey" FOREIGN KEY ("partnersId") REFERENCES "Partners"("id") ON DELETE SET NULL ON UPDATE CASCADE;
