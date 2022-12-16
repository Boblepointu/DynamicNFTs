
/* global ethers task */
require('@nomiclabs/hardhat-waffle')
const Conf = require('./conf')
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
// 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
module.exports = {
  solidity: {
    compilers: [
      { 
        version: "0.8.13"
        , settings: {
          optimizer: {
            enabled: true,
            runs: 10
          }
        }  
      },
      { 
        version: "0.8.6"
        , settings: {
          optimizer: {
            enabled: true,
            runs: 10
          }
        } 
      }
    ],
  },
  defaultNetwork: "default",
  networks: {
    hardhat: {},
    default: {
      url: Conf.rpcAddress,
      accounts: [ Conf.deployerPrivateKey ]
    }
  },
  paths: {
    sources: "./src",
    tests: "./test",
    cache: "./cache",
    artifacts: "./out"
  },  
  settings: {
    optimizer: {
      enabled: true,
      runs: 1
    }
  }
}
