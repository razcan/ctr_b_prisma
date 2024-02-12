/*
  Warnings:

  - You are about to alter the column `content` on the `ContractContent` table. The data in that column could be lost. The data in that column will be cast from `VarChar(10000)` to `VarChar(8000)`.

*/
-- AlterTable
ALTER TABLE "ContractContent" ALTER COLUMN "content" SET DATA TYPE VARCHAR(8000);
