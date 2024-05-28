
import {Invoice} from '../../invoice/entities/invoice.entity'
import {Partners} from '../../partners/entities/partners.entity'
import {InvoiceItem} from '../../invoiceItem/entities/invoiceItem.entity'
import {MeasuringUnit} from '../../measuringUnit/entities/measuringUnit.entity'
import {VatQuota} from '../../vatQuota/entities/vatQuota.entity'


export class InvoiceDetail {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
invoice?: Invoice ;
invoiceId: number ;
entity?: Partners ;
entityId: number ;
item?: InvoiceItem  | null;
itemId: number  | null;
qtty: number ;
price: number ;
measuringUnit?: MeasuringUnit  | null;
measuringUnitid: number  | null;
vat?: VatQuota  | null;
vatId: number  | null;
vatValue: number ;
lineValue: number ;
totalValue: number ;
description: string ;
}
