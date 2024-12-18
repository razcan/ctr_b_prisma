
import {Partners} from '../../partners/entities/partners.entity'
import {InvoiceType} from '../../invoiceType/entities/invoiceType.entity'
import {TransactionType} from '../../transactionType/entities/transactionType.entity'
import {InvoiceStatus} from '../../invoiceStatus/entities/invoiceStatus.entity'
import {Banks} from '../../banks/entities/banks.entity'
import {Address} from '../../address/entities/address.entity'
import {User} from '../../user/entities/user.entity'
import {Currency} from '../../currency/entities/currency.entity'
import {InvoiceDetail} from '../../invoiceDetail/entities/invoiceDetail.entity'
import {DocumentSeries} from '../../documentSeries/entities/documentSeries.entity'
import {Contracts} from '../../contracts/entities/contracts.entity'
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'
import {TransactionDetail} from '../../transactionDetail/entities/transactionDetail.entity'
import {TransactionDetailEvents} from '../../transactionDetailEvents/entities/transactionDetailEvents.entity'


export class Invoice {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
partner?: Partners  | null;
partnerId: number  | null;
entity?: Partners  | null;
entityId: number  | null;
number: string ;
date: Date ;
duedate: Date ;
totalAmount: number ;
vatAmount: number ;
totalPayment: number ;
type?: InvoiceType  | null;
typeId: number  | null;
transaction?: TransactionType  | null;
transactionTypeId: number  | null;
status?: InvoiceStatus  | null;
statusId: number  | null;
entityBank?: Banks  | null;
entitybankId: number  | null;
partnerAddress?: Address  | null;
partneraddressId: number  | null;
currencyRate: number ;
user?: User ;
userId: number ;
currency?: Currency  | null;
currencyId: number  | null;
InvoiceDetail?: InvoiceDetail[] ;
remarks: string ;
series?: DocumentSeries  | null;
seriesId: number  | null;
serialNumber: string ;
eqvTotalAmount: number ;
eqvVatAmount: number ;
eqvTotalPayment: number ;
restPayment: number ;
vatOnReceipt: boolean ;
parentId: number  | null;
movement_type: number ;
contract?: Contracts  | null;
contractId: number  | null;
financialItem?: ContractFinancialDetail  | null;
contractfinancialItemId: number  | null;
financialItemScedule?: ContractFinancialDetailSchedule  | null;
contractFinancialScheduleId: number  | null;
allocationSummary: string  | null;
TransactionDetail?: TransactionDetail[] ;
TransactionDetailEvents?: TransactionDetailEvents[] ;
}
