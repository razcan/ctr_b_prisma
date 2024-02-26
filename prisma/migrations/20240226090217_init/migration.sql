-- AlterTable
ALTER TABLE "ContractFinancialDetail" ALTER COLUMN "currencyid" DROP NOT NULL;

-- AlterTable
ALTER TABLE "ContractFinancialDetailSchedule" ALTER COLUMN "measuringUnitid" DROP NOT NULL,
ALTER COLUMN "currencyid" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_currencyid_fkey" FOREIGN KEY ("currencyid") REFERENCES "Currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_measuringUnitid_fkey" FOREIGN KEY ("measuringUnitid") REFERENCES "MeasuringUnit"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_paymentTypeid_fkey" FOREIGN KEY ("paymentTypeid") REFERENCES "PaymentType"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" ADD CONSTRAINT "ContractFinancialDetailSchedule_currencyid_fkey" FOREIGN KEY ("currencyid") REFERENCES "Currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" ADD CONSTRAINT "ContractFinancialDetailSchedule_measuringUnitid_fkey" FOREIGN KEY ("measuringUnitid") REFERENCES "MeasuringUnit"("id") ON DELETE SET NULL ON UPDATE CASCADE;
