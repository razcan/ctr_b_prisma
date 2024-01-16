
import {Partners} from '../../partners/entities/partners.entity'


export class Banks {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
bank: string  | null;
currency: string  | null;
branch: string  | null;
iban: string  | null;
status: string  | null;
partner?: Partners ;
partnerId: number ;
}
