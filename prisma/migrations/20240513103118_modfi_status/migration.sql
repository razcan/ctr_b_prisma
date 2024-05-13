-- DropForeignKey
ALTER TABLE "WorkFlowContractTasks" DROP CONSTRAINT "WorkFlowContractTasks_statusId_fkey";

-- DropForeignKey
ALTER TABLE "WorkFlowXContracts" DROP CONSTRAINT "WorkFlowXContracts_wfstatusId_fkey";

-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "statusWFId" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "ContractsAudit" ADD COLUMN     "statusWFId" INTEGER DEFAULT 1,
ALTER COLUMN "statusId" SET DEFAULT 1;

-- CreateTable
CREATE TABLE "ContractWFStatus" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "Desription" TEXT NOT NULL DEFAULT '',

    CONSTRAINT "ContractWFStatus_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ContractWFStatus_name_key" ON "ContractWFStatus"("name");

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_statusWFId_fkey" FOREIGN KEY ("statusWFId") REFERENCES "ContractWFStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowContractTasks" ADD CONSTRAINT "WorkFlowContractTasks_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES "ContractWFStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowXContracts" ADD CONSTRAINT "WorkFlowXContracts_wfstatusId_fkey" FOREIGN KEY ("wfstatusId") REFERENCES "ContractWFStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
