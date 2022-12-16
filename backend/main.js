const Express = require('express')

const main = async () => {
    const app = Express()
    const port = 3000
    
    app.get('/healthcheck', (req, res) => {
      res.sendStatus(200)
    })

    app.get('/', (req, res) => {
      console.log('Received a query for temperature !')
      res.json({
        avgTemp: 3//'0x3000000000000000000000000000000000000000000000000000000000000000'
      })
    })
    
    app.listen(port, () => {
      console.log(`Weather app listening on port ${port}`)
    })
}

main()