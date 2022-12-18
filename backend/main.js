const Utils = require('./utils.class')
const Abi = require('./abi')
const Express = require('express')
const Axios = require('axios')
const Web3 = require('web3')

const { 
  PRIVATE_KEY
  , RPC_URL
  , WEATHER_CONTRACT_ADDRESS
  , LINK_FEE
  , LINK_CONTRACT_ADDRESS
} = process.env

let avgTempPlus1000 = 1000

const web3 = new Web3(RPC_URL)

const sendChainTx = async () => {
  const account = web3.eth.accounts.privateKeyToAccount(`0x${PRIVATE_KEY}`).address

  const LinkContract = new web3.eth.Contract(Abi, LINK_CONTRACT_ADDRESS)

  const transferLinksTx = LinkContract.methods.transfer(WEATHER_CONTRACT_ADDRESS, LINK_FEE)

  const createTransferTransaction = await web3.eth.accounts.signTransaction(
    {
      from: account,
      to: LINK_CONTRACT_ADDRESS,
      data: transferLinksTx.encodeABI(),
      maxFeePerGas: 5500000,
      maxPriorityFeePerGas: 5500000,
      gasLimit: 300000
    },
    `0x${PRIVATE_KEY}`
  )

  await web3.eth.sendSignedTransaction(createTransferTransaction.rawTransaction);

  console.log(`Sent the necessary LINK to the contract to call Oracle !`)

  const WeatherContract = new web3.eth.Contract(Abi, WEATHER_CONTRACT_ADDRESS)

  const requestAvgTempTx = WeatherContract.methods.requestAvgTemp()

  const createOracleTransaction = await web3.eth.accounts.signTransaction(
    {
      to: WEATHER_CONTRACT_ADDRESS,
      data: requestAvgTempTx.encodeABI(),
      maxFeePerGas: 5500000,
      maxPriorityFeePerGas: 5500000,
      gasLimit: await requestAvgTempTx.estimateGas()*2
    },
    `0x${PRIVATE_KEY}`
  )

  await web3.eth.sendSignedTransaction(createOracleTransaction.rawTransaction);

  console.log(`Sucessfully asked for a renewal of current temperature to the Chainlink Oracle !`)
}

const dataRefresh = async () => {  
  while(true){
    try{
      const { current_condition: { tmp } } = (await Axios.get('https://www.prevision-meteo.ch/services/json/paris')).data

      avgTempPlus1000 = Math.trunc(tmp) + 1000
      console.log(`Retrieved temperature in Paris ! (${tmp})`)
      await sendChainTx()
      await Utils.sleep(60*60*24*1000)
    }catch(err){
      console.log(err)
      console.log(`Was enable to retrieve and/or to set the new average temperature on chain ! Retrying in 60 seconds.`)
      await Utils.sleep(60*1000)
    }
  }
}

const main = async () => {
    const app = Express()
    const port = 3000
    
    app.get('/healthcheck', (req, res) => {
      res.sendStatus(200)
    })

    app.get('/', (req, res) => {
      const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress 
      console.log(`Received a query for temperature from ${ip} !`)
      res.setHeader('Content-Type', 'application/json')
      res.end(JSON.stringify({
        avgTemp: avgTempPlus1000
      }))
    })
    
    app.listen(port, () => {
      console.log(`Weather app listening on port ${port}`)
    })
}

dataRefresh()
main()