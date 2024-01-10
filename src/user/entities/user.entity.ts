
import {Role} from '@prisma/client'


export class User {
  id: number ;
name: string  | null;
email: string ;
password: string ;
role: Role ;
}
