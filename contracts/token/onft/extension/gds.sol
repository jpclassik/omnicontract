// SPDX-License-Identifier: BUSL-1.1 
 
pragma solidity ^0.8; 
import "@openzeppelin/contracts/security/Pausable.sol"; 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 
import "@openzeppelin/contracts/utils/Strings.sol"; 
import ".././ONFT721.sol"; 
import ".././ONFT.sol"; 
/// @title Interface of the UniversalONFT standard 
contract  NFT is ONFT,Pausable ,ReentrancyGuard{ 
    uint public nextMintId; 
    uint public maxMintId; 
    string public baseTokenURI;
    string public baseExtension = ".json"; 
    using Strings for uint256;
    mapping(address => bool) public whitelisted; 
    mapping(address => bool) private onePerWallet;

 
    constructor(string memory _name, string memory _symbol, address _layerZeroEndpoint, uint _startMintId, uint _endMintId) ONFT(_name, _symbol, _layerZeroEndpoint) { 
         nextMintId = _startMintId; 
         maxMintId = _endMintId; 
          
    } 
 
    /// @notice Mint your ONFT 
    function mint() external payable { 
        require(nextMintId <= maxMintId, "NFT: Max Mint limit reached"); 
        require(onePerWallet[msg.sender] == false, "Already minted an NFT");
        onePerWallet[msg.sender] = true;
        uint newId = nextMintId; 
        nextMintId++; 
        require(whitelisted[msg.sender], "NFT: Wallet address not in whitelist"); 
        _safeMint(msg.sender, newId); 
    }
 
 
     function pauseSendTokens(bool pause) external onlyOwner { 
        pause ? _pause() : _unpause(); 
    } 
 
    function whitelistUser(address[] memory _user) external onlyOwner { 
        for(uint256 i = 0; i < _user.length; i++) 
         { 
        whitelisted[_user[i]] = true; 
 
        } 
    } 
 
    function setBaseURI(string memory _baseTokenURI) public onlyOwner { 
        baseTokenURI = _baseTokenURI; 
    } 
 
    function _baseURI() internal view override returns (string memory) { 
        return baseTokenURI; 
    } 
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension
    
    )) : "";
}

}
