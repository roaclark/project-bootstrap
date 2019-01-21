const express = require('express')
const path = require('path')

const app = express()
const port = process.env.PORT || 3000

app.use('/', express.static(path.join(__dirname, 'client/dist')))

app.get('/api', (req, res) => {
  res.send('Hello from the server!')
})

app.listen(port, () => {
  console.log(`Server listening on port ${port}!`) // eslint-disable-line no-console
})
