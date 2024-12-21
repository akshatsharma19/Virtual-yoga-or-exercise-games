// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VirtualYogaGame {

    // Mapping of user addresses to profiles
    mapping(address => Profile) public users;
    
    // Mapping of challenge IDs to challenges
    mapping(uint256 => Challenge) public challenges;
    
    uint256 public challengeCount;
    uint256 public userCount;

    // Events
    event NewProfile(uint256 _id, address _userAddress);
    event NewChallengeCreated(uint256 _id, string _name);
    event ChallengeCompleted(uint256 _challengeId, address _userAddress);
    event ParticipatedInChallenge(uint256 _challengeId, address _userAddress);

    // Struct for User Profile
    struct Profile {
        uint256 id;      // Unique identifier for the profile
        string name;     // User's display name
        uint256 points;  // Total rewards (tokens) earned by user
        mapping(uint256 => bool) completedChallenges; // Mapping of challengeId to completed status
    }

    // Struct for Challenge
    struct Challenge {
        uint256 id;      // Unique identifier for the challenge
        string name;     // Name of the exercise or yoga pose set
        uint256 points;  // Reward (tokens) earned upon completion
        mapping(address => bool) participants; // Mapping of participants
    }

    // Function to create a new user profile
    function createProfile(string memory _displayName) public returns (uint256) {
        require(bytes(_displayName).length > 0, "Display name cannot be empty");

        // Increment user count and create a new profile
        userCount++;
        Profile storage newProfile = users[msg.sender];
        newProfile.id = userCount;
        newProfile.name = _displayName;
        newProfile.points = 0;

        emit NewProfile(newProfile.id, msg.sender);
        return newProfile.id;
    }

    // Function to create a new challenge
    function createChallenge(string memory _name, uint256 _points) public returns (uint256) {
        require(bytes(_name).length > 0, "Challenge name cannot be empty");
        require(_points > 0, "Points must be greater than zero");

        // Increment challenge count and create a new challenge
        challengeCount++;
        Challenge storage newChallenge = challenges[challengeCount];
        newChallenge.id = challengeCount;
        newChallenge.name = _name;
        newChallenge.points = _points;

        emit NewChallengeCreated(newChallenge.id, _name);
        return newChallenge.id;
    }

    // Function for a user to participate in a challenge
    function participateInChallenge(uint256 _challengeId) public {
        Challenge storage selectedChallenge = challenges[_challengeId];
        require(_challengeId > 0 && _challengeId <= challengeCount, "Invalid challenge ID");
        
        // Check if the user is already participating
        require(!selectedChallenge.participants[msg.sender], "You are already participating in this challenge");

        // Update the participation status
        selectedChallenge.participants[msg.sender] = true;

        emit ParticipatedInChallenge(_challengeId, msg.sender);
    }

    // Function for a user to complete a challenge
    function completeChallenge(uint256 _challengeId) public {
        Challenge storage selectedChallenge = challenges[_challengeId];
        Profile storage userProfile = users[msg.sender];

        require(_challengeId > 0 && _challengeId <= challengeCount, "Invalid challenge ID");
        require(selectedChallenge.participants[msg.sender], "You must participate in the challenge before completing it");
        
        // Check if the user has already completed the challenge
        require(!userProfile.completedChallenges[_challengeId], "You have already completed this challenge");

        // Update the challenge completion status for the user
        userProfile.completedChallenges[_challengeId] = true;

        // Reward the user with points
        userProfile.points += selectedChallenge.points;

        emit ChallengeCompleted(_challengeId, msg.sender);
    }

    // Function to get the total points for a user
    function getUserPoints(address _user) public view returns (uint256) {
        return users[_user].points;
    }

    // Function to get user profile
    function getUserProfile(address _user) public view returns (uint256, string memory, uint256) {
        Profile storage userProfile = users[_user];
        return (userProfile.id, userProfile.name, userProfile.points);
    }

    // Function to get challenge details
    function getChallengeDetails(uint256 _challengeId) public view returns (string memory, uint256) {
        Challenge storage selectedChallenge = challenges[_challengeId];
        return (selectedChallenge.name, selectedChallenge.points);
    }
}
