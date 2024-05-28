
import {VatQuota} from '../../vatQuota/entities/vatQuota.entity'
import {MeasuringUnit} from '../../measuringUnit/entities/measuringUnit.entity'
import {InvoiceItemClassification} from '../../invoiceItemClassification/entities/invoiceItemClassification.entity'
import {User} from '../../user/entities/user.entity'
import {InvoiceDetail} from '../../invoiceDetail/entities/invoiceDetail.entity'


export class InvoiceItem {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
itemName: string ;
itemCode: string ;
barCode: string ;
itemDescription: string ;
vat?: VatQuota  | null;
vatId: number  | null;
measuringUnit?: MeasuringUnit  | null;
measuringUnitid: number  | null;
isStockable: boolean ;
isActive: boolean ;
classification?: InvoiceItemClassification  | null;
classificationId: number  | null;
user?: User ;
userId: number ;
InvoiceDetail?: InvoiceDetail[] ;
}
