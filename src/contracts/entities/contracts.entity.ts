
import {ContractsDetails} from '../../contractsDetails/entities/contractsDetails.entity'


export class Contracts {
  id: number ;
number: string ;
type: string ;
partner: string ;
status: string ;
start: Date ;
end: Date ;
sign: Date ;
completion: Date ;
remarks: string ;
category: string ;
contract?: ContractsDetails[] ;
}
