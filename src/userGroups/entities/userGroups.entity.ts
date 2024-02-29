
import {User} from '../../user/entities/user.entity'
import {Groups} from '../../groups/entities/groups.entity'
import {Partners} from '../../partners/entities/partners.entity'


export class UserGroups {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
user?: User ;
userId: number ;
group?: Groups ;
groupId: number ;
entity?: Partners  | null;
entityId: number  | null;
}
