// contracs/TroversePassesStaking.sol
// SPDX-License-Identifier: MIT

// ████████╗██████╗  ██████╗ ██╗   ██╗███████╗██████╗ ███████╗███████╗    
// ╚══██╔══╝██╔══██╗██╔═══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██╔════╝    
//    ██║   ██████╔╝██║   ██║██║   ██║█████╗  ██████╔╝███████╗█████╗      
//    ██║   ██╔══██╗██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗╚════██║██╔══╝      
//    ██║   ██║  ██║╚██████╔╝ ╚████╔╝ ███████╗██║  ██║███████║███████╗    
//    ╚═╝   ╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝    

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface IMultiToken is IERC1155 {
    function operatorTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
}


contract TroversePassesStaking is ERC1155Holder, Ownable, ReentrancyGuard {
    mapping(uint256 => mapping(address => uint256)) public amountStaked;
    IMultiToken public multiToken;

    event Staked(uint256 id, uint256 amount, address account);
    event Unstaked(uint256 id, uint256 amount, address account);


    constructor() { }


    function setMultiToken(address _multiToken) external onlyOwner {
        require(_multiToken != address(0), "Bad MultiToken address");
        multiToken = IMultiToken(_multiToken);
    }

    function balanceOf(address account, uint256 id) external view returns (uint256) {
        return amountStaked[id][account];
    }

    function stake(uint256[] calldata _tokenIds, uint256[] calldata _amounts) external nonReentrant {
        uint256 tokensLen = _tokenIds.length;

        for (uint256 i; i < tokensLen; ++i) {
            require(multiToken.balanceOf(_msgSender(), _tokenIds[i]) >= _amounts[i], "Not enough balance");

            multiToken.operatorTransferFrom(_msgSender(), address(this), _tokenIds[i], _amounts[i], "");
            amountStaked[_tokenIds[i]][_msgSender()] += _amounts[i];

            emit Staked(_tokenIds[i], _amounts[i], _msgSender());
        }
    }

    function stakeFor(uint256[] calldata _tokenIds, uint256[] calldata _amounts, address[] calldata _accounts) external onlyOwner {
        uint256 tokensLen = _tokenIds.length;

        for (uint256 i; i < tokensLen; ++i) {
            require(multiToken.balanceOf(_accounts[i], _tokenIds[i]) >= _amounts[i], "Not enough balance");

            multiToken.operatorTransferFrom(_accounts[i], address(this), _tokenIds[i], _amounts[i], "");
            amountStaked[_tokenIds[i]][_accounts[i]] += _amounts[i];

            emit Staked(_tokenIds[i], _amounts[i], _accounts[i]);
        }
    }

    function unstake(uint256[] calldata _tokenIds, uint256[] calldata _amounts) external nonReentrant {
        uint256 tokensLen = _tokenIds.length;

        for (uint256 i; i < tokensLen; ++i) {
            require(amountStaked[_tokenIds[i]][_msgSender()] >= _amounts[i], "Not enough tokens to unstake");

            multiToken.operatorTransferFrom(address(this), _msgSender(), _tokenIds[i], _amounts[i], "");
            amountStaked[_tokenIds[i]][_msgSender()] -= _amounts[i];

            emit Unstaked(_tokenIds[i], _amounts[i], _msgSender());
        }
    }

    function unstakeFor(uint256[] calldata _tokenIds, uint256[] calldata _amounts, address[] calldata _accounts) external onlyOwner {
        uint256 tokensLen = _tokenIds.length;

        for (uint256 i; i < tokensLen; ++i) {
            require(amountStaked[_tokenIds[i]][_accounts[i]] >= _amounts[i], "Not enough tokens to unstake");

            multiToken.operatorTransferFrom(address(this), _accounts[i], _tokenIds[i], _amounts[i], "");
            amountStaked[_tokenIds[i]][_accounts[i]] -= _amounts[i];

            emit Unstaked(_tokenIds[i], _amounts[i], _accounts[i]);
        }
    }
}
