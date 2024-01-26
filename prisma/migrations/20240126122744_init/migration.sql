/*
  Warnings:

  - You are about to drop the column `contractId` on the `ContractsDetails` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "ContractsDetails" DROP CONSTRAINT "ContractsDetails_contractId_fkey";

-- AlterTable
ALTER TABLE "ContractsDetails" DROP COLUMN "contractId";
