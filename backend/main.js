const Express = require('express')

const main = async () => {
    const app = Express()
    const port = 3000
    
    app.get('/', (req, res) => {
      res.send('3')
    })
    
    app.listen(port, () => {
      console.log(`Weather app listening on port ${port}`)
    })
}

main()