import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {

    // const contractType = [
    //     { name: "Contracte de Vanzare-Cumparare" },
    //     { name: "Contracte de inchiriere" },
    //     { name: "Contracte de servicii" },
    //     { name: "Contracte de parteneriat" },
    //     { name: "Contracte de colaborare" },
    //     { name: "Contracte de constructie" },
    //     { name: "Contracte de licentiere" },
    //     { name: "Contracte de franciză" },
    //     { name: "Contracte de imprumut" },
    //     { name: "Contracte de agent" },
    //     { name: "Contracte de dezvoltare Software" },
    //     { name: "Contracte de asigurare" },
    //     { name: "Contracte imobiliare" },
    //     { name: "Contracte de mentenanta" },
    //     { name: "Contracte abonament" },
    //     { name: "Contract de schimb" },
    //     { name: "Contract de report" },
    //     { name: "Contract de antrepriză" },
    //     { name: "Contract de asociere în participație" },
    //     { name: "Contract de transport" },
    //     { name: "Contract de mandat" },
    //     { name: "Contract de comision" },
    //     { name: "Contract de consignație" },
    //     { name: "Contract de agenție" },
    //     { name: "Contract de intermediere" },
    //     { name: "Contract de depozit" },
    //     { name: "Contract de cont curent" },
    //     { name: "Contract de joc și pariu" },
    //     { name: "Contract de donație" },
    //     { name: "Contract de fiducie" },
    //     { name: "Contract de leasing" },
    //     { name: "Contract de factoring" }
    // ];


    // const contractStatus = [
    //     { name: 'In lucru' },
    //     { name: 'Asteapta aprobarea' },
    //     { name: 'In curs de revizuire' },
    //     { name: 'Aprobat' },
    //     { name: 'In executie' },
    //     { name: 'Activ' },
    //     { name: 'Expirat' },
    //     { name: 'Finalizat' },
    //     { name: 'Reinnoit' },
    //     { name: 'Modificat' },
    //     { name: 'Inchis inainte de termen' },
    //     { name: 'Contestat' },
    // ]

    // const cashflowLines = [
    //     { name: 'Incasari operationale' },
    //     { name: 'Incasari financiare' },
    //     { name: 'Plati operationale' },
    //     { name: 'Plati investitionale' },
    //     { name: 'Plati financiare' },
    //     { name: 'Tranzactii InterCompany' },
    //     { name: 'Salarii' },
    //     { name: 'Furnizori activitate curenta' },
    //     { name: 'Utilitati' },
    //     { name: 'Auto combustibili si reparatii' },
    //     { name: 'Paza' },
    //     { name: 'Publicitate si sponsorizare' },
    //     { name: 'Deplasari + diurne' },
    //     { name: 'Marfa MUDR' },
    //     { name: 'Restituiri clienti' },
    //     { name: 'Investitii in curs' },
    //     { name: 'Investitii finalizate' },
    //     { name: 'Asigurari/ leasing , comisioane banci' },
    //     { name: 'Restituire credite si dobanzi' },
    //     { name: 'Impozit pe profit' },
    //     { name: 'Impozite locale' },
    //     { name: 'TVA de plata  ' },
    //     { name: 'Taxa salarii' },
    //     { name: 'Tranzactii intercompany' },
    //     { name: 'Transfer bancar(credit)' },
    //     { name: 'Transfer bancar(debit)' },
    //     { name: 'Plati Deconturi' },
    //     { name: 'Investitii Proprii' },
    //     { name: 'Compensari/Girari/Retururi' }]

    // const costcenters = [
    //     { name: 'Abonamente RATB' },
    //     { name: 'Achizitii carti de specialitate' },
    //     { name: 'Achizitii de specialitate' },
    //     { name: 'Achizitii produse auto' },
    //     { name: 'Administratia pietelor' },
    //     { name: 'Administratie' },
    //     { name: 'Alpinisti utilitari' },
    //     { name: 'Alte cheltuieli' },
    //     { name: 'Alte cheltuieli si evenimente' },
    //     { name: 'Alte facilitati - masa personal, utilitati, servicii, abonamente RATB' },
    //     { name: 'Alte facilitati personal alte persoane' },
    //     { name: 'Alte obiective' },
    //     { name: 'Alte taxe (Reg. comert, mediu, urbanism, avize)' },
    //     { name: 'Altele' },
    //     { name: 'Amenajare incinta' },
    //     { name: 'Andimed - medicina muncii' },
    //     { name: 'Anunturi piblicitare, taxe postale si alte taxe' },
    //     { name: 'Anunturi publicitare, taxe postale' },
    //     { name: 'Apa' },
    //     { name: 'Apa menajera' },
    //     { name: 'Apartamente' },
    //     { name: 'Apele Romane' },
    //     { name: 'Ascensorul Schindler - servicii mentenanta' },
    //     { name: 'Asigurari auto casco si RCA' },
    //     { name: 'Asigurari cladiri si de viata' },
    //     { name: 'Autofinantare' },
    //     { name: 'Autorizatie/Licenta utilizare muzica' },
    //     { name: 'Bonuri de masa' },
    //     { name: 'Bonuri de masa alte persoane' },
    //     { name: 'Bugetul Managerului General' },
    //     { name: 'Carburant Auto' },
    //     { name: 'Carburant auto personal Tesa' },
    //     { name: 'Cheltuieli administrare si intretinere' },
    //     { name: 'Cheltuieli Comunicare' },
    //     { name: 'Cheltuieli comunicare' },
    //     { name: 'Cheltuieli cu personalul' },
    //     { name: 'Cheltuieli financiare' },
    //     { name: 'Cheltuieli imagine' },
    //     { name: 'Cheltuieli linie CFR / taxa drumuri/ taxa poduri' },
    //     { name: 'Cheltuieli Neprevazute' },
    //     { name: 'Cheltuieli neprevazute' },
    //     { name: 'Cheltuieli personal alte obiective fara profit' },
    //     { name: 'Cheltuieli personal Tesa' },
    //     { name: 'Cheltuieli sp. SNCFR ' },
    //     { name: 'Cheltuieli transport' },
    //     { name: 'Cheltuieli utilitati' }]

    // const Currency = [
    //     { code: "RON", name: "LEU" },
    //     { code: "EUR", name: "Euro" },
    //     { code: "USD", name: "Dolarul SUA" },
    //     { code: "CHF", name: "Francul elveţian" },
    //     { code: "GBP", name: "Lira sterlină" },
    //     { code: "BGN", name: "Leva bulgarească" },
    //     { code: "RUB", name: "Rubla rusească" },
    //     { code: "ZAR", name: "Randul sud-african" },
    //     { code: "BRL", name: "Realul brazilian" },
    //     { code: "CNY", name: "Renminbi-ul chinezesc" },
    //     { code: "INR", name: "Rupia indiană" },
    //     { code: "MXN", name: "Peso-ul mexican" },
    //     { code: "NZD", name: "Dolarul neo-zeelandez" },
    //     { code: "RSD", name: "Dinarul sârbesc" },
    //     { code: "UAH", name: "Hryvna ucraineană" },
    //     { code: "TRY", name: "Noua lira turcească" },
    //     { code: "AUD", name: "Dolarul australian" },
    //     { code: "CAD", name: "Dolarul canadian" },
    //     { code: "CZK", name: "Coroana cehă" },
    //     { code: "DKK", name: "Coroana daneză" },
    //     { code: "EGP", name: "Lira egipteană" },
    //     { code: "HUF", name: "Forinți maghiari" },
    //     { code: "JPY", name: "Yeni japonezi" },
    //     { code: "MDL", name: "Leul moldovenesc" },
    //     { code: "NOK", name: "Coroana norvegiană" },
    //     { code: "PLN", name: "Zlotul polonez" },
    //     { code: "SEK", name: "Coroana suedeză" },
    //     { code: "AED", name: "Dirhamul Emiratelor Arabe" },
    //     { code: "THB", name: "Bahtul thailandez" }
    // ]


    // const Banks = [
    //     { name: "Alpha Bank" },
    //     { name: "BRCI" },
    //     { name: "Banca FEROVIARA" },
    //     { name: "Intesa Sanpaolo" },
    //     { name: "BCR" },
    //     { name: "BCR Banca pentru Locuinţe" },
    //     { name: "Eximbank" },
    //     { name: "Banca Românească" },
    //     { name: "Banca Transilvania" },
    //     { name: "Leumi" },
    //     { name: "BRD" },
    //     { name: "CEC Bank" },
    //     { name: "Crédit Agricole" },
    //     { name: "Credit Europe" },
    //     { name: "Garanti Bank" },
    //     { name: "Idea Bank" },
    //     { name: "Libra Bank" },
    //     { name: "Vista Bank" },
    //     { name: "OTP Bank" },
    //     { name: "Patria Bank" },
    //     { name: "First Bank" },
    //     { name: "Porsche Bank" },
    //     { name: "ProCredit Bank" },
    //     { name: "Raiffeisen" },
    //     { name: "Aedificium Banca pentru Locuinte" },
    //     { name: "UniCredit" },
    //     { name: "Alior Bank" },
    //     { name: "BLOM Bank France" },
    //     { name: "BNP Paribas" },
    //     { name: "Citibank" },
    //     { name: "ING" },
    //     { name: "TBI " }]



    // for (const type of contractType) {
    //     await prisma.contractType.create({
    //         data: type,
    //     });
    // }

    // for (const status of contractStatus) {
    //     await prisma.contractStatus.create({
    //         data: status,
    //     });
    // }

    // for (const cf of cashflowLines) {
    //     await prisma.cashflow.create({
    //         data: cf,
    //     });
    // }

    // for (const cc of costcenters) {
    //     await prisma.costCenter.create({
    //         data: cc,
    //     });
    // }

    // for (const currency of Currency) {
    //     await prisma.currency.create({
    //         data: currency,
    //     });
    // }

    // for (const bank of Banks) {
    //     await prisma.bank.create({
    //         data: bank,
    //     });
    // }

    // const PaymentType = [
    //     { name: "Numerar" },
    //     { name: "Ordin de Plată" },
    //     { name: "Cec" },
    //     { name: "Bilet la ordin" },
    //     { name: "Transfer Bancar" },
    //     { name: "Virament Bancar" },
    //     { name: "Portofel Digital(PayPal, Venmo...)" },
    //     { name: "Bitcoin și Criptomonede" },
    //     { name: "Card de Debit" },
    //     { name: "Card de Credit" }]

    // const Frequency = [
    //     { name: "Zilnic" },
    //     { name: "Săptămânal" },
    //     { name: "Lunar" },
    //     { name: "Trimestrial" },
    //     { name: "Semestrial" },
    //     { name: "Anual" },
    //     { name: "Personalizat" }
    // ]

    // const MeasuringUnit = [
    //     { name: "Lună (lună)" },
    //     { name: "Oră (h)" },
    //     { name: "Zi (zi)" },
    //     { name: "An (an)" },
    //     { name: "Metru (m)" },
    //     { name: "Metru pătrat (m²)" },
    //     { name: "Centimetru (cm)" },
    //     { name: "Centimetru pătrat (cm²)" },
    //     { name: "Kilometru (km)" },
    //     { name: "Milimetru (mm)" },
    //     { name: "Milă (mi)" },
    //     { name: "Gram (g)" },
    //     { name: "Kilogram (kg)" },
    //     { name: "Tona metrică (t)" },
    //     { name: "Miligram (mg)" },
    //     { name: "Centigram (cg)" },
    //     { name: "Uncie (oz)" },
    //     { name: "Mililitru (ml)" },
    //     { name: "Centilitru (cl)" },
    //     { name: "Secundă (s)" },
    //     { name: "Minut (min)" },
    //     { name: "Săptămână (săptămână)" },
    //     { name: "Centimetru cub (cm³ sau cc)" },
    //     { name: "Metru cub (m³)" },
    //     { name: "Mililitru (ml)" },
    //     { name: "Hectolitră (hl)" },
    //     { name: "Calorie (cal)" },
    //     { name: "Kilocalorie (kcal)" },
    //     { name: "Watt-ora (Wh)" },
    //     { name: "Kilowatt-ora (kWh)" },
    //     { name: "Hectare (ha)" }]

    // for (const measuringunit of MeasuringUnit) {
    //     await prisma.measuringUnit.create({
    //         data: measuringunit,
    //     });
    // }


    // for (const frequency of Frequency) {
    //     await prisma.billingFrequency.create({
    //         data: frequency,
    //     });
    // }


    // for (const frequency of Frequency) {
    //     await prisma.billingFrequency.create({
    //         data: frequency,
    //     });
    // }

    // for (const type of PaymentType) {
    //     await prisma.PaymentType.create({
    //         data: type,
    //     });
    // }

    // prisma.$executeRaw(`
    //     INSERT INTO public."Alerts"
    //     ( "name", "isActive", subject, "text", internal_emails, nrofdays, param, "isActivePartner", "isActivePerson")
    //     VALUES
    //     ('Contract Inchis inainte de termen', false, 'Contract Inchis inainte de termen', 
    //     'Va informam faptul ca urmeaza sa expire contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract este in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.', 
    //     'office@companie.ro',30, 'Data Final Contract', false, false);
    //     `
    // )

    await prisma.alerts.create({
        data: [
            {
                name: "Contract Inchis inainte de termen",
                isActive: true,
                subject: "Contract Inchis inainte de termen",
                text: "Va informam faptul ca a fost inchis contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract a fost in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.",
                internal_emails: "office@companie.ro",
                nrofdays: 0,
                param: "Inchis la data",
                isActivePartner: false,
                isActivePerson: false
            },
            {
                name: "Expirare Contract",
                isActive: true,
                subject: "Expirare Contract",
                text: "Va informam faptul ca urmeaza sa expire contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract este in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.",
                internal_emails: "office@companie.ro",
                nrofdays: 30,
                param: "Inchis la data",
                isActivePartner: false,
                isActivePerson: false
            },
        ]
    });


    console.log('Seed completed');
}
main()
    .then(async () => {
        await prisma.$disconnect()
    })
    .catch(async (e) => {
        console.error(e)
        await prisma.$disconnect()
        process.exit(1)
    })