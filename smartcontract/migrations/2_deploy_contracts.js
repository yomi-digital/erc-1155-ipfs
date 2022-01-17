const Erc1155IPFS = artifacts.require("./Erc1155IPFS.sol");
const fs = require('fs')

module.exports = async (deployer, network) => {
    await deployer.deploy(Erc1155IPFS);
    const contract = await Erc1155IPFS.deployed();
    let configs = JSON.parse(fs.readFileSync(process.env.CONFIG).toString())
    console.log('Saving address in config file..')
    configs.contract_address = contract.address
    fs.writeFileSync(process.env.CONFIG, JSON.stringify(configs, null, 4))
    console.log('--')
};