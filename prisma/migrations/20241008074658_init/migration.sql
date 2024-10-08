/*
  Warnings:

  - A unique constraint covering the columns `[entityId,number]` on the table `Transactions` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "Invoice" ADD COLUMN     "restPayment" DOUBLE PRECISION NOT NULL DEFAULT -1;

-- AlterTable
ALTER TABLE "Transactions" ADD COLUMN     "bank" DOUBLE PRECISION;

-- CreateIndex
CREATE UNIQUE INDEX "Transactions_entityId_number_key" ON "Transactions"("entityId", "number");
