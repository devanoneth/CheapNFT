// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice 1-of-1 NFT.
/// adapted from https://gist.github.com/z0r0z/ea0b752aa9537070b0d61f8a74d5c10c
contract SingleNFT {
    mapping(address => uint256) public balanceOf;

    mapping(uint256 => address) public ownerOf;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    function name() external pure returns (string memory) {
        uint256 offset = _getImmutableArgsOffset();
        bytes32 nameBytes;
        assembly {
            nameBytes := calldataload(offset)
        }
        return string(abi.encodePacked(nameBytes));
    }

    function symbol() external pure returns (string memory) {
        uint256 offset = _getImmutableArgsOffset();
        bytes16 symbolBytes;
        assembly {
            symbolBytes := calldataload(add(offset, 0x20))
        }
        return string(abi.encodePacked(symbolBytes));
    }

    function tokenURI(uint256) external pure returns (string memory) {
        uint256 offset = _getImmutableArgsOffset();
        bytes32 uriBytes1;
        bytes16 uriBytes2;
        assembly {
            uriBytes1 := calldataload(add(offset, 0x30))
            uriBytes2 := calldataload(add(offset, 0x50))
        }
        return string(abi.encodePacked("ipfs://", uriBytes1, uriBytes2));
    }

    /// @return offset The offset of the packed immutable args in calldata
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            offset := sub(
                calldatasize(),
                add(shr(240, calldataload(sub(calldatasize(), 2))), 2)
            )
        }
    }

    /// @notice Random function name to save gas. Thanks to @_apedev for early access.
    /// https://twitter.com/_apedev/status/1483827473930407936
    function mint_d22vi9okr4w(address to) external {
        require(ownerOf[0] == address(0), "Already minted");
        balanceOf[to] = 1;

        ownerOf[0] = to;

        emit Transfer(address(0), to, 0);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 ||
            interfaceId == 0x80ac58cd ||
            interfaceId == 0x5b5e139f;
    }
}
