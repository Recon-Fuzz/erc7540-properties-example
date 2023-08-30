// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2017, 2018, 2019 dbrock, rain, mrchico
// Copyright (C) 2021-2022 Foundation
pragma solidity ^0.8.18;

import "./../util/Auth.sol";

interface IERC1271 {
    function isValidSignature(bytes32, bytes memory) external view returns (bytes4);
}

// Adapted from https://github.com/makerdao/xdomain-dss/blob/master/src/Dai.sol
contract ERC20 is Auth {
    string public name;
    string public symbol;
    string public constant version = "3";
    uint8 public immutable decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nonces;

    // --- EIP712 niceties ---
    uint256 public immutable deploymentChainId;
    bytes32 private immutable _DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    // --- Events ---
    event File(bytes32 indexed what, string data);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint8 decimals_) {
        decimals = decimals_;
        wards[msg.sender] = 1;
        emit Rely(msg.sender);

        deploymentChainId = block.chainid;
        _DOMAIN_SEPARATOR = _calculateDomainSeparator(block.chainid);
    }

    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                address(this)
            )
        );
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return block.chainid == deploymentChainId ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(block.chainid);
    }

    function file(bytes32 what, string memory data) external auth {
        if (what == "name") name = data;
        else if (what == "symbol") symbol = data;
        else revert("ERC20/file-unrecognized-param");
        emit File(what, data);
    }

    // --- ERC20 Mutations ---
    function transfer(address to, uint256 value) public virtual returns (bool) {
        require(to != address(0) && to != address(this), "ERC20/invalid-address");
        uint256 balance = balanceOf[msg.sender];
        require(balance >= value, "ERC20/insufficient-balance");

        unchecked {
            balanceOf[msg.sender] = balance - value;
            balanceOf[to] += value;
        }

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        require(to != address(0) && to != address(this), "ERC20/invalid-address");
        uint256 balance = balanceOf[from];
        require(balance >= value, "ERC20/insufficient-balance");

        if (from != msg.sender) {
            uint256 allowed = allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "ERC20/insufficient-allowance");

                unchecked {
                    allowance[from][msg.sender] = allowed - value;
                }
            }
        }

        unchecked {
            balanceOf[from] = balance - value;
            balanceOf[to] += value;
        }

        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        uint256 newValue = allowance[msg.sender][spender] + addedValue;
        allowance[msg.sender][spender] = newValue;

        emit Approval(msg.sender, spender, newValue);

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 allowed = allowance[msg.sender][spender];
        require(allowed >= subtractedValue, "ERC20/insufficient-allowance");
        unchecked {
            allowed = allowed - subtractedValue;
        }
        allowance[msg.sender][spender] = allowed;

        emit Approval(msg.sender, spender, allowed);

        return true;
    }

    function approveForOwner(address owner, address spender, uint256 value) external auth returns (bool) {
        allowance[owner][spender] = value;

        emit Approval(owner, spender, value);

        return true;
    }

    function increaseAllowanceForOwner(address owner, address spender, uint256 addedValue)
        external
        auth
        returns (bool)
    {
        uint256 newValue = allowance[owner][spender] + addedValue;
        allowance[owner][spender] = newValue;

        emit Approval(owner, spender, newValue);

        return true;
    }

    function decreaseAllowanceForOwner(address owner, address spender, uint256 subtractedValue)
        external
        auth
        returns (bool)
    {
        uint256 allowed = allowance[owner][spender];
        require(allowed >= subtractedValue, "ERC20/insufficient-allowance");
        unchecked {
            allowed = allowed - subtractedValue;
        }
        allowance[owner][spender] = allowed;

        emit Approval(owner, spender, allowed);

        return true;
    }

    // --- Mint/Burn ---
    function mint(address to, uint256 value) public virtual auth {
        require(to != address(0) && to != address(this), "ERC20/invalid-address");
        unchecked {
            balanceOf[to] = balanceOf[to] + value; // note: we don't need an overflow check here b/c balanceOf[to] <= totalSupply and there is an overflow check below
        }
        totalSupply = totalSupply + value;

        emit Transfer(address(0), to, value);
    }

    function burn(address from, uint256 value) external auth {
        uint256 balance = balanceOf[from];
        require(balance >= value, "ERC20/insufficient-balance");

        if (from != msg.sender) {
            uint256 allowed = allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "ERC20/insufficient-allowance");

                unchecked {
                    allowance[from][msg.sender] = allowed - value;
                }
            }
        }

        unchecked {
            balanceOf[from] = balance - value; // note: we don't need overflow checks b/c require(balance >= value) and balance <= totalSupply
            totalSupply = totalSupply - value;
        }

        emit Transfer(from, address(0), value);
    }

    // --- Approve by signature ---
    function _isValidSignature(address signer, bytes32 digest, bytes memory signature) internal view returns (bool) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            if (signer == ecrecover(digest, v, r, s)) {
                return true;
            }
        }

        (bool success, bytes memory result) =
            signer.staticcall(abi.encodeWithSelector(IERC1271.isValidSignature.selector, digest, signature));
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector);
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature) public {
        require(block.timestamp <= deadline, "ERC20/permit-expired");
        require(owner != address(0), "ERC20/invalid-owner");

        uint256 nonce;
        unchecked {
            nonce = nonces[owner]++;
        }

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                block.chainid == deploymentChainId ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(block.chainid),
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline))
            )
        );

        require(_isValidSignature(owner, digest, signature), "ERC20/invalid-permit");

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
    {
        permit(owner, spender, value, deadline, abi.encodePacked(r, s, v));
    }
}