// contracs/TroversePasses.sol
// SPDX-License-Identifier: MIT

// ████████╗██████╗  ██████╗ ██╗   ██╗███████╗██████╗ ███████╗███████╗    
// ╚══██╔══╝██╔══██╗██╔═══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██╔════╝    
//    ██║   ██████╔╝██║   ██║██║   ██║█████╗  ██████╔╝███████╗█████╗      
//    ██║   ██╔══██╗██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗╚════██║██╔══╝      
//    ██║   ██║  ██║╚██████╔╝ ╚████╔╝ ███████╗██║  ██║███████║███████╗    
//    ╚═╝   ╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝    

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TroversePasses is ERC1155, Ownable {
    mapping(address => bool) public operators;
    
    string public constant name = "Troverse Passes";
    string public constant symbol = "PASS";
    string private _uriPrefix;

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) public tokenSupply;

    address public minter;

    
    constructor() ERC1155("") { }

    
    modifier onlyMinter() {
        require(msg.sender == minter, "The caller is not the minter");
        _;
    }

    modifier onlyOperator() {
        require(operators[_msgSender()], "The caller is not an operator");
        _;
    }
    
    function updateOperatorState(address _operator, bool _state) external onlyOwner {
        operators[_operator] = _state;
    }
    
    function updateMinter(address _minter) external onlyOwner {
        minter = _minter;
    }
    
    function operatorTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external onlyOperator {
        _safeTransferFrom(from, to, id, amount, data);
    }
    
    function operatorBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external onlyOperator {
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) external onlyMinter {
        _mint(account, id, amount, data);
        tokenSupply[id] += amount;
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return _tokenURI(_id);
    }

    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    function _tokenURI(uint256 id) private view returns (string memory) {
        return string(abi.encodePacked(_uriPrefix, _tokenURIs[id]));
    }

    function setTokenURI(uint256 id, string memory newURI) external onlyOwner {
        _tokenURIs[id] = newURI;
    }

    function setURI(string memory newURI) external onlyOwner {
        _uriPrefix = newURI;
    }
}
