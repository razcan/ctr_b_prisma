
import {Role} from '@prisma/client'
import {Post} from '../../post/entities/post.entity'
import {ExtendedProfile} from '../../extendedProfile/entities/extendedProfile.entity'


export class User {
  id: number ;
name: string  | null;
email: string ;
profileViews: number ;
role: Role ;
coinflips: boolean[] ;
posts?: Post[] ;
profile?: ExtendedProfile  | null;
}
