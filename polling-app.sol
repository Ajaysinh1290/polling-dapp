//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <=0.9.0;

contract Poll {
    struct PollItem {
        string title;
        string[] optionsTitles;
        uint256[] optionsVotes;
        mapping(address => bool) voters;
        address owner;
        bool isClosed;
    }
  modifier onlyPollOwner(uint256 pollIndex) {
        require(pollIndex < polls.length, "Invalid poll index");
        require(polls[pollIndex].owner == msg.sender, "You are not allowed to perform this action");
        _;
    }
    modifier onlyOpenPoll(uint256 pollIndex) {
        require(pollIndex < polls.length, "Invalid poll index");
        require(!polls[pollIndex].isClosed, "Poll is closed");
        _;
    }

    PollItem[] polls;

    function createPoll(string memory pollTitle, string[] memory options)
        public
    {
        require(options.length > 1, "Must provide at least two options");
        PollItem storage newPoll = polls.push();
        newPoll.title = pollTitle;
        newPoll.owner = msg.sender;
        newPoll.isClosed = false;
        newPoll.optionsTitles = new string[](options.length); // Create the dynamic array
        newPoll.optionsVotes = new uint256[](options.length); // Create the dynamic array

        for (uint256 i = 0; i < options.length; i++) {
            newPoll.optionsTitles[i] = options[i]; // Assign values to optionsTitles
            newPoll.optionsVotes[i] = 0; // Initialize optionsVotes to zero
        }
    }

    function vote(uint256 pollIndex, uint256 optionIndex) public {
        require(pollIndex < polls.length, "Invalid poll index");
        require(
            optionIndex < polls[pollIndex].optionsVotes.length,
            "Invalid vote index"
        );
        require(!polls[pollIndex].isClosed, "Poll is closed");
        require(!polls[pollIndex].voters[msg.sender], "Already voted");
        polls[pollIndex].optionsVotes[optionIndex]++;
        polls[pollIndex].voters[msg.sender] = true;
    }

    function getAvailablePollsIds() public view returns (uint256[] memory) {
        uint256[] memory activePolls = new uint256[](polls.length); // Fixed-size array
        uint256 activeCount = 0; // Counter for active polls

        for (uint256 i = 0; i < polls.length; i++) {
            if (!polls[i].isClosed && !polls[i].voters[msg.sender] && polls[i].owner != msg.sender) {
                activePolls[activeCount] = i;
                activeCount++;
            }
        }

        // Resize the activePolls array to the number of active polls
        uint256[] memory activeIds = new uint256[](activeCount);
        for (uint256 j = 0; j < activeCount; j++) {
            activeIds[j] = activePolls[j];
        }

        return activeIds;
    }

    function getVotedPollsIds() public view returns (uint256[] memory) {
        uint256[] memory votedPolls = new uint256[](polls.length);
        uint256 activeCount = 0;

        for (uint256 i = 0; i < polls.length; i++) {
            if (polls[i].voters[msg.sender]) {
                votedPolls[activeCount] = i;
                activeCount++;
            }
        }

        uint256[] memory votedPollsIds = new uint256[](activeCount);
        for (uint256 j = 0; j < activeCount; j++) {
            votedPollsIds[j] = votedPolls[j];
        }

        return votedPollsIds;
    }

    function getMyPollsIds() public view returns (uint256[] memory) {
        uint256[] memory myPolls = new uint256[](polls.length);
        uint256 activeCount = 0;

        for (uint256 i = 0; i < polls.length; i++) {
            if (polls[i].owner == msg.sender) {
                myPolls[activeCount] = i;
                activeCount++;
            }
        }

        uint256[] memory myPollsIds = new uint256[](activeCount);
        for (uint256 j = 0; j < activeCount; j++) {
            myPollsIds[j] = myPolls[j];
        }

        return myPollsIds;
    }

    function getPollDetailsFromId(uint256 id)
        public
        view
        returns (
            string memory,
            string[] memory,
            uint256[] memory,
            address,
            bool
        )
    {
        require(id < polls.length, "Invalid poll index");

        return (
            polls[id].title,
            polls[id].optionsTitles,
            polls[id].optionsVotes,
            polls[id].owner,
            polls[id].isClosed
        );
    }

    function closePoll(uint256 id) public {
        require(
            polls[id].owner == msg.sender,
            "You are not allowed to close this poll"
        );
        require(id < polls.length, "Invalid poll index");
        polls[id].isClosed = true;
    }
}
