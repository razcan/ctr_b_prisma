/*
  Warnings:

  - Added the required column `updateadAt` to the `ContractsAudit` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ContractsAudit" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updateadAt" TIMESTAMP(3) NOT NULL;
