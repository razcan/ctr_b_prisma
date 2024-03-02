/*
  Warnings:

  - The primary key for the `User_Groups` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `groupId` on the `User_Groups` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "User_Groups" DROP CONSTRAINT "User_Groups_groupId_fkey";

-- AlterTable
ALTER TABLE "User_Groups" DROP CONSTRAINT "User_Groups_pkey",
DROP COLUMN "groupId",
ADD CONSTRAINT "User_Groups_pkey" PRIMARY KEY ("id");
