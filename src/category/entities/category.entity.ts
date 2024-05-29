
import {Contracts} from '../../contracts/entities/contracts.entity'
import {Item} from '../../item/entities/item.entity'


export class Category {
  id: number ;
name: string ;
contractId?: Contracts[] ;
Item?: Item[] ;
}
