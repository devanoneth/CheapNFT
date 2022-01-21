// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

import {DSTest} from "ds-test/test.sol";

import {VM} from "./utils/VM.sol";
import {console} from "./utils/console.sol";
import {SingleNFT} from "../SingleNFT.sol";
import {SingleNFTFactory} from "../SingleNFTFactory.sol";

contract ExampleCloneFactoryTest is DSTest {
    VM internal constant vm = VM(HEVM_ADDRESS);

    SingleNFTFactory internal factory;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    function setUp() public {
        SingleNFT implementation = new SingleNFT();
        factory = new SingleNFTFactory(implementation);
    }

    /// -----------------------------------------------------------------------
    /// Gas benchmarking
    /// -----------------------------------------------------------------------

    function testGasOfCloning(
        bytes32 name,
        bytes16 symbol,
        bytes32 uri1,
        bytes16 uri2
    ) public {
        factory.createERC721(name, symbol, uri1, uri2);
    }

    /// -----------------------------------------------------------------------
    /// Correctness tests
    /// -----------------------------------------------------------------------

    function testCreation() public {
        string memory _name = "A cool name";
        string memory _symbol = "SYMBOL";
        string
            memory _URI = "QmWEgPgwqX9jruTaYF9nLeJjcUoiD5DVLLibWekgQgknEX";

        bytes32 name;
        bytes16 symbol;
        bytes32 uri1;
        bytes16 uri2;
        assembly {
            name := mload(add(_name, 0x20))
            symbol := mload(add(_symbol, 0x20))
            uri1 := mload(add(_URI, 0x20))
            uri2 := mload(add(_URI, 0x40))
        }

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), address(this), 0);

        SingleNFT clone = factory.createERC721(name, symbol, uri1, uri2);

        console.log(clone.name());
        console.log(clone.symbol());
        console.log(clone.tokenURI(0));

        assertEq(clone.name(), string(abi.encodePacked(name)));
        assertEq(clone.symbol(), string(abi.encodePacked(symbol)));
        assertEq(clone.tokenURI(0), string(abi.encodePacked("ipfs://", uri1, uri2)));
    }

    function testCannotCallMintAgain() public {
        string memory _name = "A cool name";
        string memory _symbol = "SYMBOL";
        string
            memory _URI = "QmWEgPgwqX9jruTaYF9nLeJjcUoiD5DVLLibWekgQgknEX";

        bytes32 name;
        bytes16 symbol;
        bytes32 uri1;
        bytes16 uri2;
        assembly {
            name := mload(add(_name, 0x20))
            symbol := mload(add(_symbol, 0x10))
            uri1 := mload(add(_URI, 0x20))
            uri2 := mload(add(_URI, 0x30))
        }

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), address(this), 0);

        SingleNFT clone = factory.createERC721(name, symbol, uri1, uri2);

        vm.expectRevert("Already minted");
        clone.mint(address(0));
    }
}
