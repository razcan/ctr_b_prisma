

export class CreateInvoiceDto {
  partnerId?: number | null;
  entityId?: number | null;
  number: string;
  date: Date;
  duedate: Date;
  totalAmount: number;
  vatAmount: number;
  totalPayment: number;
  typeId?: number | null;
  transactionTypeId?: number | null;
  statusId?: number | null;
  entitybankId?: number | null;
  partneraddressId?: number | null;
  currencyRate: number;
  userId: number;
  currencyId?: number | null;
  remarks: string;
  seriesId?: number | null;
  serialNumber: string;
  eqvTotalAmount: number;
  eqvVatAmount: number;
  eqvTotalPayment: number;
  vatOnReceipt: boolean;
}
