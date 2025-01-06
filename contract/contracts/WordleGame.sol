// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./WordleToken.sol";

contract WordleGame {
	address public token;
	address public admin;
	string private WORD;
	uint256 public constant GUESS_FEE = 1 ether;
	uint256 public constant MAX_ATTEMPTS = 5;

	mapping(address => string[]) private userGuesses;
	mapping(address => bool) private hasGuessedCorrectly;

	constructor(address _token) {
		token = _token;
		admin = msg.sender;
	}

	modifier onlyAdmin() {
		require(msg.sender == admin, "Only admin can perform this action");
		_;
	}

	// Function to set the word (admin only)
	function setWord(string memory _word) external onlyAdmin {
		require(bytes(_word).length == 5, "Word must be 5 letters long");
		WORD = _word;
	}

	// Function to make a guess
	function makeGuess(string memory userGuess) public {
		require(bytes(userGuess).length == 5, "Guess must be 5 letters long!");
		require(
			IERC20(token).balanceOf(msg.sender) >= GUESS_FEE,
			"Insufficient tokens!"
		);
		require(
			!hasGuessedCorrectly[msg.sender],
			"You have already guessed correctly!"
		);
		require(
			userGuesses[msg.sender].length < MAX_ATTEMPTS,
			"You have exceeded the maximum number of guesses!"
		);

		IERC20(token).transferFrom(msg.sender, address(this), GUESS_FEE);

		// Update the user's guesses
		userGuesses[msg.sender].push(userGuess);

		// Check if the guess is correct
		bool isCorrect = keccak256(abi.encodePacked(userGuess)) ==
			keccak256(abi.encodePacked(WORD));
		if (isCorrect) {
			hasGuessedCorrectly[msg.sender] = true;
		}
	}

	// Function to calculate letter statuses for a specific guess
	function getLetterStatuses(
		address user,
		uint256 guessIndex
	) public view returns (uint8[5] memory) {
		require(guessIndex < userGuesses[user].length, "Invalid guess index!");

		string memory userGuess = userGuesses[user][guessIndex];
		bytes memory guessBytes = bytes(userGuess);
		bytes memory fixedBytes = bytes(WORD);

		uint8[5] memory letterStatuses;

		bool[5] memory usedFixedBytes;

		for (uint8 i = 0; i < 5; i++) {
			if (guessBytes[i] == fixedBytes[i]) {
				letterStatuses[i] = 2; // Using 2 for correct letters
				usedFixedBytes[i] = true;
			} else {
				for (uint8 j = 0; j < 5; j++) {
					if (!usedFixedBytes[j] && guessBytes[i] == fixedBytes[j]) {
						letterStatuses[i] = 1; // Using 1 for misplaced letters
						usedFixedBytes[j] = true;
						break;
					}
				}
			}
		}

		return letterStatuses;
	}

	// Function to get all the user's guesses
	function getUserGuesses(
		address user
	) public view returns (string[] memory) {
		return userGuesses[user];
	}

	// Function to check if the user has guessed correctly
	function getHasUserGuessedCorrectly(
		address user
	) public view returns (bool) {
		return hasGuessedCorrectly[user];
	}
}
