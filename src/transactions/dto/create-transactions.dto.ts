





export class CreateTransactionsDto {
  number: string;
date: Date;
paymentValue: number;
exchangeRate: number;
eqvTotalPayment: number;
cash?: number;
card?: number;
meal?: number;
remarks?: string;
}
