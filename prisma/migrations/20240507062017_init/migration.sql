/*
  Warnings:

  - You are about to drop the column `advance` on the `ContractFinancialDetail` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "ContractFinancialDetail" DROP COLUMN "advance",
ADD COLUMN     "advancePercent" DOUBLE PRECISION;
