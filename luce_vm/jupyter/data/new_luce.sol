pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}



/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)
            // To delete a key-value pair from the _entries array in O(1), we swap the entry to delete with the last one
            // in the array, and then remove the last entry (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            MapEntry storage lastEntry = map._entries[lastIndex];

            // Move the last entry to the index where the entry to delete is
            map._entries[toDeleteIndex] = lastEntry;
            // Update the index for the moved entry
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved entry was stored
            map._entries.pop();

            // Delete the index for the deleted slot
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

   /**
    * @dev Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Note that there are no guarantees on the ordering of entries inside the
    * array, and it may change when more entries are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     */
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     */
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}



/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}



/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}




/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}




/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transfered from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    /**
     * @dev Emitted when a new token is generated.
     */
    event NewToken(uint tokenID, uint licenseType, uint purposeCode);

    // /**
    //  * @dev Returns the number of tokens in ``owner``'s account.
    //  */
    // function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from`, `to` cannot be zero.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;



    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from`, `to` cannot be zero.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}




/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}








/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}




/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    // /**
    //  * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    //  */
    // function tokenURI(uint256 tokenId) external view returns (string memory);
}




/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
abstract contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public virtual returns (bytes4);
}




/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    // using Strings for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    // mapping(uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURI;

    // Token user -> can only be changed by the token Owner
    // Adapted transfer function to change this variable instead of transferring ownership
    EnumerableMap.UintToAddressMap private _tokenUsers;
    
    struct LUCEToken {
        // address requester;
        uint license;
        uint purposeCode; // this may become part of the hash?
        uint accessTime; // this is needed, since the expiryDate for each token will be different
        bytes32 tokenHash;
        // bool burned;
    }
    
    LUCEToken[] internal tokens; // an alternative where this is private could be in combination with a function that returns all tokens and their settings


    /*
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }


    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }


    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner.
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract.
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens.
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }


    /**
     * @dev This functions creates a token that can be manupulated according to the ERC721 standard... sort of, since it has no real use
     * inside the ERC721 standard, but I'm not sure what that use could even be, since I've never seen any application other than as an
     * alternative currency.
     * @param _purposeCode ....
     */
    function _createRequestedToken(uint _license, uint _purposeCode, uint _accessTime) internal {
        uint id;
        bytes32 lastHash;
        if(tokens.length < 1){
            id = 1;
            lastHash = keccak256(abi.encodePacked(uint(1), msg.sender, _license, _purposeCode));
        } else {
            lastHash = tokens[tokens.length.sub(1)].tokenHash;
            id = tokens.length.add(1);
        }
        bytes32 tokenHash = keccak256(abi.encodePacked(id.add(uint(lastHash)), msg.sender, _license, _purposeCode));
        tokens.push(LUCEToken(_license, _purposeCode, now.add(_accessTime), tokenHash));
        
        // introduce checksum composed of unique values to make sure token access can be verified easily
        emit NewToken(id, _license, _purposeCode); // not sure this is needed...
    }



    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner,
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(from, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether the specified token exists.
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(userOf(tokenId) == address(0), "This token is already in use.");
        address owner = ownerOf(tokenId);
        return (spender == owner);
    }

    /**
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);


        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);
        
        _tokenUsers.remove(tokenId); // this removes the User from the mapping that allows them use of the token

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _tokenUsers.set(tokenId, to); // This adds the user to the mapping that allows them to use the token

        emit Transfer(from, to, tokenId);
    }


    /**
     * @dev Gets the user of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function userOf(uint256 tokenId) public view returns (address) {
        return _tokenUsers.get(tokenId, "ERC721: owner query for nonexistent token");
    }


    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ));
        if (!success) {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - when `from` is zero, `tokenId` will be minted for `to`.
     * - when `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}


contract owned {
    constructor() public { owner = msg.sender; }
    address payable owner;

    // This contract only defines a modifier but does not use
    // it: it will be used in derived contracts.
    // The function body is inserted where the special symbol
    // `_;` in the definition of a modifier appears.
    // This means that if the owner calls this function, the
    // function is executed and otherwise, an exception is
    // thrown.
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
}

contract destructible is owned {
    // This contract inherits the `onlyOwner` modifier from
    // `owned` and applies it to the `destroy` function, which
    // causes that calls to `destroy` only have an effect if
    // they are made by the stored owner.
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}



