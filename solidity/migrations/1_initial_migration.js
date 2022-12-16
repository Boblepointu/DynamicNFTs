const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 }

const DiamondCutFacet = artifacts.require("DiamondCutFacet")
const ERC721Facet = artifacts.require('ERC721Facet')
const Diamond = artifacts.require('Diamond')
const DiamondInit = artifacts.require('DiamondInit')
const IERC20 = artifacts.require('IERC20')

const { 
  CONTRACT_NAME
  , CONTRACT_SYMBOL
  , SNOWFLAKE_URI
  , CLOUD_URI
  , SUN_URI
  , LINK_CONTRACT_ADDRESS
  , ORACLE_CONTRACT_ADDRESS
  , SERVER_URL
  , LINK_FEE
} = process.env

module.exports = async (deployer) => {
  const accounts = await web3.eth.getAccounts()

  console.log(`Deploying DiamondCutFacet`)
  await deployer.deploy(DiamondCutFacet)
  console.log(DiamondCutFacet)
  console.log(DiamondCutFacet._json)
  console.log(DiamondCutFacet._json.abi[0])
  console.log(`DiamondCutFacet deployed: ${DiamondCutFacet.address}`)

  console.log(`Deploying Diamond`)
  await deployer.deploy(Diamond, accounts[0], DiamondCutFacet.address)
  console.log(Diamond)
  console.log(accounts[0], DiamondCutFacet.address)
  console.log(`Diamond deployed: ${Diamond.address}`)

  console.log(`Deploying DiamondInit`)
  await deployer.deploy(DiamondInit)
  console.log(DiamondInit)
  console.log(accounts[0], DiamondInit.address)
  console.log(`DiamondInit deployed: ${DiamondInit.address}`)

  console.log(`Deploying Facets`)

  const facets = [ { artifact: ERC721Facet, name: "ERC721Facet"} ]
  const cut = []

  for (const facet of facets) {
    console.log(`Deploying ${facet.name}`)
    await deployer.deploy(facet.artifact)
    console.log(`${facet.name} deployed: ${facet.artifact.address}`)

    const facetFucntionsSignatures = facet.artifact._json.abi.filter(element => 
      element.signature 
      && element.type === 'function' 
      && element.name !== 'init')
      .map(element => element.signature)
    

    cut.push({
      facetAddress: facet.artifact.address,
      action: FacetCutAction.Add,
      functionSelectors: facetFucntionsSignatures
    })
    
    console.log(`Generated ${facetFucntionsSignatures.length} function signatures to include to Diamond !`)
  }

  console.log(cut)
  const DiamondInitInstance = new web3.eth.Contract(DiamondInit._json.abi, DiamondInit.address)
  const encodedInitFunctionCall = DiamondInitInstance.methods.init().encodeABI()
  console.log(`Got back encoded init function call.`)
  console.log(encodedInitFunctionCall)
  
  console.log(`Calling diamondCut func with encoded init and cut array.`)
  const DiamondCutFacetInstance = await DiamondCutFacet.at(Diamond.address)//new web3.eth.Contract(DiamondCutFacet._json.abi, DiamondCutFacet.address)
  await DiamondCutFacetInstance.diamondCut(cut, DiamondInit.address, encodedInitFunctionCall)

  console.log(`Executing extra func to init at address ${Diamond.address}`)

  // Sending some LINK to Diamond
  const linkToken = await IERC20.at(LINK_CONTRACT_ADDRESS)
  await linkToken.transfer(Diamond.address, "1000000000000000000")
  console.log(`Sent 1 LINK to Diamond !`)

  const ERC721FacetInstance = await ERC721Facet.at(Diamond.address)//new web3.eth.Contract(ERC721Facet._json.abi, Diamond.address)

  // initting diamond
  await ERC721FacetInstance.transferOwnership(accounts[0])
  console.log(`Setted diamond owner to ${accounts[0]}`)
  await ERC721FacetInstance.setNameAndSymbol(CONTRACT_NAME, CONTRACT_SYMBOL)
  console.log(`Setted diamond name to ${CONTRACT_NAME} and symbol to ${CONTRACT_SYMBOL}`)
  await ERC721FacetInstance.initStateUris(SNOWFLAKE_URI, CLOUD_URI, SUN_URI)
  console.log(`Setted nft states to snowflake = ${SNOWFLAKE_URI}, cloud = ${CLOUD_URI}, sun = ${SUN_URI}`)
  await ERC721FacetInstance.initSupportedInterfaces()
  console.log(`Initted supported interfaces to ERC721Metadata, ERC721Enumerable and ERC721`)
  await ERC721FacetInstance.initChainLinkClient(LINK_CONTRACT_ADDRESS, ORACLE_CONTRACT_ADDRESS, SERVER_URL, LINK_FEE)
  console.log(`Initted chainlink client with link address ${LINK_CONTRACT_ADDRESS}, oracle address ${ORACLE_CONTRACT_ADDRESS}, and a fixed fee of ${LINK_FEE} `)
  await ERC721FacetInstance.requestAvgTemp()
  console.log(`Requested temperature for today ${LINK_CONTRACT_ADDRESS}, oracle address ${ORACLE_CONTRACT_ADDRESS}, and a fixed fee of ${LINK_FEE} `)
  

  await ERC721FacetInstance.mintWeather(accounts[0])
  console.log(`Minted a new nft, for ${accounts[0]}`)
}
