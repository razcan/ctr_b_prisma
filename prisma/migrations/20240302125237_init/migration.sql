/*
  Warnings:

  - You are about to drop the `User_Groups` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "User_Groups" DROP CONSTRAINT "User_Groups_userId_fkey";

-- DropTable
DROP TABLE "User_Groups";

-- CreateTable
CREATE TABLE "_GroupsToUser" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "_GroupsToUser_AB_unique" ON "_GroupsToUser"("A", "B");

-- CreateIndex
CREATE INDEX "_GroupsToUser_B_index" ON "_GroupsToUser"("B");

-- AddForeignKey
ALTER TABLE "_GroupsToUser" ADD CONSTRAINT "_GroupsToUser_A_fkey" FOREIGN KEY ("A") REFERENCES "Groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_GroupsToUser" ADD CONSTRAINT "_GroupsToUser_B_fkey" FOREIGN KEY ("B") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
