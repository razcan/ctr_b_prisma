
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {Invoice} from '../../invoice/entities/invoice.entity'
import {PartnersBanksExtraRates} from '../../partnersBanksExtraRates/entities/partnersBanksExtraRates.entity'


export class Currency {
  id: number ;
code: string ;
name: string ;
ContractItems?: ContractItems[] ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
item?: ContractFinancialDetail[] ;
guarantee?: ContractFinancialDetail[] ;
goodexecution?: ContractFinancialDetail[] ;
Invoice?: Invoice[] ;
PartnersBanksExtraRates?: PartnersBanksExtraRates[] ;
}
