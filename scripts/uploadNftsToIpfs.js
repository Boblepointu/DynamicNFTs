
const Axios = require('axios')
const FormData = require('form-data')
const Fs = require('fs')
const Path = require('path')
const { IPFS_LOGIN, IPFS_PASSWORD, IPFS_ADMIN_HOST } = process.env
const NFTsData = require('../nftdata/data')


const sendToIpfs = async (fileBuffer, filename, contentType) => {
    const form = new FormData()
    form.append('file', fileBuffer, { filename, contentType })

    const { data } = await Axios.post(
        `https://${IPFS_ADMIN_HOST}/api/v0/add?pin=true&stream-channels=true`
        , form
        , {
            auth: { username: IPFS_LOGIN, password: IPFS_PASSWORD }            
            , maxContentLength: Infinity
            , maxBodyLength: Infinity
            , timeout: 20000 
        })
    console.log(`Sent to IPFS ! IPFS CIDV0 is ${data.Hash}.`)
    return data.Hash
}

const filepathToBuffer = (path)=> {
    return new Promise((resolve, reject) => {
        Fs.readFile(path, (err, data) => {
            if (err) {
                reject(err)
                return
            }
            resolve(data)
        });
    })
}

const stringToFile = (path, string) => {
    return new Promise((resolve, reject) => {
        Fs.writeFile(path, string, err => {
            if (err) {
                reject(err)
                return
            }
            resolve()
        });
    })
}

const main = async () => {
    console.log('Fetching nft data images, metadata and sending them to IPFS.')
    const weather = NFTsData.weather
    const keyWeather = Object.keys(weather)

    const generatedJson = {}

    for(let i = 0; i < keyWeather.length; i++){
        const currKey = keyWeather[i]
        const currMeta = weather[currKey]
        const currImageFileName = currMeta.image
        const absPath = Path.join(__dirname, '../nftdata/images', currImageFileName)
        console.log(`Getting file buffer for "${currKey}" nft, at ${absPath}.`)
        const fileBuffer = await filepathToBuffer(absPath, currImageFileName)
        console.log(`Got buffer for "${currKey}" image, of size ${fileBuffer.length} bytes.`)
        console.log(`Sending file to IPFS.`)
        const CIDImage = await sendToIpfs(fileBuffer, currImageFileName, 'image/png')
        console.log(`Replacing file name in metadata by CID ${CIDImage}.`)
        currMeta.image = `ipfs://${CIDImage}`
        console.log(`Sending stringified metadata to IPFS.`)
        const metadataBuffer = Buffer.from(JSON.stringify(currMeta))
        const CIDMetadata = await sendToIpfs(metadataBuffer, 'metadata.json', 'application/json')
        console.log(`${currKey} NFT metadata IPFS link is ipfs://${CIDMetadata}`)
        generatedJson[currKey] = `ipfs://${CIDMetadata}`
    }

    const absPath = Path.join(__dirname, '../nftdata/generated', 'nftCids.json')
    console.log(`Writing generated json to disk at ${absPath} for future use.`)
    await stringToFile(absPath, JSON.stringify(generatedJson, null, "\t"))
    console.log('Done !')
}

main()