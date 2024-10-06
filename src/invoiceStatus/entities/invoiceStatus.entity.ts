
import {Invoice} from '../../invoice/entities/invoice.entity'
import {Transactions} from '../../transactions/entities/transactions.entity'


export class InvoiceStatus {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
name: string ;
Invoice?: Invoice[] ;
Transactions?: Transactions[] ;
}
