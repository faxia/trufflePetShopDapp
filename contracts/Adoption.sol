pragma solidity ^0.5.0;

contract Adoption {
    address[16] public adopters;

    // 购买一只宠物
    function adopt(uint petId) public returns (uint) {
        require(petId >= 0 && petId <= 15);

        adopters[petId] = msg.sender;

        return petId;
    }

    // 获取购买用户
    function getAdopters() public view returns (address[16] memory) { 
        return adopters; 
    }

}