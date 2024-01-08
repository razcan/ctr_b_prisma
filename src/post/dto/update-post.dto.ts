
import {Prisma} from '@prisma/client'




export class UpdatePostDto {
  title?: string;
comments?: Prisma.InputJsonValue;
}
