//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract twitterProfile{

    struct userProfile{
        string displayName;
        string bio;
    }

    mapping(address => userProfile) public profiles;

    function setProfile(string memory _displayName, string memory _bio) public{
        profiles[msg.sender]= userProfile(_displayName, _bio);
    }
    function getProfile(address _user) public view returns (userProfile memory) {
        return profiles[_user];
    }
}