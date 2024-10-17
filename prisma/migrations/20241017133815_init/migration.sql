/*
  Warnings:

  - A unique constraint covering the columns `[entityId,typeId,serialNumber,number,partnerId]` on the table `Invoice` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "Invoice_entityId_typeId_number_partnerId_key";

-- CreateIndex
CREATE UNIQUE INDEX "Invoice_entityId_typeId_serialNumber_number_partnerId_key" ON "Invoice"("entityId", "typeId", "serialNumber", "number", "partnerId");
