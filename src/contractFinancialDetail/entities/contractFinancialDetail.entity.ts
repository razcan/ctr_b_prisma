
import {Currency} from '../../currency/entities/currency.entity'
import {MeasuringUnit} from '../../measuringUnit/entities/measuringUnit.entity'
import {PaymentType} from '../../paymentType/entities/paymentType.entity'
import {Bank} from '../../bank/entities/bank.entity'
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'
import {VatQuota} from '../../vatQuota/entities/vatQuota.entity'
import {Invoice} from '../../invoice/entities/invoice.entity'


export class ContractFinancialDetail {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
itemid: number  | null;
price: number ;
currency?: Currency  | null;
currencyid: number  | null;
currencyValue: number  | null;
currencyPercent: number  | null;
billingDay: number ;
billingQtty: number ;
billingFrequencyid: number  | null;
measuringUnit?: MeasuringUnit  | null;
measuringUnitid: number  | null;
paymentType?: PaymentType  | null;
paymentTypeid: number  | null;
billingPenaltyPercent: number ;
billingDueDays: number ;
remarks: string  | null;
guaranteeLetter: boolean  | null;
guaranteecurrency?: Currency  | null;
guaranteeLetterCurrencyid: number  | null;
guaranteeLetterDate: Date  | null;
guaranteeLetterValue: number  | null;
guaranteeLetterInfo: string  | null;
guaranteeLetterBank?: Bank  | null;
guaranteeLetterBankId: number  | null;
goodexecutionLetter: boolean  | null;
goodexecutionLetterCurrency?: Currency  | null;
goodexecutionLetterCurrencyId: number  | null;
goodexecutionLetterDate: Date  | null;
goodexecutionLetterValue: number  | null;
goodexecutionLetterInfo: string  | null;
goodexecutionLetterBank?: Bank  | null;
goodexecutionLetterBankId: number  | null;
active: boolean  | null;
items?: ContractItems  | null;
contractItemId: number  | null;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
advancePercent: number  | null;
vat?: VatQuota  | null;
vatId: number  | null;
Invoice?: Invoice[] ;
}
