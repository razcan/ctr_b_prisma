
import {RoleUser} from '../../roleUser/entities/roleUser.entity'
import {Groups} from '../../groups/entities/groups.entity'


export class User {
  id: number ;
updatedAt: Date ;
createdAt: Date ;
name: string ;
email: string ;
password: string ;
roles?: RoleUser[] ;
status: boolean ;
picture: string  | null;
User_Groups?: Groups[] ;
}
