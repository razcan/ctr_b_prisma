
import {User} from '../../user/entities/user.entity'
import {Role} from '../../role/entities/role.entity'


export class RoleUser {
  id: number ;
user?: User ;
userId: number ;
role?: Role ;
roleId: number ;
}
