
import {Partners} from '../../partners/entities/partners.entity'
import {Contracts} from '../../contracts/entities/contracts.entity'
import {Invoice} from '../../invoice/entities/invoice.entity'
import {Transactions} from '../../transactions/entities/transactions.entity'


export class Banks {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
bank: string  | null;
currency: string  | null;
branch: string  | null;
iban: string  | null;
status: boolean  | null;
isDefault: boolean  | null;
partner?: Partners ;
partnerId: number ;
Contracts?: Contracts[] ;
Enity?: Contracts[] ;
Invoice?: Invoice[] ;
TransactionsEntity?: Transactions[] ;
TransactionsPartner?: Transactions[] ;
}
