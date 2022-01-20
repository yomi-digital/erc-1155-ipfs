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
    mapping(address => bool) public _minters;
    mapping(uint256 => uint256) public _supplies;
    mapping(uint256 => uint256) public _limits;
    mapping(uint256 => address) public _creators;
    mapping(address => uint256[]) public _created;
    address _proxyAddress;
    uint256 nonce = 0;

    constructor() ERC1155("https://bridgedomain.xyz/nft/{id}.json") {
        metadata_uri = "https://bridgedomain.xyz/nft/{id}.json";
    }

    /**
     * Admin functions to fix base uri if needed
     */
    function setURI(string memory newuri) public onlyOwner {
        metadata_uri = newuri;
        _setURI(newuri);
    }

    /**
     * Admin functions to set the proxy address
     */
    function setProxyAddress(address newproxy) public onlyOwner {
        _proxyAddress = newproxy;
    }

    /**
     * Admin functions to set other minters
     */
    function setMinters(address minter, bool state) public onlyOwner {
        _minters[minter] = state;
    }

    function prepare(
        address creator,
        string memory metadata,
        uint256 max_supply
    ) public returns (uint256) {
        require(
            msg.sender == _proxyAddress || _minters[msg.sender] == true,
            "Erc1155IPFS: Only the proxy address or minters can prepare nfts"
        );
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
        _creators[id] = creator;
        _limits[id] = max_supply;
        _created[creator].push(id);
        return id;
    }

    function created(address _creator)
        public
        view
        returns (uint256[] memory createdTokens)
    {
        return _created[_creator];
    }

    function tokenCID(uint256 id) public view returns (string memory) {
        return _idToMetadata[id];
    }

    function mint(
        address receiver,
        string memory metadata,
        uint256 amount
    ) public returns (uint256) {
        require(
            _metadataToId[metadata] > 0,
            "Erc1155IPFS: Minting a non-existent nft"
        );
        uint256 id = _metadataToId[metadata];
        require(
            _creators[id] == msg.sender || _proxyAddress == msg.sender,
            "Erc1155IPFS: Can't mint tokens you haven't created"
        );
        // Check if there's a max supply
        if (_limits[id] > 0) {
            uint256 reached = _supplies[id] + amount;
            require(reached <= _supplies[id], "Erc1155IPFS: Max supply reached for the NFT");
        }
        _mint(receiver, id, amount, bytes(""));
        _supplies[id] += amount;
        return id;
    }

    /**
     * Function to get the creator of a specific token
     */
    function creatorOfToken(uint256 tknId) public view returns (address) {
        return _creators[tknId];
    }
}
