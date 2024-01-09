import { PartialType } from '@nestjs/mapped-types';
import { CreateContractDto } from './create-contract.dto';

export class UpdateContractDto extends PartialType(CreateContractDto) {
    number: string;
    type: string;
    partner: string;
    status: string;
    start: Date;
    end: Date;
    sign: Date;
    completion: Date;
    remarks: string;
}
