
import {Invoice} from '../../invoice/entities/invoice.entity'
import {Partners} from '../../partners/entities/partners.entity'
import {MeasuringUnit} from '../../measuringUnit/entities/measuringUnit.entity'
import {VatQuota} from '../../vatQuota/entities/vatQuota.entity'
import {Item} from '../../item/entities/item.entity'


export class InvoiceDetail {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
invoice?: Invoice ;
invoiceId: number ;
entity?: Partners ;
entityId: number ;
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
item?: Item  | null;
itemId: number  | null;
}
