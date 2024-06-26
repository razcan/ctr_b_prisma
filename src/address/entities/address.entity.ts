
import {Partners} from '../../partners/entities/partners.entity'
import {Contracts} from '../../contracts/entities/contracts.entity'
import {Invoice} from '../../invoice/entities/invoice.entity'


export class Address {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
addressName: string  | null;
addressType: string  | null;
Country: string  | null;
County: string  | null;
City: string  | null;
Street: string  | null;
Number: string  | null;
postalCode: string  | null;
Status: boolean  | null;
Default: boolean  | null;
aggregate: boolean  | null;
completeAddress: string  | null;
partner?: Partners ;
partnerId: number ;
Contracts?: Contracts[] ;
Entity?: Contracts[] ;
Invoice?: Invoice[] ;
}
