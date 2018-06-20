pragma solidity ^0.4.21;

contract Owned {

    address public owner;

    event LogChangeOwner(address sender, address newOwner);

    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    constructor()
    public
    {
        owner = msg.sender;
    }

    function changeOwner(address newOwner)
    public
    onlyOwner
    returns(bool success)
    {
        require(newOwner!=0);
        owner = newOwner;
        emit LogChangeOwner(msg.sender, newOwner);
        return true;
    }

}