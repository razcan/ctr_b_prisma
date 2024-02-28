
import {ContractType} from '../../contractType/entities/contractType.entity'


export class ContractTemplates {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
name: string ;
active: boolean ;
contractType?: ContractType  | null;
contractTypeId: number  | null;
notes: string ;
content: string ;
}
