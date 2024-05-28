
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'
import {InvoiceItem} from '../../invoiceItem/entities/invoiceItem.entity'
import {InvoiceDetail} from '../../invoiceDetail/entities/invoiceDetail.entity'


export class MeasuringUnit {
  id: number ;
name: string ;
ContractFinancialDetail?: ContractFinancialDetail[] ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
InvoiceItem?: InvoiceItem[] ;
InvoiceDetail?: InvoiceDetail[] ;
}
