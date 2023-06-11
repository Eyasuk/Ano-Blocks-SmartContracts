// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract CreditLoan {
    struct Loan {
        uint256 loanAmount;
        uint256 returnedLoan;
        uint256 returnDate;
        uint256 interestRate;
        uint256 loanCompletedDate;
    }

    struct UserLoanStatus {
        bool status;
        uint256 loanNumber;
    }

    IERC20 etbc_token;
    uint256 day30IntersetRate = 5;
    uint256 day60IntersetRate = 7;
    uint256 day90IntersetRate = 10;
    uint256 creditLimit = 5000;

    constructor(address tokenAddress) {
        etbc_token = IERC20(tokenAddress);
    }

    mapping(address => mapping(uint256 => Loan)) userLoans;
    mapping(address => UserLoanStatus) userLoanStatus;

    function giveLoan(
        uint256 amount,
        uint256 amountEther,
        uint256 returnDate
    ) public {
        uint256 interst = getIntersetValue(returnDate);
        uint256 limit = calculateCreditLimit();
        uint256 contractBalance = etbc_token.balanceOf(address(this));
        require(amount <= limit, "above your limit");
        require(
            amountEther <= contractBalance,
            "Not enough tokens in the reserve"
        );
        etbc_token.transfer(msg.sender, amountEther);
        userLoanStatus[msg.sender].status = true;
        userLoanStatus[msg.sender].loanNumber++;
        Loan storage loan = userLoans[msg.sender][
            userLoanStatus[msg.sender].loanNumber
        ];

        loan.loanAmount = (amount * interst) / 100;
        loan.returnDate = block.timestamp + (returnDate * 86400);
        loan.interestRate = interst;
        loan.returnedLoan = amount;
    }

    function pay(uint256 amount, uint256 amountEther) public {
        require(userLoanStatus[msg.sender].status, "no debt in current time");
        Loan storage loan = userLoans[msg.sender][
            userLoanStatus[msg.sender].loanNumber
        ];
        require(amount <= loan.loanAmount, "max payment");
        etbc_token.transferFrom(msg.sender, address(this), amountEther);
        loan.returnedLoan = loan.returnedLoan - amount;
        if (loan.returnDate == 0) {
            loan.loanCompletedDate = block.timestamp;
            userLoanStatus[msg.sender].status = false;
        }
    }

    function getUserLoans() public view returns (Loan[] memory) {
        uint256 noOfLoan = userLoanStatus[msg.sender].loanNumber;

        Loan[] memory ret = new Loan[](noOfLoan);
        for (uint256 i = 1; i <= noOfLoan; i++) {
            ret[i - 1] = userLoans[msg.sender][i];
        }
        return ret;
    }

    function currentUserLoan() public view returns (uint256) {
        if (userLoanStatus[msg.sender].status) {
            return
                userLoans[msg.sender][userLoanStatus[msg.sender].loanNumber]
                    .loanAmount -
                userLoans[msg.sender][userLoanStatus[msg.sender].loanNumber]
                    .returnedLoan;
        } else {
            return 0;
        }
    }

    function getIntersetValue(uint256 returnDate)
        internal
        view
        returns (uint256)
    {
        require(
            returnDate == 30 || returnDate == 60 || returnDate == 90,
            "incorrect return date"
        );
        if (returnDate == 30) {
            return day30IntersetRate;
        } else if (returnDate == 60) {
            return day60IntersetRate;
        } else {
            return day90IntersetRate;
        }
    }

    function calculateCreditLimit() public view returns (uint256) {
        uint256 credit = calculateCredit();
        uint256 limit = (credit * creditLimit) / 800;
        return limit;
    }

    function calclulateCreditLastLoan(address user)
        internal
        view
        returns (int256 value)
    {
        Loan memory userLastLoan = userLoans[user][
            userLoanStatus[user].loanNumber
        ];
        if (userLastLoan.returnDate - userLastLoan.loanCompletedDate >= 0)
            return 800;
        else {
            return -800;
        }
    }

    function calclulateCreditLoanStatus(address user)
        internal
        view
        returns (int256 value)
    {
        if (userLoanStatus[user].status) return -800;
        else {
            return 800;
        }
    }

    function calclulateCreditPayedLoans(address user)
        internal
        view
        returns (uint256 value)
    {
        if (userLoanStatus[user].loanNumber >= 8) return 800;
        else return (8 - userLoanStatus[user].loanNumber) * 100;
    }

    function calculateCredit() public view returns (uint256) {
        int256 creditscore = ((calclulateCreditLastLoan(msg.sender) +
            calclulateCreditLoanStatus(msg.sender) +
            int256(calclulateCreditPayedLoans(msg.sender))) * 3) / 10;
        return uint256(creditscore);
    }
}
