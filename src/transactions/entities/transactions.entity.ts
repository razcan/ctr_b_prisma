
import {Partners} from '../../partners/entities/partners.entity'
import {Currency} from '../../currency/entities/currency.entity'
import {PaymentType} from '../../paymentType/entities/paymentType.entity'
import {Banks} from '../../banks/entities/banks.entity'
import {User} from '../../user/entities/user.entity'
import {InvoiceStatus} from '../../invoiceStatus/entities/invoiceStatus.entity'
import {TransactionDetail} from '../../transactionDetail/entities/transactionDetail.entity'


export class Transactions {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
partner?: Partners  | null;
partnerId: number  | null;
entity?: Partners  | null;
entityId: number  | null;
number: string ;
date: Date ;
currency?: Currency  | null;
currencyId: number  | null;
paymentValue: number ;
exchangeRate: number ;
eqvTotalPayment: number ;
type?: PaymentType  | null;
typeId: number  | null;
entityBank?: Banks  | null;
entitybankId: number  | null;
PartnerBank?: Banks  | null;
partnerbankId: number  | null;
bank: number  | null;
cash: number  | null;
card: number  | null;
meal: number  | null;
remarks: string  | null;
user?: User ;
userId: number ;
status?: InvoiceStatus  | null;
statusId: number  | null;
TransactionDetail?: TransactionDetail[] ;
}
