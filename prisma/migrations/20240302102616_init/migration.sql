/*
  Warnings:

  - You are about to drop the column `entityId` on the `Groups` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Groups" DROP CONSTRAINT "Groups_entityId_fkey";

-- AlterTable
ALTER TABLE "Groups" DROP COLUMN "entityId";

-- CreateTable
CREATE TABLE "_GroupsToPartners" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "_GroupsToPartners_AB_unique" ON "_GroupsToPartners"("A", "B");

-- CreateIndex
CREATE INDEX "_GroupsToPartners_B_index" ON "_GroupsToPartners"("B");

-- AddForeignKey
ALTER TABLE "_GroupsToPartners" ADD CONSTRAINT "_GroupsToPartners_A_fkey" FOREIGN KEY ("A") REFERENCES "Groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_GroupsToPartners" ADD CONSTRAINT "_GroupsToPartners_B_fkey" FOREIGN KEY ("B") REFERENCES "Partners"("id") ON DELETE CASCADE ON UPDATE CASCADE;
