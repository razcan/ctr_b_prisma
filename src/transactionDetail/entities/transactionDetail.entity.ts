
import {Transactions} from '../../transactions/entities/transactions.entity'
import {Invoice} from '../../invoice/entities/invoice.entity'
import {Partners} from '../../partners/entities/partners.entity'
import {Currency} from '../../currency/entities/currency.entity'
import {TransactionDetailEvents} from '../../transactionDetailEvents/entities/transactionDetailEvents.entity'


export class TransactionDetail {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
transactions?: Transactions  | null;
transactionId: number  | null;
invoice?: Invoice  | null;
invoiceId: number  | null;
entity?: Partners  | null;
entityId: number  | null;
partner?: Partners  | null;
partnerId: number  | null;
partPaymentValue: number ;
currency?: Currency  | null;
currencyId: number  | null;
exchangeRate: number ;
eqvTotalPayment: number ;
TransactionDetailEvents?: TransactionDetailEvents[] ;
}
