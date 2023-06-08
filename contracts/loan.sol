pragma solidity ^0.8.0;

contract CreditLoan {
    struct Loan {
        uint256 loanAmount;
        uint256 returnedLoan;
        uint256 returnDate;
        uint256 interestRate;
        uint256 loanCompletedDate;
        bool status;
    }

    struct UserLoanStatus {
        bool status;
        uint256 loanNumber;
    }

    uint256 day30IntersetRate = 5;
    uint256 day60IntersetRate = 7;
    uint256 day90IntersetRate = 10;

    mapping(address => mapping(uint256 => Loan)) userLoans;
    mapping(address => UserLoanStatus) userLoanStatus;

    function returnCreditScore() {}

    function giveLoan(uint256 amount, uint256 returnDate) {
        const interst = getIntersetValue(returnDate);
        //calculate cridit
        //if send
        //else revert
    }

    function pay() {}

    function userLoans() {}

    function getIntersetValue(uint256 date) internal {
        require(
            returnDate == 30 || returnDate == 60 || returnDate == 90,
            "incorrect return date"
        );
        if (date == 30) {
            return day30IntersetRate;
        } else if (date == 60) {
            return day60IntersetRate;
        } else {
            return day90IntersetRate;
        }
    }

    function calculateCredit() {}
}
