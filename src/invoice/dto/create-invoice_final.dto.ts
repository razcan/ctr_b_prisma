// create-invoice.dto.ts
import { IsNotEmpty, IsNumber, IsString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class CreateInvoiceDetailDto {
    @IsString()
    @IsNotEmpty()
    description: string;

    @IsNumber()
    @IsNotEmpty()
    quantity: number;

    @IsNumber()
    @IsNotEmpty()
    price: number;
}

export class CreateInvoiceDto {
    @IsString()
    @IsNotEmpty()
    number: string;

    @IsNotEmpty()
    date: Date;

    @IsNumber()
    @IsNotEmpty()
    totalAmount: number;

    @IsNumber()
    @IsNotEmpty()
    vatAmount: number;

    @ValidateNested({ each: true })
    @Type(() => CreateInvoiceDetailDto)
    details: CreateInvoiceDetailDto[];
}
