-- AddForeignKey
ALTER TABLE "ContractTasks" ADD CONSTRAINT "ContractTasks_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE SET NULL ON UPDATE CASCADE;
