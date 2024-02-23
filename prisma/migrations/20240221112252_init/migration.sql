-- AlterTable
ALTER TABLE "ContractFinancialDetail" ALTER COLUMN "itemid" DROP NOT NULL,
ALTER COLUMN "currencyPercent" DROP NOT NULL,
ALTER COLUMN "billingFrequencyid" DROP NOT NULL,
ALTER COLUMN "measuringUnitid" DROP NOT NULL,
ALTER COLUMN "paymentTypeid" DROP NOT NULL,
ALTER COLUMN "remarks" DROP NOT NULL,
ALTER COLUMN "guaranteeLetter" DROP NOT NULL,
ALTER COLUMN "guaranteeLetterCurrencyid" DROP NOT NULL,
ALTER COLUMN "guaranteeLetterDate" DROP NOT NULL,
ALTER COLUMN "guaranteeLetterValue" DROP NOT NULL,
ALTER COLUMN "active" DROP NOT NULL;
