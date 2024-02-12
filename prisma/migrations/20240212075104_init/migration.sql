/*
  Warnings:

  - Added the required column `id` to the `ContractsAudit` table without a default value. This is not possible if the table is not empty.
  - Added the required column `operationType` to the `ContractsAudit` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ContractsAudit" ADD COLUMN     "id" INTEGER NOT NULL,
ADD COLUMN     "operationType" TEXT NOT NULL;
