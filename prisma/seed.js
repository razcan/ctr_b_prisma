import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {

    const contractType = [
        { name: "Contracte de Vanzare-Cumparare" },
        { name: "Contracte de inchiriere" },
        { name: "Contracte de servicii" },
        { name: "Contracte de parteneriat" },
        { name: "Contracte de colaborare" },
        { name: "Contracte de constructie" },
        { name: "Contracte de licentiere" },
        { name: "Contracte de franciză" },
        { name: "Contracte de imprumut" },
        { name: "Contracte de agent" },
        { name: "Contracte de dezvoltare Software" },
        { name: "Contracte de asigurare" },
        { name: "Contracte imobiliare" },
        { name: "Contracte de mentenanta" },
        { name: "Contracte abonament" },
        { name: "Contract de schimb" },
        { name: "Contract de furnizare de produse" },
        { name: "Contract de report" },
        { name: "Contract de antrepriză" },
        { name: "Contract de asociere în participație" },
        { name: "Contract de transport" },
        { name: "Contract de mandat" },
        { name: "Contract de comision" },
        { name: "Contract de consignație" },
        { name: "Contract de agenție" },
        { name: "Contract de intermediere" },
        { name: "Contract de depozit" },
        { name: "Contract de închiriere" },
        { name: "Contract de cont curent" },
        { name: "Contract de cont curent bancar" },
        { name: "Contract de asigurare" },
        { name: "Contract de rentă viageră" },
        { name: "Contract de joc și pariu" },
        { name: "Contract de donație" },
        { name: "Contract de fiducie" },
        { name: "Contract de leasing" },
        { name: "Contract de factoring" },

    ];


    const contractStatus = [
        { name: 'In lucru' },
        { name: 'Asteapta aprobarea' },
        { name: 'In curs de revizuire' },
        { name: 'Aprobat' },
        { name: 'In executie' },
        { name: 'Activ' },
        { name: 'Expirat' },
        { name: 'Finalizat' },
        { name: 'Reinnoit' },
        { name: 'Modificat' },
        { name: 'Inchis inainte de termen' },
        { name: 'Contestat' },
    ]

    const cashflowLines = [
        { name: 'Incasari operationale' },
        { name: 'Incasari financiare' },
        { name: 'Plati operationale' },
        { name: 'Plati investitionale' },
        { name: 'Plati financiare' },
        { name: 'Tranzactii InterCompany' },
        { name: 'Salarii' },
        { name: 'Furnizori activitate curenta' },
        { name: 'Utilitati' },
        { name: 'Auto combustibili si reparatii' },
        { name: 'Paza' },
        { name: 'Publicitate si sponsorizare' },
        { name: 'Deplasari + diurne' },
        { name: 'Marfa MUDR' },
        { name: 'Restituiri clienti' },
        { name: 'Investitii in curs' },
        { name: 'Investitii finalizate' },
        { name: 'Asigurari/ leasing , comisioane banci' },
        { name: 'Restituire credite si dobanzi' },
        { name: 'Impozit pe profit' },
        { name: 'Impozite locale' },
        { name: 'TVA de plata  ' },
        { name: 'Taxa salarii' },
        { name: 'Tranzactii intercompany' },
        { name: 'Transfer bancar(credit)' },
        { name: 'Transfer bancar(debit)' },
        { name: 'Plati Deconturi' },
        { name: 'Investitii Proprii' },
        { name: 'Compensari/Girari/Retururi' }]

    const costcenters = [
        { name: 'Abonamente RATB' },
        { name: 'Achizitii carti de specialitate' },
        { name: 'Achizitii de specialitate' },
        { name: 'Achizitii produse auto' },
        { name: 'Administratia pietelor' },
        { name: 'Administratie' },
        { name: 'Alpinisti utilitari' },
        { name: 'Alte cheltuieli' },
        { name: 'Alte cheltuieli si evenimente' },
        { name: 'Alte facilitati - masa personal, utilitati, servicii, abonamente RATB' },
        { name: 'Alte facilitati personal alte persoane' },
        { name: 'Alte obiective' },
        { name: 'Alte taxe (Reg. comert, mediu, urbanism, avize)' },
        { name: 'Altele' },
        { name: 'Amenajare incinta' },
        { name: 'Andimed - medicina muncii' },
        { name: 'Anunturi piblicitare, taxe postale si alte taxe' },
        { name: 'Anunturi publicitare, taxe postale' },
        { name: 'Apa' },
        { name: 'Apa menajera' },
        { name: 'Apartamente' },
        { name: 'Apele Romane' },
        { name: 'Ascensorul Schindler - servicii mentenanta' },
        { name: 'Asigurari auto casco si RCA' },
        { name: 'Asigurari cladiri si de viata' },
        { name: 'Autofinantare' },
        { name: 'Autorizatie/Licenta utilizare muzica' },
        { name: 'Bonuri de masa' },
        { name: 'Bonuri de masa alte persoane' },
        { name: 'Bugetul Managerului General' },
        { name: 'Carburant Auto' },
        { name: 'Carburant auto personal Tesa' },
        { name: 'Cheltuieli administrare si intretinere' },
        { name: 'Cheltuieli Comunicare' },
        { name: 'Cheltuieli comunicare' },
        { name: 'Cheltuieli cu personalul' },
        { name: 'Cheltuieli financiare' },
        { name: 'Cheltuieli imagine' },
        { name: 'Cheltuieli linie CFR / taxa drumuri/ taxa poduri' },
        { name: 'Cheltuieli Neprevazute' },
        { name: 'Cheltuieli neprevazute' },
        { name: 'Cheltuieli personal alte obiective fara profit' },
        { name: 'Cheltuieli personal Tesa' },
        { name: 'Cheltuieli sp. SNCFR ' },
        { name: 'Cheltuieli transport' },
        { name: 'Cheltuieli utilitati' }]


    for (const type of contractType) {
        await prisma.contractType.create({
            data: type,
        });
    }

    for (const status of contractStatus) {
        await prisma.contractStatus.create({
            data: status,
        });
    }

    for (const cf of cashflowLines) {
        await prisma.cashflow.create({
            data: cf,
        });
    }

    for (const cc of costcenters) {
        await prisma.costCenter.create({
            data: cc,
        });
    }

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