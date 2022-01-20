const HDWalletProvider = require("@truffle/hdwallet-provider");
const web3 = require("web3");
require('dotenv').config()
const MNEMONIC = process.env.GANACHE_MNEMONIC;
const NFT_CONTRACT_ADDRESS = process.env.GANACHE_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.GANACHE_OWNER_ADDRESS;
const NFT_CONTRACT_ABI = require('../abi.json')
const argv = require('minimist')(process.argv.slice(2));
const fs = require('fs')

async function main() {
    const configs = JSON.parse(fs.readFileSync('./configs/' + argv._ + '.json').toString())
    if (configs.owner_mnemonic !== undefined) {
        const provider = new HDWalletProvider(
            configs.owner_mnemonic,
            configs.provider
        );
        const web3Instance = new web3(provider);

        const nftContract = new web3Instance.eth.Contract(
            NFT_CONTRACT_ABI,
            configs.contract_address, {
                gasLimit: "500000"
            }
        );
        // CUSTOMIZE THE AMOUNT MINTED AND TOKEN ID
        const ipfs_string = "bafkreidpqdpapp3k2ycdhftfizsslbqssfedlbeuqfsvqbknpud2xn4eg4"
        try {
            let nonce = await web3Instance.eth.getTransactionCount(configs.owner_address)
            console.log('Trying preparing event type ' + ipfs_string + ' with ' + configs.owner_address + ' with nonce ' + nonce + '...')
            const result = await nftContract.methods
                .prepare(configs.owner_address, ipfs_string, 500)
                .send({
                    from: configs.owner_address,
                    nonce: nonce,
                    gasPrice: "100000000000"
                }).on('transactionHash', pending => {
                    console.log('Pending TX is: ' + pending)
                })
            console.log("Event prepared! Transaction: " + result.transactionHash)
        } catch (e) {
            console.log(e)
        }
        console.log('Finished!')
        process.exit()
    } else {
        console.log('Please provide `owner_mnemonic` first.')
    }

}

if (argv._ !== undefined) {
    main();
} else {
    console.log('Provide a deployed contract first.')
}