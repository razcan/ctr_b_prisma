-- CreateTable
CREATE TABLE "ContractTasks" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "taskName" TEXT NOT NULL,
    "contractId" INTEGER NOT NULL,
    "progress" INTEGER NOT NULL,
    "status" INTEGER NOT NULL,
    "statusDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "requestor" INTEGER NOT NULL,
    "assigned" INTEGER NOT NULL,
    "due" TIMESTAMP(3) NOT NULL,
    "notes" TEXT NOT NULL,

    CONSTRAINT "ContractTasks_pkey" PRIMARY KEY ("id")
);
