
import {Partners} from '../../partners/entities/partners.entity'
import {Persons} from '../../persons/entities/persons.entity'
import {Address} from '../../address/entities/address.entity'
import {Banks} from '../../banks/entities/banks.entity'


export class Contracts {
  id: number ;
number: string ;
type: string ;
status: string ;
start: Date ;
end: Date ;
sign: Date ;
completion: Date ;
remarks: string ;
category: string ;
departament: string ;
cashflow: string ;
item: string ;
costcenter: string ;
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
}