contract Dataset is destructible, ERC721 {
    
    // Contract testing variables
    uint public scenario;
    
    // About the data provider and dataset
    address public dataProvider;
    uint public license;
    string private link;
    string public dataDescription = "default"; //this needs to become a struct when the consent contract is integrated.
    bool internal unpublished;
    
    // Registry
    address internal registry;
    
    // Cost variables
    uint public currentCost;
    uint internal costMult;
    uint internal costDiv;
    uint public profitMargin;

    // The keyword "public" makes those variables easily readable from outside.
    mapping (address => uint) internal mappedUsers;
    mapping (address => bool) internal requesterCompliance;
    address[] internal addressIndices;


    // Events allow light clients to react to changes efficiently.
    event Sent(address from, address to, uint token); // currently unused.
    event publishedDataset(address publisher, string description, string link, uint license);
    event updateDataset(address to, string uspdateDescr);
    
    
    /**
     * @dev This modifier calculates the gas cost of any function that is called with it and adds the result to the contract's
     * currentCost.
     */
    modifier providerGasCost() {
        uint remainingGasStart = gasleft();

        _;
        
        uint remainingGasEnd = gasleft();
        uint usedGas = remainingGasStart - remainingGasEnd;
        // Add intrinsic gas and transfer gas. Need to account for gas stipend as well.
        usedGas.add(30700);
        // Possibly need to check max gasprice and usedGas here to limit possibility for abuse.
        uint gasCost = usedGas.mul(tx.gasprice).mul(profitMargin).div(100); // in wei
        // Add gas cost to total
        currentCost = currentCost.add(gasCost);
    }
    
    function setScenario(uint _scenario) public onlyOwner {
        scenario = _scenario;
    }
    
    /**
     * @dev This function lets the dataProvider save the address of the general registry contract to make sure requesters are
     * registered and possess the correct license.
     * @param userRegistry is the address of the general registry contract this contract should call on whenever validating
     * data requesters.
     */
    function setRegistryAddress(address userRegistry) public onlyOwner providerGasCost {
        registry = userRegistry;
    }


    /**
     * @dev Initializes the dataset.
     * @param _description sets the description of the dataset.
     * @param _link sets the link to the dataset, which may be shared to Users through tokens.
     * @param _license sets the license which is needed to get access to the dataset.
     */
    function publishData(string memory _description, string memory _link, uint _license) public onlyOwner providerGasCost {
        require(unpublished, "Dataset was already published.");
        
        LUCERegistry c = LUCERegistry(registry);
        bool registered = c.checkProvider(msg.sender);
        require(registered, "Potential data provider is not yet registered.");
        
        dataDescription = _description;
        license = _license;
        link = _link;
        
        emit publishedDataset(msg.sender, _description, _link, license); // Triggering event
        unpublished = false;
    }


    /**
     * @dev Public function to return the link of the dataset, callable only by the dataProvider or authorized data requesters.
     * This function should become more or less obsolete once we implement the checksum for data access.
     */
    function getLink() public view returns(string memory) {
        if (msg.sender==dataProvider){
            return link;
        }
        require (requesterCompliance[msg.sender], "Access denied. Reconfirm compliance first.");
        uint tokenId = mappedUsers[msg.sender];
        require (userOf(tokenId) == msg.sender, "Operation not authorized");
        require (tokens[tokenId.sub(1)].accessTime > now, "Access time has expired.");
        return link;
    }


    function getAllDataRequesters() public view onlyOwner returns(address[] memory) {
        require(addressIndices.length > 0, "There is no data requester yet.");
        return addressIndices;
    }
    


    /**
     * @dev This function allows the dataProvider to update the description of and link to their dataset.
     * @param updateDescr is the new description of the dataset.
     * @param newlink is the new link to the dataset.
     */
    function updateData(string memory updateDescr, string memory newlink) public onlyOwner providerGasCost {
        require(unpublished == false, "Data was not yet published.");
        dataDescription = updateDescr;
        link = newlink;
        
        uint arrayLength = tokens.length;
        if(arrayLength > 0){
            for (uint i = 0; i<arrayLength; i++) {
                if (_exists(i.add(1))) {
                    address to = userOf(i.add(1));
                    if (tokens[i].accessTime >= now) {
                        requesterCompliance[to] = false; // This is false until the requester reconfirms their compliance.
                        emit updateDataset(to, updateDescr); // Triggering event for all dataRequesters.
                    } 
                    if (requesterCompliance[to] == true) {
                        requesterCompliance[to] = false; // This is false until the requester reconfirms their compliance.
                        emit updateDataset(to, updateDescr); // Triggering event for all dataRequesters.
                    }
                }
            }
        }
    }


   /**
    * @dev This is a workaround to set the correct initial cost of deploying the contract. It may also be used to control
    * the contract cost (artificial cost). This function should be called right after the contract is deployed. Possibly, it
    * should be callable only once, but this is not implemented.
    * @param price is the total cost requesters will have to pay whenever requesting access to the data.
    */
    function setPrice(uint price) public onlyOwner providerGasCost {
        currentCost = price;
    }


   /**
    * @dev This function lets the data provider set the fixed profitMargin they want to achieve by sharing this dataset.
    * @param _profitMargin is the percentage profit margin the provider strives for. Standard is 100, i.e. no-profit.
    */
    function setProfitMargin(uint _profitMargin) public onlyOwner providerGasCost {
        profitMargin = _profitMargin;
    }


    /**
     * @dev This function allows the dataProvider to control what percentage of the current contract cost (currentCost)
     * any requester should pay.
     * @param mult is the numerator in the calculation.
     * @param div is the denominator in the calculation.
     */
    function setMultis(uint mult, uint div) public onlyOwner providerGasCost {
        costMult = mult;
        costDiv = div;
    }


    constructor () ERC721("Test", "TST") public{
        dataProvider = msg.sender;
        currentCost = 1e9; // hopefully this is 1 shannon (giga wei)
        costMult = 1;
        costDiv = 3;
        unpublished = true;
        profitMargin = 100; // Cover costs exactly => scenario 2
        scenario = 2; // Initialize contract as scenario 2
    }
}


