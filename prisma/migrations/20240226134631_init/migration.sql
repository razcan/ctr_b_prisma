-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_guaranteeLetterCurrencyid_fkey" FOREIGN KEY ("guaranteeLetterCurrencyid") REFERENCES "Currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;
