-- CreateTable
CREATE TABLE "ContractItems" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "contractId" INTEGER NOT NULL,
    "itemid" INTEGER NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "ContractItems_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContractFinancialDetail" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "itemid" INTEGER NOT NULL,
    "totalContractValue" DOUBLE PRECISION NOT NULL,
    "currencyid" INTEGER NOT NULL,
    "currencyValue" DOUBLE PRECISION NOT NULL,
    "currencyPercent" DOUBLE PRECISION NOT NULL,
    "billingDay" INTEGER NOT NULL,
    "billingQtty" DOUBLE PRECISION NOT NULL,
    "billingFrequencyid" INTEGER NOT NULL,
    "measuringUnitid" INTEGER NOT NULL,
    "paymentTypeid" INTEGER NOT NULL,
    "billingPenaltyPercent" DOUBLE PRECISION NOT NULL,
    "billingDueDays" INTEGER NOT NULL,
    "remarks" VARCHAR(150) NOT NULL,
    "guaranteeLetter" BOOLEAN NOT NULL,
    "guaranteeLetterCurrencyid" INTEGER NOT NULL,
    "guaranteeLetterDate" TIMESTAMP(3) NOT NULL,
    "guaranteeLetterValue" DOUBLE PRECISION NOT NULL,
    "contractItemId" INTEGER NOT NULL,

    CONSTRAINT "ContractFinancialDetail_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContractFinancialDetailSchedule" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "itemid" INTEGER NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "measuringUnitid" INTEGER NOT NULL,
    "billingQtty" DOUBLE PRECISION NOT NULL,
    "totalContractValue" DOUBLE PRECISION NOT NULL,
    "billingValue" DOUBLE PRECISION NOT NULL,
    "guaranteeLetterCurrencyid" INTEGER NOT NULL,
    "isInvoiced" BOOLEAN NOT NULL,
    "isPayed" BOOLEAN NOT NULL,
    "contractFinancialItemId" INTEGER NOT NULL,

    CONSTRAINT "ContractFinancialDetailSchedule_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "ContractItems" ADD CONSTRAINT "ContractItems_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_contractItemId_fkey" FOREIGN KEY ("contractItemId") REFERENCES "ContractItems"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" ADD CONSTRAINT "ContractFinancialDetailSchedule_contractFinancialItemId_fkey" FOREIGN KEY ("contractFinancialItemId") REFERENCES "ContractFinancialDetail"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
