# ERC-1155 with IPFS support

This repository is needed when you want to deploy an ERC-1155 smart contract and want to use IPFS as metadata storage.
Of course you may know that officially is IPFS is not supported by OpenSea, because metadata are fetched using this pattern `https://bridgedomain.xyz/{id}.json`.
Metadata are served by a centralized API, so we prepared an api which fetches the metadata CID from the contract, downloads the metadata from IPFS and serves them for Opensea.

You'll find two different folders, one is for the smart contract and one is for the api. For both projects you'll need NodeJS an YARN, please be sure to download all dependencies first.

## Build the smart contract

## Run the APIs