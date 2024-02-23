-- AddForeignKey
ALTER TABLE "ContractItems" ADD CONSTRAINT "ContractItems_itemid_fkey" FOREIGN KEY ("itemid") REFERENCES "Item"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractItems" ADD CONSTRAINT "ContractItems_billingFrequencyid_fkey" FOREIGN KEY ("billingFrequencyid") REFERENCES "BillingFrequency"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractItems" ADD CONSTRAINT "ContractItems_currencyid_fkey" FOREIGN KEY ("currencyid") REFERENCES "Currency"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
