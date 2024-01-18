
import {Partners} from '../../partners/entities/partners.entity'


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
}
