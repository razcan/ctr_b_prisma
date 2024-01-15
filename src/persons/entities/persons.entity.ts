
import {Partners} from '../../partners/entities/partners.entity'


export class Persons {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
name: string ;
phone: string ;
email: string ;
legalrepresent: string ;
role: string ;
partner?: Partners ;
partnerId: number ;
}
