
import {Invoice} from '../../invoice/entities/invoice.entity'
import {Transactions} from '../../transactions/entities/transactions.entity'


export class DocumentSeries {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
entityId: number ;
updatedByUserId: number ;
documentTypeId: number ;
series: string ;
start_number: number ;
final_number: number ;
last_number: number ;
isActive: boolean ;
Invoice?: Invoice[] ;
Transactions?: Transactions[] ;
}
