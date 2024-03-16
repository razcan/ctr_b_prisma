-- DropForeignKey
ALTER TABLE "ContractTasks" DROP CONSTRAINT "ContractTasks_assignedId_fkey";

-- DropForeignKey
ALTER TABLE "ContractTasks" DROP CONSTRAINT "ContractTasks_requestorId_fkey";

-- AddForeignKey
ALTER TABLE "ContractTasks" ADD CONSTRAINT "ContractTasks_requestorId_fkey" FOREIGN KEY ("requestorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractTasks" ADD CONSTRAINT "ContractTasks_assignedId_fkey" FOREIGN KEY ("assignedId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
