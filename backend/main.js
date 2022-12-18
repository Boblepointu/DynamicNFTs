const Utils = require('./utils.class')
const Express = require('express')
const Axios = require('axios')
const Web3 = require('web3')

const { PRIVATE_KEY } = process.env

let avgTempPlus1000 = 1000

const dataRefresh = async () => {
  while(true){
    const { current_condition: { tmp } } = (await Axios.get('https://www.prevision-meteo.ch/services/json/paris')).data

    avgTempPlus1000 = Math.trunc(tmp) + 1000
    console.log(`Retrieved temperature in Paris ! (${tmp})`)
    await Utils.sleep(60*60*24)
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