//import "./generateToken.sol";

contract LuceMain is Dataset {
    
    bool private burnPermission = false;
    
    // This event signals a requester that their token was burned. 
    event tokenBurned(address userOfToken, uint tokenId, address contractAddress, uint remainingAccessTime);

    /**
     * @dev This function allows the dataProvider to change the license required for access to the dataset.
     * @param newlicense sets a new license that should be checked whenever a User requests access to the dataset.
     */
    function setlicense(uint newlicense) public onlyOwner providerGasCost {
        license = newlicense;
        burnPermission = true;
        uint arrayLength = tokens.length;
        // if(arrayLength == 1 && tokens[0].license != newlicense) {
        //     burn(i.add(1)); // Burn requester 1's token.
        // }
        if(arrayLength > 0){
            for (uint i = 0; i<arrayLength; i++) {
                if(tokens[i].license != newlicense) {
                    burn(i.add(1)); // Burn all previously added tokens that now have the wrong license.
                }
            }
        }
        burnPermission = false;
    }



    /**
     * @dev This function returns the license required for access to the dataset.
     */
    function getlicense() public view returns(uint) {
        return license;
    }
    
    function getCompliance(address _requester) public view returns(bool) {
        require (mappedUsers[_requester] > 0 || msg.sender == dataProvider, "Message sender does not have an access token.");
        return requesterCompliance[_requester];
    }
    
    function getTokenId(address _user) public view returns(uint) {
        require (mappedUsers[_user] > 0 || msg.sender == dataProvider, "Message sender does not have an access token.");
        if(msg.sender == dataProvider) {
            return mappedUsers[_user];
        } else {
            uint tokenId = mappedUsers[_user];
            require (userOf(tokenId) == msg.sender, "Message sender is not the user of this token.");
            return tokenId;
        }
    }


    /**
     * @dev This function allows the dataProvider or the user (requester) of a token to delete it, thus relinquishing access to 
     *  getLink, or any other token-related function via this token. The token struct will persist, however there is currently no
     * possibility to access it. This would need to be implemented for the supervisory authority.
     * @param tokenId is the token to be burned. A requester can look up their tokenId by calling mappedUsers with their own address.
     */
    function burn(uint tokenId) public {
        require (userOf(tokenId) == msg.sender || dataProvider == msg.sender || burnPermission, "Operation not authorized");
        address user = userOf(tokenId);
        uint accessTime = tokens[tokenId.sub(1)].accessTime;
        uint remainingAccessTime = 0;
        if (accessTime > now) { // access has expired
            remainingAccessTime = remainingAccessTime = accessTime.sub(now); // access not yet expired
        }
        // tokens[tokenId].burned = true;
        _burn(tokenId);
        emit tokenBurned(user, tokenId, address(this), remainingAccessTime);
        mappedUsers[user] = 0; // indicate the user no longer has a token
        if (msg.sender == user) {
            // If the data requester issues deletion of their token, they also intrinsicly agree to delete their copy of the dataset
            requesterCompliance[user] = true; 
        } else {
            requesterCompliance[user] = false; // Since the user doesn't have access anymore, they inherently comply (soft compliance).
            // Hard compliance must be verified by the supervisory authority, if it is in question.
        }
    }


   
    /**
     * @dev This function first adds a new data Requester to the relevant mapping, then creates a token to access the link
     * to the data, and then transfers User-rights to the data Requester. Before this function is called, it is advisable
     * that the requester calls the expectedCosts function to make sure they submit the correct msg.value in their 
     * transaction. 
     * @param purposeCode represents the purpose the requester wants to use the requested data for. The provider will be
     * able to control this via the consent contract (unfinished)
     * @param accessTime is the amount of time in seconds the data should be available to the data requester. If 0 is passed
     * to this value, the function will set a standard 2 weeks accessTime. This parameter is mainly for testing purposes. 
     */
    function addDataRequester(uint purposeCode, uint accessTime) public payable returns(uint){
        require(unpublished==false, "This contract is not yet associated with a published dataset.");
        LUCERegistry c = LUCERegistry(registry);
        uint userLicense = c.checkUser(msg.sender);

        // Make sure the requester's license matches with the provider's requirements
        require(license == userLicense, "incorrect license type or user not registered");
        // Make sure the requester's purpose matches the 'requirements' (this is where the consent contract will interface)
        require(purposeCode <= 20, "incorrect purpose Code");
        // Make sure the requester doesn't have a token yet.
        require(mappedUsers[msg.sender]==0, "This user already has a token and should use renewToken.");

        addressIndices.push(msg.sender); //adding the data requester to an array so that I can loop the mapping of dataRequesters later!

        // Calculate the amount an individual requester must pay in order to receive access and make sure their transferred value matches.
        if(scenario > 1) {
            uint individualCost = currentCost.mul(costMult).div(costDiv);
            require(msg.value == individualCost, "Payment does not match requirement.");

            // Adjust the true contract cost by subtracting the value this requester transferred.
            if(currentCost < individualCost) { // Values smaller than 0 are not allowed in solidity.
                currentCost = 0;
            } else {
                currentCost = currentCost.sub(individualCost);
            }
        }

        // Token generation
        if(accessTime==0){
            accessTime = 2 weeks;
        }
        _createRequestedToken(license, purposeCode, accessTime); // Creates a token.
        uint tokenId = tokens.length; // ID of the token that was just created. Note that solidity is 0-indexed.
        _safeMint(dataProvider, tokenId); // Mints the token to the dataProvider and gives them complete control over it.
        _safeTransfer(dataProvider, msg.sender, tokenId, ""); // Allows access of the created token to the requester.
        // A requester can look up their token by calling the mappedUsers mapping with their own address.
        mappedUsers[msg.sender] = tokenId; // This proves the requester has received a token and cannot receive another one
        // Compliance initialization for the data requester:
        requesterCompliance[msg.sender] = true;
        return tokenId;
    }


    function getAccessTime(uint tokenId) public view returns (uint) {
        require (userOf(tokenId)==msg.sender || dataProvider==msg.sender, "Only the token user or data provider can view this.");
        return(tokens[tokenId.sub(1)].accessTime);
    }
    
    
    function confirmCompliance() public {
        require (mappedUsers[msg.sender] > 0, "The requester does not own a token. Request a token first.");
        requesterCompliance[msg.sender] = true;
        
    }
    
    // function resetCompliance(uint tokenId) public {
    //     require (tokens.length<tokenId, "Querying for nonexistent token.");
    //     require (tokens[tokenId].burned == true, "The token in question was not burned");
    //     require (tokens[tokenId].requester == msg.sender, "Operation not authorized.");
    //     LUCERegistry c = LUCERegistry(registry);
    //     uint requesterLicense = c.checkUser(msg.sender);
    //     require (tokens[tokenId].license != requesterLicense, "License of requester did not change.");
    //     requesterCompliance[msg.sender] = true;
    // }
 

    /**
     * @dev This function allows a data requester to renew or add to their access time to the dataset. It is advisable to
     * call the expectedCosts function to make sure the correct value is transferred with the transaction.
     * @param newAccessTime is the amount of time to be added to the requester's current access time.
     */
    function renewToken(uint newAccessTime) public payable {
        uint tokenId = mappedUsers[msg.sender]; // This defaults to 0 in case the requester doesn't own a token. TokenId 0 is invalid.
        require (userOf(tokenId) == msg.sender, "Operation not authorized");
        require (requesterCompliance[msg.sender], "Must first comply with new conditions for data access.");
        // Calculates the value the requester must pay to call this function and checks whether the amount transferred matches.
        if(scenario > 1) {
            uint individualCost = currentCost.mul(costMult).div(costDiv);
            require(msg.value == individualCost, "Payment does not match requirement.");

            // Adjust the true contract cost by subtracting the value this requester transferred.
            if(currentCost < individualCost) { // Values smaller than 0 are not allowed in solidity.
                currentCost = 0;
            } else {
                currentCost = currentCost.sub(individualCost);
            }
        }
        //emit Sent(msg.sender, dataProvider, userTokens[msg.sender]++); // This event is not really necessary...
        // Adds the new access time.
        if(tokens[tokenId.sub(1)].accessTime > now){
            tokens[tokenId.sub(1)].accessTime = tokens[tokenId.sub(1)].accessTime.add(newAccessTime);
        } else {
            tokens[tokenId.sub(1)].accessTime = now.add(newAccessTime);
        }
    }


    /**
     * @dev This function returns the amount the next requester in line needs to pay in return for access.
     */
    function expectedCosts() public view returns(uint) {
        if(scenario == 1) {
            return 0;
        }
        //returns the expected costs for the next data Requester
        uint individualCost = currentCost.mul(costMult).div(costDiv);
        return(individualCost);
    }

    /**
     * @dev Returns the contract balance. Only callable by the dataProvider.
     */
    function contractBalance() public view returns(uint256) {
        require (msg.sender == dataProvider, "Only the data provider can extract funds from the contract.");
        return uint256(address(this).balance);
    }

    /**
     * @dev Transfers all funds from the contract to the dataProvider. Only callable by the dataProvider.
     */
    function receiveFunds() public onlyOwner providerGasCost {
        msg.sender.transfer(address(this).balance); //this could just be the balance of the contract
    }
}


