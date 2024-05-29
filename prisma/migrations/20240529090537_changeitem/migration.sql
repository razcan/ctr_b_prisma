/*
  Warnings:

  - You are about to drop the `InvoiceItem` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "InvoiceDetail" DROP CONSTRAINT "InvoiceDetail_itemId_fkey";

-- DropForeignKey
ALTER TABLE "InvoiceItem" DROP CONSTRAINT "InvoiceItem_classificationId_fkey";

-- DropForeignKey
ALTER TABLE "InvoiceItem" DROP CONSTRAINT "InvoiceItem_measuringUnitid_fkey";

-- DropForeignKey
ALTER TABLE "InvoiceItem" DROP CONSTRAINT "InvoiceItem_userId_fkey";

-- DropForeignKey
ALTER TABLE "InvoiceItem" DROP CONSTRAINT "InvoiceItem_vatId_fkey";

-- AlterTable
ALTER TABLE "Item" ADD COLUMN     "barCode" TEXT,
ADD COLUMN     "classificationId" INTEGER,
ADD COLUMN     "code" TEXT,
ADD COLUMN     "description" TEXT,
ADD COLUMN     "isActive" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "isStockable" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "measuringUnitid" INTEGER,
ADD COLUMN     "userId" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "vatId" INTEGER;

-- DropTable
DROP TABLE "InvoiceItem";

-- AddForeignKey
ALTER TABLE "Item" ADD CONSTRAINT "Item_vatId_fkey" FOREIGN KEY ("vatId") REFERENCES "VatQuota"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Item" ADD CONSTRAINT "Item_measuringUnitid_fkey" FOREIGN KEY ("measuringUnitid") REFERENCES "MeasuringUnit"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Item" ADD CONSTRAINT "Item_classificationId_fkey" FOREIGN KEY ("classificationId") REFERENCES "InvoiceItemClassification"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Item" ADD CONSTRAINT "Item_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InvoiceDetail" ADD CONSTRAINT "InvoiceDetail_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES "Item"("id") ON DELETE SET NULL ON UPDATE CASCADE;
