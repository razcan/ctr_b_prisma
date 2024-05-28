
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {InvoiceDetail} from '../../invoiceDetail/entities/invoiceDetail.entity'
import {InvoiceItem} from '../../invoiceItem/entities/invoiceItem.entity'


export class VatQuota {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
VatCode: string ;
VATDescription: string ;
VATPercent: number ;
VATType: number ;
AccVATPercent: number ;
ContractFinancialDetail?: ContractFinancialDetail[] ;
InvoiceDetail?: InvoiceDetail[] ;
InvoiceItem?: InvoiceItem[] ;
}
