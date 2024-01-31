
import {Contracts} from '../../contracts/entities/contracts.entity'


export class ContractAttachments {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
name: string ;
size: number ;
lastModifiedDate: Date  | null;
dbname: string  | null;
path: string  | null;
destination: string  | null;
mimetype: string  | null;
originalname: string  | null;
contractId?: Contracts[] ;
}
