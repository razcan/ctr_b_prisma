
import {User} from '../../user/entities/user.entity'


export class ForgotPass {
  id: number ;
updatedAt: Date ;
createdAt: Date ;
email: string ;
actual_password: string ;
old_password: string ;
uuid: string ;
user?: User ;
userId: number ;
}
