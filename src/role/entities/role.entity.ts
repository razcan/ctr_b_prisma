
import {RoleUser} from '../../roleUser/entities/roleUser.entity'
import {Groups} from '../../groups/entities/groups.entity'


export class Role {
  id: number ;
roleName: string ;
users?: RoleUser[] ;
Groups?: Groups[] ;
}
