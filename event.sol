// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract eventContract {
    struct Event {
        address organiser;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint nextID;

    function createEvent(
        string memory name,
        uint date,
        uint price,
        uint ticketCount
    ) external {
        require(
            date > block.timestamp,
            "You can organise for future date only"
        );
        require(ticketCount > 0, "No of ticket must be greater than zero");

        events[nextID] = Event(
            msg.sender,
            name,
            date,
            price,
            ticketCount,
            ticketCount
        );
        nextID++;
    }

    function buyTicket(uint id, uint quantity) external payable {
        require(events[id].date != 0, "This event does not exist");
        require(block.timestamp < events[id].date);

        Event storage _event = events[id];
        require(msg.value == (_event.price * quantity), "Ether is not enough");
        require(_event.ticketRemain >= quantity, "Not enough tickets");

        _event.ticketCount -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(uint eventID, uint quantity, address to) external {
        require(events[eventID].date != 0, "This event does not exist");
        require(block.timestamp < events[eventID].date);
        require(
            tickets[msg.sender][eventID] >= quantity,
            "You do not have enough tickets"
        );
        tickets[msg.sender][eventID] -= quantity;
        tickets[to][eventID] += quantity;
    }
}
