pragma solidity ^0.4.21;

import "./Owned.sol";

contract Stoppable is Owned {
    bool private isStopped;

    modifier onlyIfRunning()
    {
        require (!isStopped);
        _;
    }

    event LogNewStoppableConstruct(address _sender);
    event LogStoppableStopContract(address _sender);
    event LogStoppableResumeContract(address _sender);

    constructor()
    public
    {
        isStopped = false;
        emit LogNewStoppableConstruct(msg.sender);
    }

    function stopContract()
    onlyOwner
    onlyIfRunning
    returns (bool _success)
    {
        isStopped = true;

        emit LogStoppableStopContract (msg.sender);
        return true;
    }

    function resumeContract()
    onlyOwner
    returns (bool _success)
    {
        require(isStopped);
        isStopped = false;

        emit LogStoppableResumeContract(msg.sender);
        return true;
    }

    function isStoppedState()
    public
    view
    returns (bool _isStopped)
    {
        return isStopped;
    }
}
