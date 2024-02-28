/*
  Warnings:

  - Added the required column `content` to the `ContractTemplates` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ContractTemplates" ADD COLUMN     "content" TEXT NOT NULL;
