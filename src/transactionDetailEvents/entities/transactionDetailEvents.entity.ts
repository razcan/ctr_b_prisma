
import {TransactionDetail} from '../../transactionDetail/entities/transactionDetail.entity'
import {Invoice} from '../../invoice/entities/invoice.entity'
import {Partners} from '../../partners/entities/partners.entity'
import {Currency} from '../../currency/entities/currency.entity'


export class TransactionDetailEvents {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
transactionDetail?: TransactionDetail  | null;
transactionDetailId: number  | null;
invoice?: Invoice ;
invoiceId: number ;
entity?: Partners  | null;
entityId: number  | null;
partner?: Partners  | null;
partnerId: number  | null;
partPaymentValue: number ;
eqvTotalPayment: number ;
restAmount: number ;
payFromDate: Date ;
payToDate: Date ;
currency?: Currency  | null;
currencyId: number  | null;
}
