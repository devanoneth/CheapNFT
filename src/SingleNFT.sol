// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice 1-of-1 NFT.
/// adapted from https://gist.github.com/z0r0z/ea0b752aa9537070b0d61f8a74d5c10c
contract SingleNFT {
    mapping(address => uint256) public balanceOf;

    mapping(uint256 => address) public ownerOf;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    bool setup = false;
  
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
        bytes32 symbolBytes;
        assembly {
            symbolBytes := calldataload(add(offset, 0x20))
        }
        return string(abi.encodePacked(symbolBytes));
    }

    function tokenURI(uint256) external pure returns (string memory) {
        uint256 offset = _getImmutableArgsOffset();
        bytes32 uriBytes1;
        bytes32 uriBytes2;
        bytes32 uriBytes3;
        assembly {
            uriBytes1 := calldataload(add(offset, 0x40))
            uriBytes2 := calldataload(add(offset, 0x60))
            uriBytes3 := calldataload(add(offset, 0x80))
        }
        return string(abi.encodePacked(uriBytes1, uriBytes2, uriBytes3));
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

    function mint(address to) external {
        require(!setup);
        balanceOf[to] = 1;

        ownerOf[0] = to;

        emit Transfer(address(0), to, 0);
        setup = true;
    }
}