
import {Partners} from '../../partners/entities/partners.entity'
import {User} from '../../user/entities/user.entity'


export class Groups {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
name: string  | null;
description: string  | null;
entity?: Partners[] ;
User?: User[] ;
}
