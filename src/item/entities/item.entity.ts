
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'


export class Item {
  id: number ;
name: string ;
ContractItems?: ContractItems[] ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
}
