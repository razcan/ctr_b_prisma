-- CreateTable
CREATE TABLE "AlertsHistory" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "alertId" INTEGER NOT NULL,
    "alertContent" TEXT NOT NULL,
    "sentTo" TEXT NOT NULL,
    "contractId" INTEGER NOT NULL,
    "criteria" TEXT NOT NULL,
    "param" TEXT NOT NULL,
    "nrofdays" INTEGER NOT NULL,

    CONSTRAINT "AlertsHistory_pkey" PRIMARY KEY ("id")
);
