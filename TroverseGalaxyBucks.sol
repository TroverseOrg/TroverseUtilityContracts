// contracts/TroverseGalaxyBucks.sol
// SPDX-License-Identifier: MIT

// ████████╗██████╗  ██████╗ ██╗   ██╗███████╗██████╗ ███████╗███████╗    
// ╚══██╔══╝██╔══██╗██╔═══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██╔════╝    
//    ██║   ██████╔╝██║   ██║██║   ██║█████╗  ██████╔╝███████╗█████╗      
//    ██║   ██╔══██╗██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗╚════██║██╔══╝      
//    ██║   ██║  ██║╚██████╔╝ ╚████╔╝ ███████╗██║  ██║███████║███████╗    
//    ╚═╝   ╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝    

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


interface IRootChainManager {
    function depositFor(address user, address rootToken, bytes calldata depositData) external;
}


contract TroverseGalaxyBucks is ERC20, Ownable {
    mapping(address => bool) public operators;
    address public manager;

    address public erc20Predicate;
    address public erc20PolygonManager;

    IRootChainManager public rootChainManager;

    constructor(
        address _erc20Predicate,
        address _erc20PolygonManager,
        IRootChainManager _rootChainManager
    ) ERC20("Troverse Galaxy Bucks", "G-Bucks") {
        erc20Predicate = _erc20Predicate;
        erc20PolygonManager = _erc20PolygonManager;
        rootChainManager = _rootChainManager;
    }


    modifier onlyOperator() {
        require(operators[_msgSender()], "The caller is not an operator");
        _;
    }

    modifier onlyManager() {
        require(manager == _msgSender(), "The caller is not the manager");
        _;
    }

    function updateOperatorState(address _operator, bool _state) external onlyOwner {
        operators[_operator] = _state;
    }

    function updateManager(address _manager) external onlyOwner {
        operators[manager] = false;

        if (_manager != address(0)) {
            operators[_manager] = true;
        }

        manager = _manager;
    }

    function mint(address _to, uint256 _amount) external onlyManager {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyOperator {
        _burn(_from, _amount);
    }

    function refillPolygonToken(uint256 _amount) external onlyOwner {
        _mint(_msgSender(), _amount);
        approve(erc20Predicate, _amount);
        rootChainManager.depositFor(
            erc20PolygonManager,
            address(this),
            abi.encode(_amount)
        );
    }

    function updateErc20Predicate(address _newErc20Predicate)
        external
        onlyOwner
    {
        require(
            _newErc20Predicate != address(0),
            "Bad Erc20Predicate address"
        );
        erc20Predicate = _newErc20Predicate;
    }

    function updateRootChainManager(IRootChainManager _newRootChainManager)
        external
        onlyOwner
    {
        require(
            address(_newRootChainManager) != address(0),
            "Bad RootChainManager address"
        );
        rootChainManager = _newRootChainManager;
    }

    function updateErc20PolygonManager(address _erc20PolygonManager)
        external
        onlyOwner
    {
        require(
            _erc20PolygonManager != address(0),
            "Bad ERC20PolygonManager address"
        );
        erc20PolygonManager = _erc20PolygonManager;
    }
}
