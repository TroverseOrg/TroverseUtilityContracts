// contracs/TroverseStarsStaking.sol
// SPDX-License-Identifier: MIT

// ████████╗██████╗  ██████╗ ██╗   ██╗███████╗██████╗ ███████╗███████╗    
// ╚══██╔══╝██╔══██╗██╔═══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██╔════╝    
//    ██║   ██████╔╝██║   ██║██║   ██║█████╗  ██████╔╝███████╗█████╗      
//    ██║   ██╔══██╗██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗╚════██║██╔══╝      
//    ██║   ██║  ██║╚██████╔╝ ╚████╔╝ ███████╗██║  ██║███████║███████╗    
//    ╚═╝   ╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝    

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TroverseStarsStaking is ERC721Holder, Ownable, ReentrancyGuard {
    mapping(address => uint256) public amountStaked;
    mapping(uint256 => address) public stakerAddress;

    IERC721 public nftCollection;

    event NFTCollectionChanged(address _nftCollection);

    event Staked(uint256 id, address account);
    event Unstaked(uint256 id, address account);


    constructor() { }


    function setNFTCollection(address _nftCollection) external onlyOwner {
        require(_nftCollection != address(0), "Bad NFTCollection address");
        nftCollection = IERC721(_nftCollection);

        emit NFTCollectionChanged(_nftCollection);
    }

    function balanceOf(address owner) external view returns (uint256) {
        return amountStaked[owner];
    }
    
    function stake(uint256[] calldata _tokenIds) external nonReentrant {
        uint256 tokensLen = _tokenIds.length;
        for (uint256 i; i < tokensLen; ++i) {
            require(nftCollection.ownerOf(_tokenIds[i]) == _msgSender(), "Can't stake tokens you don't own!");

            nftCollection.transferFrom(_msgSender(), address(this), _tokenIds[i]);
            stakerAddress[_tokenIds[i]] = _msgSender();

            emit Staked(_tokenIds[i], _msgSender());
        }

        amountStaked[_msgSender()] += tokensLen;
    }

    function unstake(uint256[] calldata _tokenIds) external nonReentrant {
        require(amountStaked[_msgSender()] > 0, "You have no tokens staked");

        uint256 tokensLen = _tokenIds.length;
        for (uint256 i; i < tokensLen; ++i) {
            require(stakerAddress[_tokenIds[i]] == _msgSender(), "Can't unstake tokens you didn't stake!");

            stakerAddress[_tokenIds[i]] = address(0);
            nftCollection.transferFrom(address(this), _msgSender(), _tokenIds[i]);

            emit Unstaked(_tokenIds[i], _msgSender());
        }

        amountStaked[_msgSender()] -= tokensLen;
    }
}
