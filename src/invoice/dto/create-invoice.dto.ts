





export class CreateInvoiceDto {
  number: string;
date: Date;
duedate: Date;
totalAmount: number;
vatAmount: number;
totalPayment: number;
currencyRate: number;
remarks: string;
serialNumber: string;
eqvTotalAmount: number;
eqvVatAmount: number;
eqvTotalPayment: number;
vatOnReceipt: boolean;
parentId?: number;
movement_type: number;
allocationSummary?: string;
}
