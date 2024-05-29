
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'
import {InvoiceDetail} from '../../invoiceDetail/entities/invoiceDetail.entity'
import {Item} from '../../item/entities/item.entity'


export class MeasuringUnit {
  id: number ;
name: string ;
ContractFinancialDetail?: ContractFinancialDetail[] ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
InvoiceDetail?: InvoiceDetail[] ;
Item?: Item[] ;
}
