





export class CreateTransactionsDto {
  number: string;
date: Date;
paymentValue: number;
exchangeRate: number;
eqvTotalPayment: number;
bank?: number;
cash?: number;
card?: number;
meal?: number;
remarks?: string;
}
