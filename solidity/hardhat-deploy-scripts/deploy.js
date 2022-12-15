/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
const { 
  CONTRACT_NAME
  , CONTRACT_SYMBOL
  , SNOWFLAKE_URI
  , CLOUD_URI
  , SUN_URI 
} = process.env

async function deployDiamond () {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]

  // deploy DiamondCutFacet
  const DiamondCutFacet = await ethers.getContractFactory('DiamondCutFacet')
  const diamondCutFacet = await DiamondCutFacet.deploy()
  await diamondCutFacet.deployed()
  console.log('DiamondCutFacet deployed:', diamondCutFacet.address)

  // deploy Diamond
  const Diamond = await ethers.getContractFactory('Diamond')
  const diamond = await Diamond.deploy(contractOwner.address, diamondCutFacet.address)
  await diamond.deployed()
  console.log('Diamond deployed:', diamond.address)

  // deploy DiamondInit
  // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const DiamondInit = await ethers.getContractFactory('DiamondInit')
  const diamondInit = await DiamondInit.deploy()
  await diamondInit.deployed()
  console.log('DiamondInit deployed:', diamondInit.address)

  // deploy facets
  console.log('')
  console.log('Deploying facets')
  const FacetNames = [
    'ERC721Facet'
  ]
  const cut = []
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy()
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)
    cut.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet)
    })
  }

  // upgrade diamond with facets
  console.log('')
  console.log('Diamond Cut:', cut)
  const diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address)
  let tx
  let receipt
  // call to init function
  let functionCall = diamondInit.interface.encodeFunctionData('init')
  tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
  console.log('Diamond cut tx: ', tx.hash)
  receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
  }
  console.log('Completed diamond cut')

  console.log(`Executing extra func to init at address ${diamond.address}`)
  const facet = await ethers.getContractAt('ERC721Facet', diamond.address)

  // initting diamond
  await facet.transferOwnership(contractOwner.address)
  console.log(`Setted diamond owner to ${contractOwner.address}`)
  await facet.setNameAndSymbol(CONTRACT_NAME, CONTRACT_SYMBOL)
  console.log(`Setted diamond name to ${CONTRACT_NAME} and symbol to ${CONTRACT_SYMBOL}`)
  await facet.initStateUris(SNOWFLAKE_URI, CLOUD_URI, SUN_URI)
  console.log(`Setted nft states to snowflake = ${SNOWFLAKE_URI}, cloud = ${CLOUD_URI}, sun = ${SUN_URI}`)
  await facet.initSupportedInterfaces()
  console.log(`Initted supported interfaces to ERC721Metadata, ERC721Enumerable and ERC721`)

  for(let i = 0; i < 15; i++){
    await facet.mintWeather(contractOwner.address)
    console.log(`Minted a new nft, tokenId ${i}, for ${contractOwner.address}`)
  }

  return diamond.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDiamond = deployDiamond
