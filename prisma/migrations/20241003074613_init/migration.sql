/*
  Warnings:

  - A unique constraint covering the columns `[entityId,seriesId,number]` on the table `Invoice` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Invoice_entityId_seriesId_number_key" ON "Invoice"("entityId", "seriesId", "number");
