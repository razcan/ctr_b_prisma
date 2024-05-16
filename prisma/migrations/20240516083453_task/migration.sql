-- AlterTable
ALTER TABLE "ContractTasks" ADD COLUMN     "statusWFId" INTEGER NOT NULL DEFAULT 2;

-- AddForeignKey
ALTER TABLE "ContractTasks" ADD CONSTRAINT "ContractTasks_statusWFId_fkey" FOREIGN KEY ("statusWFId") REFERENCES "ContractWFStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
