





export class CreateTransactionsDto {
  number: number;
date: Date;
paymentValue: number;
exchangeRate: number;
eqvTotalPayment: number;
bank?: number;
cash?: number;
card?: number;
meal?: number;
remarks?: string;
movement_type: number;
}
