const Express = require('express')

const {
    BACKEND_HOST
} = process.env

const main = async () => {
    const app = Express()
    const port = 3000
    
    app.get('/runtTimeVars', (req, res) => {
        res.setHeader('Content-Type', 'application/json')
        res.end(JSON.stringify({
            BACKEND_HOST
        }))
    })

    app.get('/healthcheck', (req, res) => {
      res.sendStatus(200)
    })

    app.use(express.static('public'))

    app.listen(port, () => {
    console.log(`Frontend app listening on port ${port}`)
    })
}

main()