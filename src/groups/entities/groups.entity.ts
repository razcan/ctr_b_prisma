
import {Partners} from '../../partners/entities/partners.entity'
import {Role} from '../../role/entities/role.entity'
import {UserGroups} from '../../userGroups/entities/userGroups.entity'


export class Groups {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
name: string  | null;
description: string  | null;
entity?: Partners  | null;
entityId: number  | null;
role?: Role  | null;
roleId: number  | null;
User_Groups?: UserGroups[] ;
}
