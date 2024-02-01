
import {Contracts} from '../../contracts/entities/contracts.entity'


export class ContractAttachments {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
fieldname: string ;
originalname: string ;
encoding: string ;
mimetype: string ;
destination: string ;
filename: string ;
path: string ;
size: number ;
contractId?: Contracts[] ;
}
