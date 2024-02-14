-- CreateTable
CREATE TABLE "ContractAlertSchedule" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "contractId" INTEGER NOT NULL,
    "alertId" INTEGER NOT NULL,
    "alertname" TEXT NOT NULL,
    "datetoBeSent" TIMESTAMP(3) NOT NULL,
    "isActive" BOOLEAN NOT NULL,
    "status" BOOLEAN NOT NULL,
    "subject" TEXT NOT NULL,
    "nrofdays" INTEGER NOT NULL,

    CONSTRAINT "ContractAlertSchedule_pkey" PRIMARY KEY ("id")
);
