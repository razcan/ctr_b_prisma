
import {Contracts} from '../../contracts/entities/contracts.entity'
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'


export class Item {
  id: number ;
name: string ;
contractId?: Contracts[] ;
ContractItems?: ContractItems[] ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
}
