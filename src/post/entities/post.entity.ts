
import {Prisma} from '@prisma/client'
import {User} from '../../user/entities/user.entity'
import {Category} from '../../category/entities/category.entity'


export class Post {
  id: number ;
title: string ;
published: boolean ;
author?: User ;
authorId: number ;
comments: Prisma.JsonValue  | null;
views: number ;
likes: number ;
categories?: Category[] ;
}
