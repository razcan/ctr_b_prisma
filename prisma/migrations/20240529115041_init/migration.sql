/*
  Warnings:

  - You are about to drop the `InvoiceItemClassification` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "Item" DROP CONSTRAINT "Item_classificationId_fkey";

-- DropTable
DROP TABLE "InvoiceItemClassification";

-- AddForeignKey
ALTER TABLE "Item" ADD CONSTRAINT "Item_classificationId_fkey" FOREIGN KEY ("classificationId") REFERENCES "Category"("id") ON DELETE SET NULL ON UPDATE CASCADE;
