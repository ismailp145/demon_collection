// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts@5.0.0/access/Ownable.sol";

contract DemonCollection_Ex_2b is ERC721, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint public constant cappedSupply = 100;
    uint public constant maxMintsPerAddress = 3;
    uint public mintPrice;
    uint8 public mintStage;
    uint public baseURI;
    // Add event for state changes
    event stateChanged(uint8 from, uint8 to);

    // Add event for minting demons
    event mintedDemon(uint8 stage, address to, uint numOfTokens);

    // Array of whitelisted addresses for stage 0
    address[] public whiteListAddresses = [0x9Acdccc4Ba4A1896Db6F95Ae143911f365A6e11d, 0xce290d5a931041B34df7DB7334eeeAdf217Ab7c3, 0x454BB310aD64474De37438D7950Eb2268c4C060c];



    constructor(address initialOwner, uint256 _mintPrice)
        ERC721("The DemonTown Collection", "DTC")
        Ownable(initialOwner)
    {
        mintPrice = _mintPrice;
    
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://csc299.s3.us-east-1.amazonaws.com/depauldemons/assets/json/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
    _unpause();
    }

    function safeMint(address to, uint amountMinted) public onlyOwner {
        for (uint i = 0; i < amountMinted; i++){
            require(totalSupply() < cappedSupply, "Exceeds capped supply");
            require(balanceOf(to) < maxMintsPerAddress, "Exceeds max mints per address");
            uint256 tokenId = _nextTokenId++;
            _safeMint(to, tokenId);
            emit mintedDemon(mintStage, to, 1);


        }
    }


    function totalSupply() public view returns(uint256) {
        return _nextTokenId;
    }



    function safePublicMint(address to, uint amountMinted) public payable {
        // require(totalSupply() < cappedSupply, "Exceeds capped supply");
        // require(balanceOf(to) < maxMintsPerAddress, "Exceeds max mints per address");

        if (mintStage == 0) {
            require(isWhitelisted(to), "Not whitelisted for this stage");


        } else if (mintStage == 1) {
            require( mintPrice == msg.value/amountMinted, "Incorrect value sent");


        } else if (mintStage != 2) {
            revert("Invalid minting stage");
        }

        for (uint i = 0; i < amountMinted; i++){
            require(totalSupply() < cappedSupply, "Exceeds capped supply");
            require(balanceOf(to) < maxMintsPerAddress, "Exceeds max mints per address");
            uint256 tokenId = _nextTokenId++;
            _safeMint(to, tokenId);
            emit mintedDemon(mintStage, to, 1);


        }
    }



    function isWhitelisted(address addr) internal view returns (bool) {
        for (uint i = 0; i < whiteListAddresses.length; i++) {
            if (whiteListAddresses[i] == addr) {
                return true;
            }
        }
        return false;
    }




    function withdraw() public onlyOwner{
    // get the amount of Ether stored in this contract
        uint amount = address(this).balance;
        // send all Ether to owner
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send Ether");
}



    function setMintStage(uint8 _newStage) public onlyOwner {
        require(_newStage >=0 && _newStage <= 2, "invalid states!");
        emit stateChanged(mintStage, _newStage);
        mintStage = _newStage;
}




    function setbaseURI(uint _newBaseURI) public onlyOwner{
        baseURI = _newBaseURI;
    }


    function setMintPrice(uint _newMintPrice) public onlyOwner{
        mintPrice = _newMintPrice;
    }



// The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Pausable)
        returns (address)
        {
        return super._update(to, tokenId, auth);
    }
}