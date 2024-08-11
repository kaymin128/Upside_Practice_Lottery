// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Lottery {
    struct ticket {
        address buyer;
        uint16 number;
    }
    uint public vault_balance;
    uint public end_time;
    uint public reward;
    ticket[] public tickets;
    uint16 public winning_number;
    bool public drawed=false;
    constructor() {
        end_time = block.timestamp + 24 hours;
    }
    function buy(uint16 _number) external payable {
        // 로또 티켓 구매, 등록
        require(block.timestamp < end_time, "Too late error!");
        require(msg.value == 0.1 ether, "price is wrong");
        for (uint i = 0; i < tickets.length; i++) {
            require(!(tickets[i].buyer == msg.sender && tickets[i].number == _number));
        }
        tickets.push(ticket({buyer: msg.sender, number: _number}));
        vault_balance += msg.value;
    }
    function draw() external {// 무작위로 당첨 번호 추첨. 추첨 번호 저장
        require(block.timestamp>=end_time, "not yet finished error!");
        require(drawed==false, "already done it error!");
        winning_number=uint16(uint256(keccak256(abi.encodePacked(block.timestamp)))%10000);
        drawed=true;
        uint winner_count=0;
        for (uint i=0; i<tickets.length;i++){
            if (tickets[i].number==winning_number){
                winner_count++;
            }
        }
        if (winner_count!=0){
            reward=vault_balance/winner_count;
        }
        else{
            reward=0;
        }
    }//timestamp>endtime, 1 time 실행
    function claim() external {// 당첨된 사용자가 상금을 받는 함수
        require(block.timestamp>=end_time, "not yet finished error!");
        uint is_me=0;
        for (uint i=0;i<tickets.length;i++){
            if (tickets[i].buyer==msg.sender && tickets[i].number==winning_number){
                is_me=1;
            }
        }
        if (is_me==1){
            payable(msg.sender).call{value: reward}("");
        }
        else{
            drawed=false;
            end_time=block.timestamp+24 hours;
        }
        
    }//timestamp>endtime, winning_number==number 인 buyer에게. 단, buyer가 두명이면 엔빵
    function winningNumber() external returns (uint16) {// 현재 로또의 당첨 번호를 반환
        return winning_number;
    }
}

