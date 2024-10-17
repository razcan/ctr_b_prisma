/*
  Warnings:

  - A unique constraint covering the columns `[entityId,typeId,number]` on the table `Invoice` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "Invoice_entityId_seriesId_number_key";

-- CreateIndex
CREATE UNIQUE INDEX "Invoice_entityId_typeId_number_key" ON "Invoice"("entityId", "typeId", "number");
