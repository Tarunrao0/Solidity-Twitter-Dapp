//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IProfile {
    struct userProfile {
        string displayName;
        string bio;
    }
    function getProfile (address _user) external  view returns (userProfile memory);
}


contract Twitter is Ownable{

    uint16 public MAX_TWEET_LENGTH = 280; //a global constant limiting the max characters one tweet can take

    //optimization of the various data a tweet can have
    struct Tweet{
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }
    //converting the address of the user to contain in their tweets in an array

    mapping (address=>Tweet[]) public tweets;

    IProfile profileContract;
    
    //creating events!! 
    
    event TweetCreated(uint256 id, address author, string content, uint256 timestamp);//event for creation of a tweet
    event TweetLiked(address liker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);//event for recieving a like on the tweet
    event TweetUnliked(address unliker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);//event for recieving an unlike on the tweet

    modifier OnlyRegistered(){
        IProfile.userProfile memory userProfileTemp = profileContract.getProfile(msg.sender);
        require(bytes(userProfileTemp.displayName).length>0, "please register yourself");
        _;
        }
    




    constructor(address _profileContract) {
       profileContract = IProfile(_profileContract);
    }
    //function for writing the tweet 

    function createTweet(string memory _tweet) public OnlyRegistered{

        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet too long");

        Tweet memory NewTweet= Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(NewTweet); //adding tweets to the users array

        emit TweetCreated(NewTweet.id, NewTweet.author, NewTweet.content, NewTweet.timestamp);//event notification
    }

    //function that lets you like a tweet

    function likeTweet(address author, uint256 id) external OnlyRegistered{
        require(tweets[author][id].id==id, "tweet does not exist"); //confirming the existance of the tweet by matching its IDs
        tweets[author][id].likes++;

        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);//event notification
    }
     //function that lets you unlike a tweet

    function unlikeTweet(address author, uint256 id) external OnlyRegistered {
        require(tweets[author][id].id==id, "tweet does not exist"); //confirming the existance of the tweet by matching its IDs
        require(tweets[author][id].likes>0,"cannot unlike this tweet"); //making sure the like counter doesnt go below zero
        tweets[author][id].likes--;

        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes);//event notification
    }

    //lets user view a single tweet at a specified index

    function getTweet( uint256 _i) public view returns(Tweet memory){
        return tweets[msg.sender][_i];
    }

    //lets user view all the tweets 

    function getAllTweets(address _owner) public view returns(Tweet[] memory){
        return tweets[_owner];
    }

    //function for the owner to change the max characters 

    function changeTweetLength(uint16 newTweetLength) public{
        MAX_TWEET_LENGTH=newTweetLength;
    }
    function getTotalLikes(address _author) external  view returns(uint256){
        uint totalLikes;
        for( uint i=0; i < tweets[_author].length ; i++){
            totalLikes += tweets[_author][i].likes;
        }
        return totalLikes;
    }
    
}