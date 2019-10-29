pragma solidity ^0.4.16;

contract Passport {

    struct PasportData {
        bytes32 name;
        bytes32 surname;
        uint age;
        address hash;
    }
    
    mapping(address => PasportData) public users;
    
    modifier registered(address _address) {
        require(users[_address].hash != 0x0);
        _;
    }
    
    modifier notRegistered(address _address) {
        require(users[_address].hash == 0x0);
        _;
    }
    
    function Passport() public{
    }
    
    function stringToBytes32(string memory source) returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    	}
	}
    function addUser(address _address, string _name, string _surname, uint _age) public notRegistered(_address){
        users[_address].name = stringToBytes32(_name);
        users[_address].surname = stringToBytes32(_surname);
        users[_address].age = _age;
        users[_address].hash = _address;
    }
    
    function getUserHash(address _address) public returns (address) {
        return (users[_address].hash);
    }
    
    function getData(address _address) public registered(_address) returns (bytes32, bytes32, uint, address) {
        return (users[_address].name, users[_address].surname, users[_address].age, users[_address].hash);
    }
    
    function getUserName(address _address) public returns (bytes32) {
        return (users[_address].name);
    }
    
    function getUserSurname(address _address) public returns (bytes32) {
        return (users[_address].surname);
    }
    
    function getUserAge(address _address) public returns (uint) {
        return (users[_address].age);
    }
}