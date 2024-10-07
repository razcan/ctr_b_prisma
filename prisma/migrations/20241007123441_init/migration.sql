/*
  Warnings:

  - You are about to drop the column `seriesId` on the `Transactions` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Transactions" DROP CONSTRAINT "Transactions_seriesId_fkey";

-- AlterTable
ALTER TABLE "Transactions" DROP COLUMN "seriesId";
