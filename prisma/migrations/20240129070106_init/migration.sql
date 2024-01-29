/*
  Warnings:

  - You are about to drop the column `cashflow` on the `Contracts` table. All the data in the column will be lost.
  - You are about to drop the column `category` on the `Contracts` table. All the data in the column will be lost.
  - You are about to drop the column `costcenter` on the `Contracts` table. All the data in the column will be lost.
  - You are about to drop the column `item` on the `Contracts` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "cashflow",
DROP COLUMN "category",
DROP COLUMN "costcenter",
DROP COLUMN "item",
ADD COLUMN     "cashflowId" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "categoryId" INTEGER DEFAULT 1,
ADD COLUMN     "costcenterId" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "itemId" INTEGER NOT NULL DEFAULT 1;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_cashflowId_fkey" FOREIGN KEY ("cashflowId") REFERENCES "Cashflow"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES "Item"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_costcenterId_fkey" FOREIGN KEY ("costcenterId") REFERENCES "CostCenter"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