contract LUCERegistry {

    // This may be used for administrator control later. Not totally necessary. Can also remain unused.
    address public admin;

    // -------------------------------------- Provider section ---------------------------------------
    
    // Mapping for provider registration
    mapping (address => bool) public providerRegistry;
    
    /**
     * @dev Allows any person to register themselves as data provider.
     * @param _provider is the address of the new data provider to be registered. The function fails if
     * the _provider is already registered.
     */
    function newDataProvider(address _provider) external {
        require(providerRegistry[_provider]==false, "This address is already registered as Provider.");
        providerRegistry[_provider] = true;
    }
    
    /**
     * @dev Allows any person to check whether a certain address belongs to a data provider.
     * @param _provider is the address of data provider in question.
     */
    function checkProvider(address _provider) external view returns(bool) {
        return (providerRegistry[_provider]);
    }

    
    // -----------------------------------------User section -----------------------------------------
    
    event newUserRegistered(address indexed user, uint license);
    
    // Maps the license of a data requester to their address. License 0 is default for all addresses, i.e. not registered.
    mapping (address => uint) public userRegistry;
    
    /**
     * @dev Allows (currently any) person to register themselves with (currently any) license. This function should
     * introduce more stringent requirements etc. to make sure only authorized usage is allowed.
     * @param newUser is the address of the new user to be registered.
     * @param license is the license of the new user to be registered.
     */
    function registerNewUser(address newUser, uint license) external {
        require(userRegistry[newUser] == 0, "User is already registered.");
        userRegistry[newUser] = license;
        emit newUserRegistered(newUser, license);
    }

    /**
     * @dev Returns the license of a user. Not completely necessary, since the mapping is public.
     * @param user is the address of the user whose license is in question.
     */
    function checkUser(address user) external view returns(uint) {
        return (userRegistry[user]);
    }
    
    /**
     * @dev Allows any registered user to change their license. This should be controlled by the supervising authority
     * but such control is not yet implemented and not necessarily a good idea because centralized control defeats the
     * purpose of a decentralized ledger.
     * @param newLicense is the new license to be associated with the address of the msg.sender.
     */
    function updateUserLicense(uint newLicense) external {
        require(userRegistry[msg.sender] != 0, "User is not yet registered.");
        userRegistry[msg.sender] = newLicense;
    }
    
    /**
     * @dev Allows a user to deregister themselves.
     */
    function deregister() external {
        userRegistry[msg.sender] = 0;
        providerRegistry[msg.sender] = false;
    }

    constructor() public {
        admin = msg.sender;
    }
}
