// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Erc1155IPFS
 * Erc1155IPFS - ERC1155 contract with IPFS support
 */
contract Erc1155IPFS is ERC1155, Ownable {
    string metadata_uri;
    mapping(uint256 => string) public _idToMetadata;
    mapping(string => uint256) public _metadataToId;
    mapping(uint256 => address) public _creators;
    mapping(address => uint256[]) public _created;
    uint256 nonce = 0;

    constructor()
        ERC1155("https://bridgedomain.xyz/nft/{id}.json")
    {
        metadata_uri = "https://bridgedomain.xyz/nft/{id}.json";
    }

    /**
     * Admin functions to fix base uri if needed
     */
    function setURI(string memory newuri) public onlyOwner {
        metadata_uri = newuri;
        _setURI(newuri);
    }

    function prepare(
        string memory metadata
    ) public returns (uint256) {
        require(
            _metadataToId[metadata] == 0,
            "Erc1155IPFS: Trying to push same metadata to another id"
        );
        uint256 id = uint256(
            keccak256(
                abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))
            )
        );
        while (bytes(_idToMetadata[id]).length > 0) {
            nonce += 1;
            id = uint256(
                keccak256(
                    abi.encodePacked(
                        nonce,
                        msg.sender,
                        blockhash(block.number - 1)
                    )
                )
            );
        }
        _idToMetadata[id] = metadata;
        _metadataToId[metadata] = id;
        _creators[id] = msg.sender;
        _created[msg.sender].push(id);
        return id;
    }

    function created(address _creator)
        public
        view
        returns (uint256[] memory createdTokens)
    {
        return _created[_creator];
    }

    function tokenCID(uint256 id)
        public
        view
        returns (string memory)
    {
        return _idToMetadata[id];
    }

    function mint(string memory metadata, uint256 amount) public {
        require(
            _metadataToId[metadata] > 0,
            "Erc1155IPFS: Minting a non-existent nft"
        );
        uint256 id = _metadataToId[metadata];
        require(
            _creators[id] == msg.sender,
            "Erc1155IPFS: Can't mint tokens you haven't created"
        );
        _mint(msg.sender, id, amount, bytes(""));
    }

    /**
     * Function to get the creator of a specific token
     */
    function creatorOfToken(uint256 tknId) public view returns (address) {
        return _creators[tknId];
    }
}
