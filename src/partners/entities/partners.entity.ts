
import {Persons} from '../../persons/entities/persons.entity'
import {Address} from '../../address/entities/address.entity'
import {Banks} from '../../banks/entities/banks.entity'
import {Contracts} from '../../contracts/entities/contracts.entity'
import {Groups} from '../../groups/entities/groups.entity'
import {InvoiceDetail} from '../../invoiceDetail/entities/invoiceDetail.entity'
import {Invoice} from '../../invoice/entities/invoice.entity'
import {PartnersBanksExtraRates} from '../../partnersBanksExtraRates/entities/partnersBanksExtraRates.entity'
import {Transactions} from '../../transactions/entities/transactions.entity'
import {TransactionDetail} from '../../transactionDetail/entities/transactionDetail.entity'
import {TransactionDetailEvents} from '../../transactionDetailEvents/entities/transactionDetailEvents.entity'


export class Partners {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
name: string ;
fiscal_code: string ;
commercial_reg: string ;
state: string ;
type: string ;
email: string ;
remarks: string ;
isVatPayer: boolean ;
contractsId: number  | null;
paymentTerm: number  | null;
Persons?: Persons[] ;
Address?: Address[] ;
Banks?: Banks[] ;
Contracts?: Contracts[] ;
Entity?: Contracts[] ;
Groups?: Groups[] ;
InvoiceDetail?: InvoiceDetail[] ;
partnerInvoice?: Invoice[] ;
entityInvoice?: Invoice[] ;
PartnerBanksExtraRates?: PartnersBanksExtraRates[] ;
picture: string  | null;
TransactionsPartner?: Transactions[] ;
TransactionsEntity?: Transactions[] ;
TransactionDetailEntity?: TransactionDetail[] ;
TransactionDetailPartner?: TransactionDetail[] ;
TransactionDetailEventsEntity?: TransactionDetailEvents[] ;
TransactionDetailEventsPartner?: TransactionDetailEvents[] ;
}
