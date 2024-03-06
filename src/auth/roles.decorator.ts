import { SetMetadata } from '@nestjs/common';

export const Roles = (...roles: ('Administrator' | 'Reader' | 'Requestor' | 'Editor')[]) => SetMetadata('roles', roles);