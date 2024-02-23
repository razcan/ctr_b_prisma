
import {Contracts} from '../../contracts/entities/contracts.entity'
import {ContractItems} from '../../contractItems/entities/contractItems.entity'


export class Item {
  id: number ;
name: string ;
contractId?: Contracts[] ;
ContractItems?: ContractItems[] ;
}
