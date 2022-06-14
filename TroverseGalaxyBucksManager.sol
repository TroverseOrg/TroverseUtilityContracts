// contracs/TroverseGalaxyBucksManager.sol
// SPDX-License-Identifier: MIT

// ████████╗██████╗  ██████╗ ██╗   ██╗███████╗██████╗ ███████╗███████╗    
// ╚══██╔══╝██╔══██╗██╔═══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██╔════╝    
//    ██║   ██████╔╝██║   ██║██║   ██║█████╗  ██████╔╝███████╗█████╗      
//    ██║   ██╔══██╗██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗╚════██║██╔══╝      
//    ██║   ██║  ██║╚██████╔╝ ╚████╔╝ ███████╗██║  ██║███████║███████╗    
//    ╚═╝   ╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝    

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface IYieldToken {
    function mint(address to, uint256 amount) external;
}


contract TroverseGalaxyBucksManager is Ownable, ReentrancyGuard {
    using ECDSA for bytes32;

    bool public claimEnabled = false;
    mapping(address => uint64) public claimCount;
    mapping(bytes => bool) private usedClaimSignatures;
    
    address private signer;

    IYieldToken public yieldToken;


    constructor() { }


    function setYieldToken(address _yieldToken) external onlyOwner {
        yieldToken = IYieldToken(_yieldToken);
    }
    
    function airdrop(address[] memory _accounts, uint256[] memory _amounts) external onlyOwner {
        for (uint256 i; i < _accounts.length; i++) {
            yieldToken.mint(_accounts[i], _amounts[i]);
        }
    }
    
    function claim(uint256 _amount, uint8 _claimNonce, bytes calldata _signature) external nonReentrant {
        require(verifyOwnerSignature(keccak256(abi.encode(_msgSender(), address(this), _amount, _claimNonce)), _signature), "Invalid Signature");
        require(claimEnabled, "Claiming is not enabled.");
        require(!usedClaimSignatures[_signature], "You have already claimed your available rewards.");

        yieldToken.mint(_msgSender(), _amount);

        usedClaimSignatures[_signature] = true;
        claimCount[_msgSender()]++;
    }

    function toggleClaim(bool _claimEnabled) external onlyOwner {
        claimEnabled = _claimEnabled;
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function verifyOwnerSignature(bytes32 hash, bytes memory signature) private view returns (bool) {
        return hash.toEthSignedMessageHash().recover(signature) == signer;
    }
}
