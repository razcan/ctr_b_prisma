
import {RoleUser} from '../../roleUser/entities/roleUser.entity'
import {UserGroups} from '../../userGroups/entities/userGroups.entity'


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
User_Groups?: UserGroups[] ;
}
