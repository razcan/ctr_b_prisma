
import {ContractsDetails} from '../../contractsDetails/entities/contractsDetails.entity'
import {Partners} from '../../partners/entities/partners.entity'


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
entity: string ;
contract?: ContractsDetails[] ;
partner?: Partners  | null;
partnersId: number  | null;
}
