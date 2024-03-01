/*
  Warnings:

  - You are about to drop the column `roleId` on the `Groups` table. All the data in the column will be lost.
  - The primary key for the `User_Groups` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `entityId` on the `User_Groups` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Groups" DROP CONSTRAINT "Groups_roleId_fkey";

-- DropForeignKey
ALTER TABLE "User_Groups" DROP CONSTRAINT "User_Groups_entityId_fkey";

-- AlterTable
ALTER TABLE "Groups" DROP COLUMN "roleId";

-- AlterTable
ALTER TABLE "User_Groups" DROP CONSTRAINT "User_Groups_pkey",
DROP COLUMN "entityId",
ADD COLUMN     "partnersId" INTEGER,
ADD CONSTRAINT "User_Groups_pkey" PRIMARY KEY ("userId", "groupId");

-- AddForeignKey
ALTER TABLE "User_Groups" ADD CONSTRAINT "User_Groups_partnersId_fkey" FOREIGN KEY ("partnersId") REFERENCES "Partners"("id") ON DELETE SET NULL ON UPDATE CASCADE;
