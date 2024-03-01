
import {RoleUser} from '../../roleUser/entities/roleUser.entity'


export class Role {
  id: number ;
roleName: string ;
users?: RoleUser[] ;
}
