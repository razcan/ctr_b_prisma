
import {Contracts} from '../../contracts/entities/contracts.entity'


export class ContractContent {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
content: string ;
contract?: Contracts  | null;
contractId: number  | null;
}
