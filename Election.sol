pragma solidity ^0.4.16;

contract Election{
    Passport passport;
    
    address public owner;
    uint candidatesCounter;
    address[] candidates;
    
    struct Candidate {
        bool isCandidate;
        uint votes;
    }
    
    mapping(address => Candidate) candidate;
    mapping(address => bool) voted;
    
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }
    
    modifier isOpen() {
    require(electionStatus == Status.Open);
    _;
    }
    
    modifier votingStarted() {
    require(electionStatus == Status.Voting);
    _;
    }
    
    modifier isClosed() {
    require(electionStatus == Status.Closed);
    _;
    }
    
    Status public electionStatus;
    
    enum Status {Open, Voting, Closed}
    
    function Election() public {
        passport = new Passport();
        owner = msg.sender;
        electionStatus = Status.Open;
    }
    
    function startVoting() public onlyOwner isOpen{
        require(candidatesCounter > 0);
        electionStatus = Status.Voting;
    }
    
    function bytes32ToStr(bytes32 _bytes32) internal constant returns (string){

    // string memory str = string(_bytes32);
    // TypeError: Explicit type conversion not allowed from "bytes32" to "string storage pointer"
    // thus we should fist convert bytes32 to bytes (to dynamically-sized byte array)

    bytes memory bytesArray = new bytes(32);
    for (uint256 i; i < 32; i++) {
        bytesArray[i] = _bytes32[i];
        }
    return string(bytesArray);
    }
    
    function addMe(string _name, string _surname, uint _age) public isOpen{
        passport.addUser(msg.sender, _name, _surname, _age);
    }
    
    function addNewUser(address _address, string _name, string _surname, uint _age)
    public
    onlyOwner 
    isOpen {
        passport.addUser(_address, _name, _surname, _age);
    }
    
    function chooseCandidate(address _address)
    public
    onlyOwner 
    isOpen {
        require(passport.getUserHash(_address) != 0x0);
        require(!(candidate[_address].isCandidate));
        candidate[_address].isCandidate = true;
        candidates.push(_address);
        candidatesCounter++;
    }
    
    function addNewCandidate(address _address, string _name, string _surname, uint _age)
    public
    onlyOwner 
    isOpen {
        require(!(candidate[_address].isCandidate));
        if (passport.getUserHash(_address) == 0x0) {
            passport.addUser(_address, _name, _surname, _age);
        }
        candidate[_address].isCandidate = true;
        candidates.push(_address);
        candidatesCounter++;
    }
    
    function deleteCandidate(address _address)
    public
    onlyOwner 
    isOpen {
        require(candidate[_address].isCandidate);
        candidate[_address].isCandidate = false;
        candidatesCounter--;
    }
    
    function getMyData() public view returns (string, string, uint, address) {
        return (bytes32ToStr(passport.getUserName(msg.sender)), bytes32ToStr(passport.getUserSurname(msg.sender)), passport.getUserAge(msg.sender), passport.getUserHash(msg.sender));
    }
    
    function getUserData(address _address)
    public
    view
    onlyOwner
    returns (string, string, uint, address) {
        return (bytes32ToStr(passport.getUserName(_address)), bytes32ToStr(passport.getUserSurname(_address)), passport.getUserAge(_address), passport.getUserHash(_address));
    }
    
    function vote(address _address)
    public
    votingStarted {
        require(candidate[_address].isCandidate);
        require(!(voted[msg.sender]));
        candidate[_address].votes++;
        voted[msg.sender] = true;
    }
    
    function stopVoting()
    public
    onlyOwner
    votingStarted {
        electionStatus = Status.Closed;
    }
    
    function getUserRank(address _address)
    public
    view
    isClosed
    returns (uint) {
        require(candidate[_address].isCandidate);
        return (candidate[_address].votes);
    }
    
    function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    owner = _newOwner;
    }
    
    function destroyElection() public onlyOwner{
        selfdestruct(this);
    }
}