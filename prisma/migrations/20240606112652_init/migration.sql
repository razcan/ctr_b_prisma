/*
  Warnings:

  - You are about to drop the column `partnersId` on the `Invoice` table. All the data in the column will be lost.
  - Added the required column `partnerId` to the `Invoice` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_partnersId_fkey";

-- AlterTable
ALTER TABLE "Banks" ADD COLUMN     "isDefault" BOOLEAN;

-- AlterTable
ALTER TABLE "Invoice" DROP COLUMN "partnersId",
ADD COLUMN     "partnerId" INTEGER NOT NULL;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partners"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
