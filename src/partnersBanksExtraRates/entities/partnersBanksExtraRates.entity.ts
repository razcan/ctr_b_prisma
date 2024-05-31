
import {Partners} from '../../partners/entities/partners.entity'
import {Currency} from '../../currency/entities/currency.entity'


export class PartnersBanksExtraRates {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
partners?: Partners  | null;
partnersId: number  | null;
currency?: Currency  | null;
currencyId: number  | null;
percent: number  | null;
}
