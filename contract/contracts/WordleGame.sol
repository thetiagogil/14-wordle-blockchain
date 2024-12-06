// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./WordleToken.sol";

contract WordleGame {
    WordleToken public token;
    string private constant FIXED_WORD = "APPLE";
    uint256 public constant GUESS_FEE = 10 * 10 ** 18;

    event GuessMade(address indexed player, string guess, bool isCorrect);

    constructor(WordleToken _token) {
        token = _token;
    }

    function guess(string memory userGuess) public {
        require(bytes(userGuess).length == 5, "Guess must be 5 letters long");
        require(token.transferFrom(msg.sender, address(this), GUESS_FEE), "Token transfer failed");

        bool isCorrect = keccak256(abi.encodePacked(userGuess)) == keccak256(abi.encodePacked(FIXED_WORD));
        emit GuessMade(msg.sender, userGuess, isCorrect);
    }
}
