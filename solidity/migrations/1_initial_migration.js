const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 }

const DiamondCutFacet = artifacts.require("DiamondCutFacet")
const ERC721Facet = artifacts.require('ERC721Facet')
const ERC2981Facet = artifacts.require('ERC2981Facet')
const Diamond = artifacts.require('Diamond')
const DiamondInit = artifacts.require('DiamondInit')
const IERC20 = artifacts.require('IERC20')
const Weather = artifacts.require('Weather')

const { 
  CONTRACT_NAME
  , CONTRACT_SYMBOL
  , SNOWFLAKE_URI
  , CLOUD_URI
  , SUN_URI
  , CONTRACT_URI
  , LINK_CONTRACT_ADDRESS
  , ORACLE_CONTRACT_ADDRESS
  , SERVER_URL
  , LINK_FEE
  , EXCLUSIVE_CONTRACT_ADDRESS
  , SALE_START_TIMESTAMP
} = process.env

module.exports = async (deployer) => {
  const accounts = await web3.eth.getAccounts()

  console.log(`Deploying Weather`)
  await deployer.deploy(Weather, LINK_CONTRACT_ADDRESS, ORACLE_CONTRACT_ADDRESS, SERVER_URL, LINK_FEE)
  console.log(`Initted chainlink client with link address ${LINK_CONTRACT_ADDRESS}, oracle address ${ORACLE_CONTRACT_ADDRESS}, and a fixed fee of ${LINK_FEE} `)

  console.log(`Deploying DiamondCutFacet`)
  await deployer.deploy(DiamondCutFacet)
  console.log(`DiamondCutFacet deployed: ${DiamondCutFacet.address}`)

  console.log(`Deploying Diamond`)
  await deployer.deploy(Diamond, accounts[0], DiamondCutFacet.address)
  console.log(`Diamond deployed: ${Diamond.address}`)

  console.log(`Deploying DiamondInit`)
  await deployer.deploy(DiamondInit)
  console.log(`DiamondInit deployed: ${DiamondInit.address}`)

  console.log(`Deploying Facets`)

  const facets = [ 
    { artifact: ERC721Facet, name: "ERC721Facet"}
    , { artifact: ERC2981Facet, name: "ERC2981Facet"}
  ]
  const cut = []

  for (const facet of facets) {
    console.log(`Deploying ${facet.name}`)
    await deployer.deploy(facet.artifact)
    console.log(`${facet.name} deployed: ${facet.artifact.address}`)

    const facetFunctionsSignatures = facet.artifact._json.abi.filter(element => 
      element.signature 
      && element.type === 'function' 
      && element.name !== 'init')
      .map(element => element.signature)
    

    cut.push({
      facetAddress: facet.artifact.address,
      action: FacetCutAction.Add,
      functionSelectors: facetFunctionsSignatures
    })
    
    console.log(`Generated ${facetFunctionsSignatures.length} function signatures to include to Diamond !`)
  }
  
  const signatureHashMap = {}

  for(let i = 0; i < cut.length; i++){
    const currCut = cut[i]
    const newSignatureArr = []
    currCut.functionSelectors.forEach(signature => {
      if(!signatureHashMap[signature]){
        signatureHashMap[signature] = true
        newSignatureArr.push(signature)
      }
    })
    currCut.functionSelectors = newSignatureArr
  }

  // console.log(cut)
  const DiamondInitInstance = new web3.eth.Contract(DiamondInit._json.abi, DiamondInit.address)
  const encodedInitFunctionCall = DiamondInitInstance.methods.init().encodeABI()
  console.log(`Got back encoded init function call.`)
  
  console.log(`Calling diamondCut func with encoded init and cut array.`)
  const DiamondCutFacetInstance = await DiamondCutFacet.at(Diamond.address)//new web3.eth.Contract(DiamondCutFacet._json.abi, DiamondCutFacet.address)
  await DiamondCutFacetInstance.diamondCut(cut, DiamondInit.address, encodedInitFunctionCall)

  // Sending some LINK to Diamond
  const linkToken = await IERC20.at(LINK_CONTRACT_ADDRESS)
  await linkToken.transfer(Weather.address, "1000000000000000000")
  console.log(`Sent 1 LINK to Weather !`)

  const ERC721FacetInstance = await ERC721Facet.at(Diamond.address)
  const ERC2981FacetInstance = await ERC2981Facet.at(Diamond.address)
  const DispatchFacetInstance = await DispatchFacet.at(Diamond.address)
  const WeatherInstance = await Weather.at(Weather.address)

  // initting diamond
  console.log(`Executing extra func to init`)
  await ERC721FacetInstance.transferOwnership(accounts[0])
  console.log(`Setted diamond owner to ${accounts[0]}`)
  await ERC721FacetInstance.setWeatherContract(Weather.address)
  console.log(`Setted diamond weather address to ${Weather.address}`)
  await ERC721FacetInstance.setNameAndSymbol(CONTRACT_NAME, CONTRACT_SYMBOL)
  console.log(`Setted diamond name to ${CONTRACT_NAME} and symbol to ${CONTRACT_SYMBOL}`)
  await ERC721FacetInstance.initStateUris(SNOWFLAKE_URI, CLOUD_URI, SUN_URI)
  console.log(`Setted nft states to snowflake = ${SNOWFLAKE_URI}, cloud = ${CLOUD_URI}, sun = ${SUN_URI}`)
  await ERC721FacetInstance.setContractUri(CONTRACT_URI)
  console.log(`Setted contract URI to ${CONTRACT_URI}`)
  await ERC721FacetInstance.setExclusiveContract(EXCLUSIVE_CONTRACT_ADDRESS)
  console.log(`Setted exclusive contract address to ${EXCLUSIVE_CONTRACT_ADDRESS}`)
  await ERC721FacetInstance.setSaleStartDate(SALE_START_TIMESTAMP)
  console.log(`Setted the sale start date to ${SALE_START_TIMESTAMP}`)
  await ERC721FacetInstance.initSupportedInterfaces()
  console.log(`Initted supported interfaces to ERC721Metadata, ERC721Enumerable and ERC721`)
  await WeatherInstance.requestAvgTemp()
  console.log(`Requested temperature for today ${LINK_CONTRACT_ADDRESS}, oracle address ${ORACLE_CONTRACT_ADDRESS}, and a fixed fee of ${LINK_FEE} `)
  await ERC2981FacetInstance.initSupportedInterfaces()
  console.log(`Initted supported interfaces to ERC2981`)
  await DispatchFacetInstance.setReceivers('0x4A5BFf849c4e790eBcaC8dE611c10EDe7a9e7075', '0x8d58362182EE5546AC43b328C19fCD3E65Fc5417')
  console.log(`Setted receivers of the royalties`)
  await ERC2981FacetInstance.setDispatchContract(Diamond.address)
  console.log(`Set dispatch contract address to Diamond itself`)
}
