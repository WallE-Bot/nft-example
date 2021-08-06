pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import './SecondaryCollectible.sol';
//learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

contract YourCollectible is ERC721, Ownable {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  /**
    maintain burn count for address
    one primray collectible burn required per mint of secondary
  **/
  mapping (address => uint256) private _holderBurnCount;

  constructor() public ERC721("YourCollectible", "YCB") {
    _setBaseURI("https://ipfs.io/ipfs/");
  }

  function getHolderBurnCount(address holder) public view returns (uint256){
    return _holderBurnCount[holder];
  }

  function mintItem(address to, string memory tokenURI)
      public
      onlyOwner
      returns (uint256)
  {
      _tokenIds.increment();

      uint256 id = _tokenIds.current();
      _mint(to, id);
      _setTokenURI(id, tokenURI);

      return id;
  }

  function burnItem(address owner, uint256 tokenId)
      public
  {
    require(owner == ownerOf(tokenId), "Attempted burn of token not own");
    uint256 currentBurnCount = _holderBurnCount[owner];
    _burn(tokenId);
    _holderBurnCount[owner] = currentBurnCount + 1;
  }
}
