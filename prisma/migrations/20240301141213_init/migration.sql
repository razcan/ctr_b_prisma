/*
  Warnings:

  - You are about to drop the column `partnersId` on the `User_Groups` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "User_Groups" DROP CONSTRAINT "User_Groups_partnersId_fkey";

-- AlterTable
ALTER TABLE "User_Groups" DROP COLUMN "partnersId";
