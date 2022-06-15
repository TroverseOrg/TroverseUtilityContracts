// contracs/TroverseGalaxyBucksPolygon.sol
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


contract TroverseGalaxyBucksPolygon is ERC20, Ownable {
    mapping(address => bool) private operators;
    address public manager;

    // keeping it for checking, whether deposit being called by valid address or not
    address public childChainManagerProxy;

    event OperatorStateChanged(address _operator, bool _state);
    event ManagerChanged(address _manager);
    event UpdatedChildChainManager(address newChildChainManagerProxy);


    constructor() ERC20("Troverse Galaxy Bucks", "G-Bucks") { }
    

    modifier onlyOperator() {
        require(operators[_msgSender()], "The caller is not an operator");
        _;
    }

    function updateOperatorState(address _operator, bool _state) external onlyOwner {
        require(_operator != address(0), "Bad Operator address");
        operators[_operator] = _state;

        emit OperatorStateChanged(_operator, _state);
    }

    function updateManager(address _manager) external onlyOwner {
        operators[manager] = false;

        if (_manager != address(0)) {
            operators[_manager] = true;

            emit OperatorStateChanged(_manager, true);
        }

        manager = _manager;

        emit ManagerChanged(_manager);
    }

    function mintByTransfer(address _to, uint256 _amount) external onlyOperator {
        _transfer(manager, _to, _amount);
    }

    function burnByTransfer(address _from, uint256 _amount) external onlyOperator {
        _transfer(_from, manager, _amount);
    }

    function updateChildChainManager(address newChildChainManagerProxy) external onlyOwner {
        require(newChildChainManagerProxy != address(0), "Bad ChildChainManagerProxy address");
        childChainManagerProxy = newChildChainManagerProxy;

        emit UpdatedChildChainManager(newChildChainManagerProxy);
    }

    function deposit(address user, bytes calldata depositData) external {
        require(_msgSender() == childChainManagerProxy, "You're not allowed to deposit");
        
        uint256 amount = abi.decode(depositData, (uint256));
        _mint(user, amount);
    }

    function withdraw(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}
