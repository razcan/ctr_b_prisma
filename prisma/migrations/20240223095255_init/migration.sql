-- AddForeignKey
ALTER TABLE "ContractTasks" ADD CONSTRAINT "ContractTasks_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES "ContractTasksStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
