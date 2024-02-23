/*
  Warnings:

  - You are about to drop the column `assigned` on the `ContractTasks` table. All the data in the column will be lost.
  - You are about to drop the column `requestor` on the `ContractTasks` table. All the data in the column will be lost.
  - You are about to drop the column `status` on the `ContractTasks` table. All the data in the column will be lost.
  - Added the required column `assignedId` to the `ContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `requestorId` to the `ContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `statusId` to the `ContractTasks` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ContractTasks" DROP COLUMN "assigned",
DROP COLUMN "requestor",
DROP COLUMN "status",
ADD COLUMN     "assignedId" INTEGER NOT NULL,
ADD COLUMN     "requestorId" INTEGER NOT NULL,
ADD COLUMN     "statusId" INTEGER NOT NULL;

-- AddForeignKey
ALTER TABLE "ContractTasks" ADD CONSTRAINT "ContractTasks_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES "ContractStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractTasks" ADD CONSTRAINT "ContractTasks_requestorId_fkey" FOREIGN KEY ("requestorId") REFERENCES "Persons"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractTasks" ADD CONSTRAINT "ContractTasks_assignedId_fkey" FOREIGN KEY ("assignedId") REFERENCES "Persons"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
