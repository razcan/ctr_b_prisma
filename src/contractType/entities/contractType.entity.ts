
import {Contracts} from '../../contracts/entities/contracts.entity'
import {ContractTemplates} from '../../contractTemplates/entities/contractTemplates.entity'


export class ContractType {
  id: number ;
name: string ;
contractId?: Contracts[] ;
ContractTemplates?: ContractTemplates[] ;
}
