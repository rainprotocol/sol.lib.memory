// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibMemCpy.sol";
import "../src/LibBytes.sol";
import "../src/LibPointer.sol";

contract LibMemCpyBytesTest is Test {
    using LibPointer for Pointer;
    using LibBytes for bytes;

    function testCopyFuzz(bytes memory source, uint256 suffix) public {
        bytes memory target = new bytes(source.length);
        uint256 end;
        assembly {
            end := add(add(target, 0x20), mload(target))
            mstore(0x40, add(end, 0x20))
            mstore(end, suffix)
        }
        LibMemCpy.unsafeCopyBytesTo(source.dataPointer(), target.dataPointer(), source.length);
        assertEq(source, target);
        uint256 suffixAfter;
        assembly {
            suffixAfter := mload(end)
        }
        assertEq(suffix, suffixAfter);
    }

    function testCopyMultiWordFuzz(bytes memory source, uint256 suffix) public {
        vm.assume(source.length > 0x20);
        testCopyFuzz(source, suffix);
    }

    function testCopyMaxSuffixFuzz(bytes memory source) public {
        testCopyFuzz(source, type(uint256).max);
    }

    function testCopySimple() public {
        testCopyFuzz(hex"010203", type(uint256).max);
    }

    // Uses somewhat circular logic to test that existing data in target cannot
    // corrupt copying from source somehow.
    function testCopyDirtyTargetFuzz(bytes memory source, bytes memory target) public {
        vm.assume(target.length >= source.length);
        bytes memory remainder = new bytes(target.length - source.length);
        LibMemCpy.unsafeCopyBytesTo(
            target.dataPointer().unsafeAddBytes(source.length), remainder.dataPointer(), remainder.length
        );
        bytes memory remainderCopy = new bytes(remainder.length);
        LibMemCpy.unsafeCopyBytesTo(remainder.dataPointer(), remainderCopy.dataPointer(), remainder.length);

        LibMemCpy.unsafeCopyBytesTo(source.dataPointer(), target.dataPointer(), source.length);
        target.truncate(source.length);
        assertEq(source, target);
        assertEq(remainder, remainderCopy);
    }

    function testCopyGas0() public {
        bytes memory a = hex"";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas1() public {
        bytes memory a = hex"01";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas2() public {
        bytes memory a = hex"0102";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas3() public {
        bytes memory a = hex"010203";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas4() public {
        bytes memory a = hex"01020304";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas5() public {
        bytes memory a = hex"0102030405";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas6() public {
        bytes memory a = hex"010203040506";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas7() public {
        bytes memory a = hex"01020304050607";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas8() public {
        bytes memory a = hex"0102030405060708";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas9() public {
        bytes memory a = hex"010203040506070809";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas10() public {
        bytes memory a = hex"01020304050607080910";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas11() public {
        bytes memory a = hex"0102030405060708091011";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas12() public {
        bytes memory a = hex"010203040506070809101112";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas13() public {
        bytes memory a = hex"01020304050607080910111213";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas14() public {
        bytes memory a = hex"0102030405060708091011121314";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas15() public {
        bytes memory a = hex"010203040506070809101112131415";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas16() public {
        bytes memory a = hex"01020304050607080910111213141516";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas17() public {
        bytes memory a = hex"0102030405060708091011121314151617";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas18() public {
        bytes memory a = hex"010203040506070809101112131415161718";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas19() public {
        bytes memory a = hex"01020304050607080910111213141516171819";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas20() public {
        bytes memory a = hex"0102030405060708091011121314151617181920";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas21() public {
        bytes memory a = hex"010203040506070809101112131415161718192021";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas22() public {
        bytes memory a = hex"01020304050607080910111213141516171819202122";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas23() public {
        bytes memory a = hex"0102030405060708091011121314151617181920212223";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas24() public {
        bytes memory a = hex"010203040506070809101112131415161718192021222324";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas25() public {
        bytes memory a = hex"01020304050607080910111213141516171819202122232425";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas26() public {
        bytes memory a = hex"0102030405060708091011121314151617181920212223242526";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas27() public {
        bytes memory a = hex"010203040506070809101112131415161718192021222324252627";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas28() public {
        bytes memory a = hex"01020304050607080910111213141516171819202122232425262728";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas29() public {
        bytes memory a = hex"0102030405060708091011121314151617181920212223242526272829";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas30() public {
        bytes memory a = hex"010203040506070809101112131415161718192021222324252627282930";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas31() public {
        bytes memory a = hex"01020304050607080910111213141516171819202122232425262728293031";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas32() public {
        bytes memory a = hex"0102030405060708091011121314151617181920212223242526272829303132";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas33() public {
        bytes memory a = hex"010203040506070809101112131415161718192021222324252627282930313233";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas34() public {
        bytes memory a = hex"01020304050607080910111213141516171819202122232425262728293031323334";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas35() public {
        bytes memory a = hex"0102030405060708091011121314151617181920212223242526272829303132333435";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas36() public {
        bytes memory a = hex"010203040506070809101112131415161718192021222324252627282930313233343536";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas37() public {
        bytes memory a = hex"01020304050607080910111213141516171819202122232425262728293031323334353637";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas38() public {
        bytes memory a = hex"0102030405060708091011121314151617181920212223242526272829303132333435363738";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas39() public {
        bytes memory a = hex"010203040506070809101112131415161718192021222324252627282930313233343536373839";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas40() public {
        bytes memory a = hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas41() public {
        bytes memory a = hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas42() public {
        bytes memory a = hex"010203040506070809101112131415161718192021222324252627282930313233343536373839404142";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas43() public {
        bytes memory a = hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas44() public {
        bytes memory a = hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas45() public {
        bytes memory a = hex"010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas46() public {
        bytes memory a =
            hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas47() public {
        bytes memory a =
            hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas48() public {
        bytes memory a =
            hex"010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas49() public {
        bytes memory a =
            hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas50() public {
        bytes memory a =
            hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas51() public {
        bytes memory a =
            hex"010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas52() public {
        bytes memory a =
            hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas53() public {
        bytes memory a =
            hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950515253";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas54() public {
        bytes memory a =
            hex"010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas55() public {
        bytes memory a =
            hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas56() public {
        bytes memory a =
            hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950515253545556";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas57() public {
        bytes memory a =
            hex"010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas58() public {
        bytes memory a =
            hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas59() public {
        bytes memory a =
            hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950515253545556575859";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas60() public {
        bytes memory a =
            hex"010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas61() public {
        bytes memory a =
            hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas62() public {
        bytes memory a =
            hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950515253545556575859606162";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas63() public {
        bytes memory a =
            hex"010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas64() public {
        bytes memory a =
            hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas128() public {
        bytes memory a =
            hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950515253545556575859606162636401020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }

    function testCopyGas256() public {
        bytes memory a =
            hex"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263640102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950515253545556575859606162636401020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364";
        LibMemCpy.unsafeCopyBytesTo(a.dataPointer(), LibPointer.allocatedMemoryPointer(), a.length);
    }
}
