import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {



    const VatQuota = [
        { VatCode: "TVA19", VATDescription: "Cota normala(19%)", VATPercent: 19, VATType: 1, AccVATPercent: 19 },
        { VatCode: "TVA9", VATDescription: "Cota normala(9%)", VATPercent: 9, VATType: 1, AccVATPercent: 9 },
        { VatCode: "TVA5", VATDescription: "Cota normala(5%)", VATPercent: 5, VATType: 1, AccVATPercent: 5 },
        { VatCode: "FARA", VATDescription: "Fara TVA", VATPercent: 0, VATType: 0, AccVATPercent: 0 }
    ]


    for (const vat of VatQuota) {
        await prisma.vatQuota.create({
            data: vat,
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
