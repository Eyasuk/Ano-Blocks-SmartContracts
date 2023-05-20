// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// contract LibNote {
//     event LogNote(
//         bytes4 indexed sig,
//         address indexed usr,
//         bytes32 indexed arg1,
//         bytes32 indexed arg2,
//         bytes data
//     ) anonymous;

//     modifier note() {
//         _;
//         assembly {
//             // log an 'anonymous' event with a constant 6 words of calldata
//             // and four indexed topics: selector, caller, arg1 and arg2
//             let mark := msize() // end of memory ensures zero
//             mstore(0x40, add(mark, 288)) // update free memory pointer
//             mstore(mark, 0x20) // bytes type data offset
//             mstore(add(mark, 0x20), 224) // bytes size (padded)
//             calldatacopy(add(mark, 0x40), 0, 224) // bytes payload
//             log4(
//                 mark,
//                 288, // calldata
//                 shl(224, shr(224, calldataload(0))), // msg.sig
//                 caller(), // msg.sender
//                 calldataload(4), // arg1
//                 calldataload(36) // arg2
//             )
//         }
//     }
// }

contract Etbc {
    mapping(address => uint256) public wards;

    // check and understand how this work part of auth

    function rely(address guy) external auth {
        wards[guy] = 1;
    }

    function deny(address guy) external auth {
        wards[guy] = 0;
    }

    modifier auth() {
        require(wards[msg.sender] == 1, "Etbc/not-authorized");
        _;
    }

    //Erc20 part
    string public constant name = "Etbc Stablecoin";
    string public constant symbol = "ETBC";
    string public constant version = "1";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 10000000000;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nonces;

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);

    // --- Math --- because of overflow
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    // --- EIP712 niceties ---
    bytes32 public DOMAIN_SEPARATOR;
    // bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)");
    bytes32 public constant PERMIT_TYPEHASH =
        0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;

    constructor(uint256 chainId_) {
        wards[msg.sender] = 1;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId_,
                address(this)
            )
        );
    }

    // --- Token ---
    function transfer(address dst, uint256 wad) external returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad, "Dai/insufficient-balance");
        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint256).max
        ) {
            require(
                allowance[src][msg.sender] >= wad,
                "Dai/insufficient-allowance"
            );
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);
        emit Transfer(src, dst, wad);
        return true;
    }

    function mint(address usr, uint256 wad) external auth {
        balanceOf[usr] = add(balanceOf[usr], wad);
        totalSupply = add(totalSupply, wad);
        emit Transfer(address(0), usr, wad);
    }

    function burn(address usr, uint256 wad) external {
        require(balanceOf[usr] >= wad, "Etbc/insufficient-balance");
        if (
            usr != msg.sender && allowance[usr][msg.sender] != type(uint256).max
        ) {
            require(
                allowance[usr][msg.sender] >= wad,
                "Etbc/insufficient-allowance"
            );
            allowance[usr][msg.sender] = sub(allowance[usr][msg.sender], wad);
        }
        balanceOf[usr] = sub(balanceOf[usr], wad);
        totalSupply = sub(totalSupply, wad);
        emit Transfer(usr, address(0), wad);
    }

    function approve(address usr, uint256 wad) external returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }

    // --- Alias ---
    function push(address usr, uint256 wad) external {
        transferFrom(msg.sender, usr, wad);
    }

    function pull(address usr, uint256 wad) external {
        transferFrom(usr, msg.sender, wad);
    }

    function move(
        address src,
        address dst,
        uint256 wad
    ) external {
        transferFrom(src, dst, wad);
    }

    // --- Approve by signature ---

    function permit(
        address owner,
        address spender,
        uint256 nonce,
        uint256 deadline,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(PERMIT_TYPEHASH, owner, spender, nonce, deadline)
                )
            )
        );
        require(owner != address(0), "Etbc/invalid-address-0");
        require(owner == ecrecover(digest, v, r, s), "Etbc/invalid-permit");
        require(
            deadline == 0 || block.timestamp <= deadline,
            "Etbc/permit-expired"
        );
        require(nonce == nonces[owner]++, "Etbc/invalid-nonce");
        uint256 wad = allowed ? type(uint256).max : 0;
        allowance[owner][spender] = wad;
        emit Approval(owner, spender, wad);
    }
}
