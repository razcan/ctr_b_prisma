/*
  Warnings:

  - Added the required column `billingFrequencyid` to the `ContractItems` table without a default value. This is not possible if the table is not empty.
  - Added the required column `currencyValue` to the `ContractItems` table without a default value. This is not possible if the table is not empty.
  - Added the required column `currencyid` to the `ContractItems` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ContractItems" ADD COLUMN     "billingFrequencyid" INTEGER NOT NULL,
ADD COLUMN     "currencyValue" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "currencyid" INTEGER NOT NULL;
