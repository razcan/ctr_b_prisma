import { IsString, IsOptional, IsInt } from 'class-validator';

export class UpdateContractFinancialDetailDto {
  itemid?: number;
  price: number;
  currencyValue?: number;
  currencyPercent?: number;
  billingDay: number;
  billingQtty: number;
  billingFrequencyid?: number;
  billingPenaltyPercent: number;
  billingDueDays: number;
  @IsOptional()
  remarks?: string;
  @IsOptional()
  guaranteeLetter?: boolean;
  @IsOptional()
  guaranteeLetterDate?: Date;
  @IsOptional()
  guaranteeLetterValue?: number;
  @IsOptional()
  guaranteeLetterInfo?: string;
  @IsOptional()
  goodexecutionLetter?: boolean;
  @IsOptional()
  goodexecutionLetterDate?: Date;
  @IsOptional()
  goodexecutionLetterValue?: number;
  @IsOptional()
  goodexecutionLetterInfo?: string;
  @IsOptional()
  active?: boolean;
  @IsOptional()
  advancePercent?: number;
  currencyid?: number;
  measuringUnitid?: number;
  paymentTypeid?: number;
  @IsOptional()
  guaranteeLetterCurrencyid?: number;
  @IsOptional()
  guaranteeLetterBankId?: number;
  @IsOptional()
  goodexecutionLetterCurrencyId?: number;
  @IsOptional()
  goodexecutionLetterBankId?: number;
  @IsOptional()
  contractItemId?: number;
  vatId?: number;
}

