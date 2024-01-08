
import {Prisma} from '@prisma/client'




export class CreatePostDto {
  title: string;
comments?: Prisma.InputJsonValue;
}
