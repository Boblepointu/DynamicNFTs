const {
  PRIVATE_KEY
  , RPC_URL
  , NETWORK_ID
} = process.env

const HDWalletProvider = require('@truffle/hdwallet-provider')
const NonceTrackerSubprovider = require("web3-provider-engine/subproviders/nonce-tracker")

module.exports = {
  networks: {
    development: {
      provider: () => {
        const wallet = new HDWalletProvider({
          privateKeys: [ PRIVATE_KEY ],
          providerOrUrl: RPC_URL
        })
        const nonceTracker = new NonceTrackerSubprovider()
        wallet.engine._providers.unshift(nonceTracker)
        nonceTracker.setEngine(wallet.engine)
        return wallet
      },
      confirmations: 0,
      skipDryRun: true,
      network_id: parseInt(NETWORK_ID)
    }
  },
  compilers: {
    solc: {
      version: "0.8.17",
      settings: {
       optimizer: {
         enabled: true,
         runs: 200
       },
       evmVersion: "constantinople"
      }
    }
  }
};
