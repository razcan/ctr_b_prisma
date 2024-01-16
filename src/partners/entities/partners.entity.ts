
import {Contracts} from '../../contracts/entities/contracts.entity'
import {Persons} from '../../persons/entities/persons.entity'
import {Address} from '../../address/entities/address.entity'


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
contractsId: number  | null;
Contracts?: Contracts[] ;
Persons?: Persons[] ;
Address?: Address[] ;
}
