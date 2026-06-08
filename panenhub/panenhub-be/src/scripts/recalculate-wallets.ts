import { prisma } from '../config/database'

async function main() {
  console.log('=== Recalculating Wallet totalEarned balances ===')
  
  const wallets = await prisma.wallet.findMany()
  console.log(`Found ${wallets.length} wallets.`)

  for (const wallet of wallets) {
    const aggregate = await prisma.withdrawal.aggregate({
      _sum: {
        amount: true,
      },
      where: {
        farmerId: wallet.farmerId,
        status: {
          in: ['approved', 'paid'],
        },
      },
    })

    const totalDisbursed = aggregate._sum.amount || 0
    const oldTotalEarned = wallet.totalEarned

    if (oldTotalEarned !== totalDisbursed) {
      await prisma.wallet.update({
        where: { id: wallet.id },
        data: { totalEarned: totalDisbursed },
      })
      console.log(
        `Wallet for Farmer ID ${wallet.farmerId}: updated totalEarned from Rp${oldTotalEarned} to Rp${totalDisbursed}.`
      )
    } else {
      console.log(
        `Wallet for Farmer ID ${wallet.farmerId}: totalEarned is already correct (Rp${totalDisbursed}).`
      )
    }
  }

  console.log('=== Recalculation complete ===')
}

main()
  .catch((e) => {
    console.error('Error during recalculation:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
