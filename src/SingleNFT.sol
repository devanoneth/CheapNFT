// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice 1-of-1 NFT.
/// adapted from https://gist.github.com/z0r0z/ea0b752aa9537070b0d61f8a74d5c10c
contract SingleNFT {
    address private owner;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    function balanceOf(address) external pure returns (uint256) {
        return 1;
    }

    function ownerOf(uint256) external view returns (address) {
        return owner;
    }

    /// @notice Returns a string from a null terminated bytes array in memory
    /// @dev Works backwards from the end of the byte array so that it only needs one for loop
    function _nullTerminatedString(bytes memory input) public pure returns (string memory) {
        bytes memory output;
        for (uint256 i = input.length; i > 0; i--) {
            // Find the first non null byte
            if (uint8(input[i - 1]) != 0) {
                // Initialize the output byte array
                if (output.length == 0) {
                    output = new bytes(i);
                }

                output[i - 1] = input[i - 1];
            }
        }

        return string(output);
    }

    function name() external pure returns (string memory) {
        uint256 offset = _getImmutableArgsOffset();
        bytes32 nameBytes;
        assembly {
            nameBytes := calldataload(offset)
        }
        return _nullTerminatedString(abi.encodePacked(nameBytes));
    }

    function symbol() external pure returns (string memory) {
        uint256 offset = _getImmutableArgsOffset();
        bytes16 symbolBytes;
        assembly {
            symbolBytes := calldataload(add(offset, 0x20))
        }
        return _nullTerminatedString(abi.encodePacked(symbolBytes));
    }

    function tokenURI(uint256) external pure returns (string memory) {
        uint256 offset = _getImmutableArgsOffset();
        bytes32 uriBytes1;
        bytes16 uriBytes2;
        assembly {
            uriBytes1 := calldataload(add(offset, 0x30))
            uriBytes2 := calldataload(add(offset, 0x50))
        }
        return _nullTerminatedString(abi.encodePacked("ipfs://", uriBytes1, uriBytes2));
    }

    /// @return offset The offset of the packed immutable args in calldata
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            offset := sub(calldatasize(), add(shr(240, calldataload(sub(calldatasize(), 2))), 2))
        }
    }

    /// @notice Random function name to save gas. Thanks to @_apedev for early access.
    /// https://twitter.com/_apedev/status/1483827473930407936
    /// Also payable to save even more gas
    function mint_d22vi9okr4w(address to) external payable {
        require(owner == address(0), "Already minted");
        owner = to;

        emit Transfer(address(0), to, 0);
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x01ffc9a7 || interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f;
    }
}
