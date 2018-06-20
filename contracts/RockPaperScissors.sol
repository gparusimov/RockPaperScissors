pragma solidity ^0.4.21;

import "./Stoppable.sol";

contract RockPaperScissors is Stoppable {

    enum Choice { None, Other, Rock, Paper, Scissors }

    struct Game {
        address firstPlayer;
        bytes32 firstPlayerHashedChoice;
        Choice  firstPlayerChoice;
        address secondPlayer;
        bytes32 secondPlayerHashedChoice;
        Choice  secondPlayerChoice;
        uint amountRate;
    }

    uint gamesId = 1;

    mapping(uint => Game) games;

    event LogCreateGame(address firstPlayer, address secondPlayer, uint amountRate);
    event LogChoice(address player, bytes32 _choiceHashed, uint _gamesId, uint amountRate);
    event LogSendToWinner(address winner, uint _gamesId, uint amountRate);

    constructor()
    public
    {

    }

    function createGame(address _secondPlayer,uint _amountRate)
    public
    returns (uint newGamesId)
    {
        require(_secondPlayer != 0);

        games[gamesId].firstPlayer = msg.sender;
        games[gamesId].secondPlayer = _secondPlayer;
        games[gamesId].amountRate = _amountRate;
        emit LogCreateGame(games[gamesId].firstPlayer, games[gamesId].secondPlayer, games[gamesId].amountRate);
        return gamesId++;
    }

    function playerChoice(uint _gamesId, bytes32 _choiceHashed)
    external
    payable
    {
        require(_gamesId != 0);
        require(msg.value == games[_gamesId].amountRate);

        if (msg.sender == games[_gamesId].firstPlayer) {

            require(games[_gamesId].firstPlayerHashedChoice == 0);

            games[_gamesId].firstPlayerHashedChoice = _choiceHashed;
            emit LogChoice(msg.sender, _choiceHashed, _gamesId, msg.value);

        } else if (msg.sender == games[_gamesId].secondPlayer) {

            require(games[_gamesId].secondPlayerHashedChoice == 0);

            games[_gamesId].secondPlayerHashedChoice = _choiceHashed;
            emit LogChoice(msg.sender, _choiceHashed, _gamesId, msg.value);

        }
    }

    function checkChoice(uint _gamesId, string _password)
    external
    {

        require(_gamesId != 0);
        require(bytes(_password).length != 0);

        //both players made a choice
        require(games[_gamesId].firstPlayerHashedChoice != 0 && games[_gamesId].secondPlayerHashedChoice != 0);

        //call checkChoice only one of the players
        require(msg.sender == games[_gamesId].firstPlayer || msg.sender == games[_gamesId].secondPlayer);

        if (msg.sender == games[_gamesId].firstPlayer){

            Choice firstPlayerChoice = getUnhashedChoice(games[_gamesId].firstPlayerHashedChoice, _password);
            games[_gamesId].firstPlayerChoice = firstPlayerChoice;

        } else if (msg.sender == games[_gamesId].secondPlayer){

            Choice secondPlayerChoice = getUnhashedChoice(games[_gamesId].secondPlayerHashedChoice, _password);
            games[_gamesId].secondPlayerChoice = secondPlayerChoice;

        }


    }

    function sendRateToWinner(uint _gamesId)
    external
    {
        require(_gamesId != 0);

        Choice firstPlayerChoice =  games[_gamesId].firstPlayerChoice;
        Choice secondPlayerChoice = games[_gamesId].secondPlayerChoice;

        //both players have an unhashed choice
        require(uint(firstPlayerChoice) != 0 &&  uint(secondPlayerChoice) != 0);


        address winner;

        //if players chose other
        if (firstPlayerChoice  == Choice.Other && secondPlayerChoice != Choice.Other) {
            winner = games[_gamesId].secondPlayer;
        }

        if (firstPlayerChoice  != Choice.Other && secondPlayerChoice == Choice.Other) {
            winner = games[_gamesId].firstPlayer;
        }


        if (firstPlayerChoice == Choice.Rock) {
            if (secondPlayerChoice == Choice.Paper) {
                winner = games[_gamesId].firstPlayer;
            } else if (secondPlayerChoice == Choice.Scissors) {
                winner = games[_gamesId].firstPlayer;
            }
        } else if (firstPlayerChoice == Choice.Paper) {
            if (secondPlayerChoice == Choice.Rock) {
                winner = games[_gamesId].secondPlayer;
            } else if (secondPlayerChoice == Choice.Scissors) {
                winner = games[_gamesId].secondPlayer;
            }
        } else if (firstPlayerChoice == Choice.Scissors) {
            if (secondPlayerChoice == Choice.Rock) {
                winner = games[_gamesId].secondPlayer;
            } else if (secondPlayerChoice == Choice.Paper) {
                winner =  games[_gamesId].firstPlayer;
            }
        }

        if (winner != 0) {
            emit LogSendToWinner(winner,_gamesId, games[_gamesId].amountRate);
            winner.transfer(2*games[_gamesId].amountRate);
        } else {
            games[_gamesId].firstPlayer.transfer(games[_gamesId].amountRate);
            games[_gamesId].secondPlayer.transfer(games[_gamesId].amountRate);
        }

        // game over
        delete games[_gamesId];
    }

    function  getUnhashedChoice(bytes32 _hashedChoice, string _password)
    private
    pure
    returns (Choice choice) {
        if (_hashedChoice == keccak256(uint(Choice.Rock), _password)) {
            return Choice.Rock;
        } else if (_hashedChoice == keccak256(uint(Choice.Paper), _password)) {
            return Choice.Paper;
        } else if (_hashedChoice == keccak256(uint(Choice.Scissors), _password)) {
            return Choice.Scissors;
        }
        return Choice.Other;
    }

}
