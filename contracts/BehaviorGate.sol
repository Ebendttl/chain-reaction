// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BehaviorGate
 * @notice Gates Reachy Mini behaviors behind micro-payments on 0G Chain.
 *         Free behaviors are always accessible. Premium behaviors require
 *         a one-time unlock payment per wallet address.
 *
 * Deploy to 0G Chain testnet (EVM-compatible, chainId: 16600).
 * RPC: https://evmrpc-testnet.0g.ai
 *
 * After deployment, call setPrice() for each premium behavior key.
 * The frontend reads isUnlocked() to gate actions client-side,
 * and calls unlock() to process payments on-chain.
 */
contract BehaviorGate {
    address public owner;

    // behavior key => price in wei (0 = free)
    mapping(string => uint256) public behaviorPrice;

    // user address => behavior key => unlocked
    mapping(address => mapping(string => bool)) public unlocked;

    // All registered behavior keys (for enumeration)
    string[] private _behaviorKeys;
    mapping(string => bool) private _knownKey;

    // ── Events ──────────────────────────────────────────────────────
    event BehaviorUnlocked(
        address indexed user,
        string indexed behaviorKey,
        uint256 pricePaid,
        uint256 timestamp
    );
    event PriceSet(string behaviorKey, uint256 price);
    event Withdrawn(address to, uint256 amount);

    // ── Modifiers ───────────────────────────────────────────────────
    modifier onlyOwner() {
        require(msg.sender == owner, "BehaviorGate: not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // ── Admin ────────────────────────────────────────────────────────

    /**
     * @notice Set the unlock price for a behavior key.
     *         Set to 0 to make a behavior free.
     * @param behaviorKey  e.g. "dance", "fortune", "backflip"
     * @param price        Price in wei. Use 0 for free.
     */
    function setPrice(string calldata behaviorKey, uint256 price) external onlyOwner {
        behaviorPrice[behaviorKey] = price;
        if (!_knownKey[behaviorKey]) {
            _knownKey[behaviorKey] = true;
            _behaviorKeys.push(behaviorKey);
        }
        emit PriceSet(behaviorKey, price);
    }

    /**
     * @notice Batch-set prices for multiple behaviors at once.
     */
    function setPriceBatch(
        string[] calldata keys,
        uint256[] calldata prices
    ) external onlyOwner {
        require(keys.length == prices.length, "BehaviorGate: length mismatch");
        for (uint256 i = 0; i < keys.length; i++) {
            behaviorPrice[keys[i]] = prices[i];
            if (!_knownKey[keys[i]]) {
                _knownKey[keys[i]] = true;
                _behaviorKeys.push(keys[i]);
            }
            emit PriceSet(keys[i], prices[i]);
        }
    }

    /**
     * @notice Withdraw accumulated ETH/0G to owner.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "BehaviorGate: nothing to withdraw");
        (bool ok, ) = owner.call{value: balance}("");
        require(ok, "BehaviorGate: transfer failed");
        emit Withdrawn(owner, balance);
    }

    // ── User-facing ──────────────────────────────────────────────────

    /**
     * @notice Pay to unlock a premium behavior for the caller's address.
     *         If the behavior is free (price = 0), no payment needed — just call isUnlocked check.
     * @param behaviorKey  The behavior to unlock.
     */
    function unlock(string calldata behaviorKey) external payable {
        uint256 price = behaviorPrice[behaviorKey];
        require(msg.value >= price, "BehaviorGate: insufficient payment");
        unlocked[msg.sender][behaviorKey] = true;

        // Refund overpayment
        if (msg.value > price) {
            (bool ok, ) = msg.sender.call{value: msg.value - price}("");
            require(ok, "BehaviorGate: refund failed");
        }

        emit BehaviorUnlocked(msg.sender, behaviorKey, price, block.timestamp);
    }

    // ── Views ─────────────────────────────────────────────────────────

    /**
     * @notice Check if a user has unlocked a behavior.
     *         Free behaviors (price = 0) always return true.
     */
    function isUnlocked(address user, string calldata behaviorKey)
        external
        view
        returns (bool)
    {
        if (behaviorPrice[behaviorKey] == 0) return true;
        return unlocked[user][behaviorKey];
    }

    /**
     * @notice Get all registered behavior keys and their prices.
     */
    function getAllBehaviors()
        external
        view
        returns (string[] memory keys, uint256[] memory prices)
    {
        keys = _behaviorKeys;
        prices = new uint256[](_behaviorKeys.length);
        for (uint256 i = 0; i < _behaviorKeys.length; i++) {
            prices[i] = behaviorPrice[_behaviorKeys[i]];
        }
    }

    /**
     * @notice Check multiple behaviors for a user in one call (gas-efficient for UI).
     */
    function checkBatch(address user, string[] calldata keys)
        external
        view
        returns (bool[] memory results)
    {
        results = new bool[](keys.length);
        for (uint256 i = 0; i < keys.length; i++) {
            results[i] = behaviorPrice[keys[i]] == 0 || unlocked[user][keys[i]];
        }
    }
}
