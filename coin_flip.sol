// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Coin FLip
 * @dev Aditi Roy
 */

contract CoinFlip {
    int size = 10;

    struct bet {
        bool guess;
        int amount;
        bool flag;
    }

    mapping(int => int) balance; // For user's balance
    mapping(int => bet) bets;

    // initialize all the users with free 100 points
    function initializeUsersWithPoints() public {
        for(int i=0; i<size; i++) {
            balance[i] = 100;
        }
    }

    // displays balance of a particular user
    function displaybalance(int userId) public view returns(int) {
        if(userId >= 0 && userId < size) {
            return balance[userId];
        } else {
            return -1;
        }
    }

    // // returns the random number in range [0, mod-1]
    // function randModules(uint mod) public view returns(uint){
    //     return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % mod;
    // }

    

    // places bet depending on the given conditions
    function placeBet(int userId, int amount, bool guess) public returns(bool) {
        if(userId < 0 || userId >= size) { // invalid ID
            return false;
        }
       
        if(bets[userId].flag) { // already placed bet in the game
            return false;
        }

        if(balance[userId] == 0) { // user has no money
            return false;
        }

        if(balance[userId] < amount) { // low balance
            return false;
        }

        // deduct the user's balance
        balance[userId] -= amount;

        // place their bet
        bets[userId].guess = guess;
        bets[userId].amount = amount;
        bets[userId].flag = true;

        return true;       
    }

    function vrf() public view returns (bytes32 result) {
        uint[1] memory bn;
        bn[0] = block.number;
        assembly {
            let memPtr := mload(0x40)
            if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
                invalid()
            }
            result := mload(memPtr)
        }
        return result;
    }

    // conclude all bets with win/loss
    function rewardBets() public {
        bool coinResult = true;
        // uint randNumber = randModules(1000000007);
        uint randNumber = uint(vrf()) & 0xfff;
        // true / false -> heads / tails respectively
        if(randNumber%2 == 0)
            coinResult = true;
        else 
            coinResult = false;
            
        // check all the results for the users
        for(int i=0; i<size; i++) {
            if(bets[i].flag && bets[i].guess == coinResult) {
                balance[i] += (2 * bets[i].amount);
                bets[i].flag = false;
            }
        }
    }
}