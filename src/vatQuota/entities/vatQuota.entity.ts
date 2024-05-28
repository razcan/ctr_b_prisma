
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'


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
}
