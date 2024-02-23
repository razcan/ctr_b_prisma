/*
  Warnings:

  - A unique constraint covering the columns `[contractId]` on the table `ContractContent` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "ContractContent_contractId_key" ON "ContractContent"("contractId");
