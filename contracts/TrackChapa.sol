// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }
}

contract TrackChapa is Ownable {
    struct Transaction {
        bool status;
        uint256 amount;
    }

    mapping(address => mapping(uint256 => Transaction)) transactions;
    mapping(address => uint256) public transactionNumber;

    function getTransaction(address user)
        public
        view
        returns (Transaction[] memory)
    {
        Transaction[] memory ret = new Transaction[](transactionNumber[user]);

        for (uint256 i = 1; i <= transactionNumber[user]; i++) {
            ret[i - 1] = transactions[user][i];
        }
        return ret;
    }

    function newTransaction(address user, uint256 amount) public {
        transactionNumber[user]++;

        Transaction storage transaction = transactions[user][
            transactionNumber[user]
        ];

        transaction.amount = amount;
        transaction.status = false;
    }

    function confirmTransaction(address user, uint256 id) public onlyOwner {
        transactions[user][id].status = true;
    }
}
