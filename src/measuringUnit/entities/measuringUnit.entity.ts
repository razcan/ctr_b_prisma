
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'


export class MeasuringUnit {
  id: number ;
name: string ;
ContractFinancialDetail?: ContractFinancialDetail[] ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
}
