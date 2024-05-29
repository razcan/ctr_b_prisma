
import {VatQuota} from '../../vatQuota/entities/vatQuota.entity'
import {MeasuringUnit} from '../../measuringUnit/entities/measuringUnit.entity'
import {Category} from '../../category/entities/category.entity'
import {User} from '../../user/entities/user.entity'
import {InvoiceDetail} from '../../invoiceDetail/entities/invoiceDetail.entity'
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'


export class Item {
  id: number ;
name: string ;
code: string  | null;
barCode: string  | null;
description: string  | null;
vat?: VatQuota  | null;
vatId: number  | null;
measuringUnit?: MeasuringUnit  | null;
measuringUnitid: number  | null;
isStockable: boolean ;
isActive: boolean ;
classification?: Category  | null;
classificationId: number  | null;
user?: User ;
userId: number ;
InvoiceDetail?: InvoiceDetail[] ;
ContractItems?: ContractItems[] ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
}
