pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// @title Ownable
// ----------------------------------------------------------------------------
contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() { require(msg.sender == owner); _; }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}
// ----------------------------------------------------------------------------
// @Project Panchigi
// @Creator RyuK
// ----------------------------------------------------------------------------
contract Panchigi is Ownable {
    mapping(address => uint256) public totalGame;
    mapping(address => uint256) public winGame;
    
    bool public IsGHArrest = false;
    uint256 maxBettingValue = 10000000000000000000;
    uint8 public recentValue = 0;
    
    uint private mySeed = 0;
    
    event DealEvent(address indexed _user, bool _isWin, uint8 _randomValue);
    event WithdrawEvent(address indexed _address, uint256 _amount);
  
    function () external payable  {
        require(!IsGHArrest);
        
        if(msg.sender != owner) {
            require(msg.value * 2 <= address(this).balance);
            require(msg.value <= maxBettingValue);
            
            bool isWin = false;
            uint8 result = random();
            recentValue = result;
        
            if(result < 90 && result % 2 == 1) {
                isWin = transferUser();
                winGame[msg.sender] += 1;
            }
            
            totalGame[msg.sender] += 1;
            emit DealEvent(msg.sender, isWin, result);
        }
    }
    
    function random() private view returns (uint8) {
       return uint8(uint256(keccak256(block.timestamp, mySeed)) % 100);
   }
    
    function Arrest(bool _isPrison) external onlyOwner {
        IsGHArrest = _isPrison;
    }
    
    function setSeedValue(uint256 _seed) external onlyOwner {
        mySeed = _seed;
    }
    
     function setMaxBettingValue(uint256 _value) external onlyOwner {
        maxBettingValue = _value;
    }
    
    function transferUser() private returns (bool) {
        transfer(msg.sender, msg.value * 2);
        
        return true;
    }

    function Withdraw(uint256 _amount) external onlyOwner {
        transfer(owner, _amount);
    }
    
    function transfer(address _to, uint256 _amount) internal {
        address(_to).transfer(_amount);
        
        emit WithdrawEvent(_to, _amount);
    }
}