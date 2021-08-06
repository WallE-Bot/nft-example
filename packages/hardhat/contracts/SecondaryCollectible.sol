pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import './YourCollectible.sol';

contract SecondaryCollectible is ERC721, Ownable {

  /**
    to maintain secondary mint relationship with primary burn
  **/
  mapping (address => uint256) private _holderMintCount;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // external secondary collectible contract
  YourCollectible private primaryCollectible;

  constructor() public ERC721("primaryCollectible", "SCB") {
    _setBaseURI("https://ipfs.io/ipfs/");
  }

  function definePrimaryCollectible(address primaryCollectibleAddress)
    public
    onlyOwner
  {
    primaryCollectible = YourCollectible(primaryCollectibleAddress);
  }

  /**
    any EOA can attempt to mint but must have
    a positive burn count balance
  **/
  function mintItem(
    string memory tokenURI
  )
    public
    returns (uint256)
  {
    /**
      get burn count of sender and
      require msg.sender to have available minting balance
    **/
    uint256 burnCount = primaryCollectible.getHolderBurnCount(msg.sender);

    require(
      _holderMintCount[msg.sender] <
      burnCount,
      "You have not burned a primary NFT"
    );

    _tokenIds.increment();

    uint256 id = _tokenIds.current();
    _mint(msg.sender, id);
    _setTokenURI(id, tokenURI);

    uint256 currentMintCount = _holderMintCount[msg.sender];
    _holderMintCount[msg.sender] = currentMintCount + 1;

    return id;
  }
}
