// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Escrow {
    string public itemSale;
    uint256 public price;
    address payable public seller;
    address payable public buyer;

    // 1.
    address[] previousBuyers;

    // 2.
    enum State { Sale, Locked, Release, Closed, Complete }

    State public state;

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyBuyer() {
        require(
            msg.sender == buyer,
            "Only buyer can call this."
        );
        _;
    }

    modifier onlySeller() {
        require(
            msg.sender == seller,
            "Only seller can call this."
        );
        _;
    }

    // 3.
    modifier notSeller() {
        require(
            msg.sender != seller,
            "Seller shouldn't call this."
        );
        _;
    }

    modifier inState(State _state) {
        require(
            state == _state,
            "Invalid state."
        );
        _;
    }

    // 4.
    event Closed(
        uint256 when
    );

    event ConfirmPurchase(
        uint256 when,
        address by
    );
    event ConfirmReceived(
        uint256 when,
        address by
    );

    event SellerRefundBuyer(
        uint256 when
    );
    event SellerRefunded(
        uint256 when
    );

    event Started(
        uint256 when
    );
    event End(
        uint256 when
    );

    constructor() {
        seller = payable(msg.sender);
        price = 0;
        state = State.Closed;
    }


    // 5. 
    function close()
        public
        onlySeller
        inState(State.Sale)
    {
        state = State.Closed;
        seller.transfer(address(this).balance);

        emit Closed(
            block.timestamp
        );
    }

    function confirmPurchase()
        public
        notSeller
        inState(State.Sale)
        condition(msg.value == price)
        payable
    {
        buyer = payable(msg.sender);
        state = State.Locked;

        emit ConfirmPurchase(
            block.timestamp,
            buyer
        );
    }

    function confirmReceived()
        public
        onlyBuyer
        inState(State.Locked)
    {
        state = State.Release;

        // buyer.transfer(price); // Buyer receive 1 x value here
        emit ConfirmReceived(
            block.timestamp,
            buyer
        );
    }

    // 6.
    function refundBuyer()
        public
        onlySeller
        inState(State.Locked)
    {
        // Give the option to the seller to refund buyer before sending a product(car) here.
        state = State.Sale;
        buyer.transfer(price);
        buyer = payable(0);

        emit SellerRefundBuyer(
            block.timestamp
        );
    }

    function refundSeller()
        public
        onlySeller
        inState(State.Release)
    {
        state = State.Complete;

        seller.transfer(2 * price); 
        // 1.
        previousBuyers.push(buyer);

        emit SellerRefunded(
            block.timestamp
        );
    }

    // 7.
    function startContract(string memory _itemSale, uint256 _price) 
        public
        onlySeller
        // inState(State.Complete)
        payable
    {
        require((state == State.Closed || state == State.Complete),'Only closed or completed contract is able to start a new one');

        itemSale = _itemSale;

        price = _price;
        require((price) == msg.value, "Value has to be equal to what started the contract.");

        state = State.Sale;

        // Reset buyer to allow the same buyer again.
        buyer = payable(0);
        // This doesn't work.
        // buyer = address(0);

        emit Started(
            block.timestamp
        );
    }

    // 1.
    function listPreviousBuyers()public view returns(address [] memory){
        return previousBuyers;
    }

    // totalPreviousBuyers
    function totalSales() public view returns(uint count) {
        return previousBuyers.length;
    }

    // function end() 
    //     public
    //     onlySeller
    // {
    //      if (state == State.Closed || state == State.Complete) {
    //         //  Should put End event before selfdestruct to update the frontend.
    //         // 8.
    //         emit End(
    //             block.timestamp
    //         );

    //         // state = State.End;
    //         selfdestruct(seller);   

    //         // This doesn't work.
    //         // emit End(
    //         //     block.timestamp
    //         // );         
    //     }
    // }
}