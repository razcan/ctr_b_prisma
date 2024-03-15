





export class CreateContractsDto {
  number: string;
start: Date;
end: Date;
sign?: Date;
completion?: Date;
remarks?: string;
automaticRenewal?: boolean;
parentId?: number;
isPurchasing?: boolean;
}
