
import {ContractType} from '../../contractType/entities/contractType.entity'
import {CostCenter} from '../../costCenter/entities/costCenter.entity'
import {ContractStatus} from '../../contractStatus/entities/contractStatus.entity'
import {Category} from '../../category/entities/category.entity'
import {Department} from '../../department/entities/department.entity'
import {Cashflow} from '../../cashflow/entities/cashflow.entity'
import {Item} from '../../item/entities/item.entity'
import {Partners} from '../../partners/entities/partners.entity'
import {Persons} from '../../persons/entities/persons.entity'
import {Address} from '../../address/entities/address.entity'
import {Banks} from '../../banks/entities/banks.entity'
import {PaymentType} from '../../paymentType/entities/paymentType.entity'
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractAttachments} from '../../contractAttachments/entities/contractAttachments.entity'
import {ContractContent} from '../../contractContent/entities/contractContent.entity'


export class Contracts {
  id: number ;
number: string ;
type?: ContractType ;
typeId: number ;
costcenter?: CostCenter ;
costcenterId: number ;
status?: ContractStatus ;
statusId: number ;
start: Date ;
end: Date ;
sign: Date ;
completion: Date ;
remarks: string ;
Category?: Category  | null;
categoryId: number  | null;
departament?: Department  | null;
departmentId: number  | null;
cashflow?: Cashflow  | null;
cashflowId: number  | null;
item?: Item ;
itemId: number ;
automaticRenewal: boolean ;
partner?: Partners  | null;
partnersId: number  | null;
entity?: Partners  | null;
entityId: number  | null;
parentId: number  | null;
PartnerPerson?: Persons  | null;
partnerpersonsId: number  | null;
EntityPerson?: Persons  | null;
entitypersonsId: number  | null;
EntityAddress?: Address  | null;
entityaddressId: number  | null;
PartnerAddress?: Address  | null;
partneraddressId: number  | null;
EntityBank?: Banks  | null;
entitybankId: number  | null;
PartnerBank?: Banks  | null;
partnerbankId: number  | null;
PaymentType?: PaymentType  | null;
paymentTypeId: number  | null;
ContractItems?: ContractItems[] ;
ContractAttachments?: ContractAttachments[] ;
ContractContent?: ContractContent[] ;
}
