// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dao {
    struct Proposal {
        string name;
        string description;
        uint256 voteStartingDate;
        uint256 voteEndingDate;
        uint256 voteAganist;
        uint256 voteFor;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) voters;
    uint256 public proposalId;

    function addVote(
        string calldata _name,
        string calldata description,
        uint256 startingDate,
        uint256 endingDate
    ) public {
        proposalId++;
        uint256 id = proposalId;
        Proposal storage proposal = proposals[id];
        proposal.name = _name;
        proposal.description = description;
        proposal.voteStartingDate = startingDate;
        proposal.voteEndingDate = endingDate;
        proposal.voteAganist = 0;
        proposal.voteFor = 0;
    }

    function voting(uint256 _proposalId, bool _vote) public {
        require(!voters[_proposalId][msg.sender], "already voted");
        require(proposalId >= _proposalId, "proposal doesnot exisit");
        require(
            block.timestamp >= proposals[_proposalId].voteStartingDate,
            "voting not started"
        );
        require(
            block.timestamp < proposals[_proposalId].voteEndingDate,
            "voting ended"
        );
        voters[_proposalId][msg.sender] = true;
        if (_vote) {
            proposals[_proposalId].voteFor++;
        } else {
            proposals[_proposalId].voteAganist++;
        }
    }

    function getProposal(uint256 _proposalId)
        public
        view
        returns (Proposal memory)
    {
        return proposals[_proposalId];
    }

    function getProposals()
        public
        view
        returns (Proposal[] memory, bool[] memory)
    {
        Proposal[] memory ret = new Proposal[](proposalId);
        bool[] memory voted = new bool[](proposalId);

        for (uint256 i = 1; i <= proposalId; i++) {
            ret[i - 1] = proposals[i];
            voted[i - 1] = voters[i][msg.sender];
        }
        return (ret, voted);
    }

    function isUserVoted(uint256 _id) public view returns (bool) {
        return voters[_id][msg.sender];
    }
}
