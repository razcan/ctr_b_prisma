
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'


export class Currency {
  id: number ;
code: string ;
name: string ;
ContractItems?: ContractItems[] ;
ContractFinancialDetail?: ContractFinancialDetail[] ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
}
