
import {Partners} from '../../partners/entities/partners.entity'


export class Persons {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
name: string ;
phone: string  | null;
email: string  | null;
legalrepresent: boolean  | null;
role: string  | null;
partner?: Partners ;
partnerId: number ;
}
