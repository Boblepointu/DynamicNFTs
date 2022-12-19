const Express = require('express')

const {
    BACKEND_HOST
    , WEATHER_CONTRACT_ADDRESS
    , DIAMOND_CONTRACT_ADDRESS
    , EXCLUSIVE_CONTRACT_ADDRESS
    , NETWORK_ID
} = process.env

const main = async () => {
    const app = Express()
    const port = 3000
    
    app.get('/runTimeVars', (req, res) => {
        res.setHeader('Content-Type', 'application/json')
        res.end(JSON.stringify({
            BACKEND_HOST
            , WEATHER_CONTRACT_ADDRESS
            , DIAMOND_CONTRACT_ADDRESS
            , EXCLUSIVE_CONTRACT_ADDRESS
            , NETWORK_ID
        }))
    })

    app.get('/healthcheck', (req, res) => {
        res.sendStatus(200)
    })

    app.use(Express.static('public'))

    app.listen(port, () => {
        console.log(`Frontend app listening on port ${port}`)
    })
}

main()