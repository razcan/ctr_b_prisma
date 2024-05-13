import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {



    const contractWFStatus = [
        { name: "In lucru" },
        { name: "Asteapta aprobarea" },
        { name: "Aprobat" },
        { name: "Respins" }
    ]

    for (const statuses of contractWFStatus) {
        await prisma.ContractWFStatus.create({
            data: statuses,
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
