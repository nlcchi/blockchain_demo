// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LetterOfCredit {

    modifier onlyParties {
        require(msg.sender == buyer || msg.sender == seller || msg.sender == shippingManager, "Invalid access");
        _;
    }

    modifier canInitializeBargain(uint256 _sum, uint256 _bargainDeadline) {
        require(msg.sender == buyer, "Invalid access");
        require(
            bargainInitializedBy[buyer].bargainState == States.ZS ||
            bargainInitializedBy[buyer].bargainState == States.FINISHED,
            "You can't initialize a new bargain"
        );
        require(_sum > 0, "Bargain sum can't be less than 0");
        require(_sum == msg.value, "Bargain sum should equal to the amount of ether sent");
        require(
            _bargainDeadline > block.timestamp && _bargainDeadline < block.timestamp + 3600 * 24 * 30 * 12 * 2,
            "Invalid bargain period"
        );
        _;
    }

    enum States {ZS, INIT, VALIDATED, SENT, ACCEPTED, DECLINED, FINISHED}

    address payable public buyer;
    address payable public seller;
    address public shippingManager;

    struct Bargain {
        uint256 bargainSum;
        uint256 bargainDeadline;
        string description;
        States bargainState;
    }
    mapping(address => Bargain) public bargainInitializedBy;

    event StateChangedToBy(States to, address by);
    event BargainCancelledBy(address by);

    /**
     * @notice sets buyers and sellers addresses
     */
    constructor(address payable _buyer, address payable _seller, address _shippingManager) {
        // no checks for 0 address
        buyer = _buyer;
        seller = _seller;
        shippingManager = _shippingManager;
    }

    /**
     * @notice creates a new bargain
     * @dev state for the bargain should be ZS (aka Zero state) or FINISHED
     * The creator role is only for buyer. Maximum bargain period is 2 years.
     */
    function createBargain(uint256 _sum, uint256 _bargainDeadline, string calldata _description)
        external
        payable
        canInitializeBargain(_sum, _bargainDeadline)
        returns (bool)
    {
        Bargain memory newBargain = Bargain({
            bargainSum: _sum,
            bargainDeadline: _bargainDeadline,
            description: _description,
            bargainState: States.INIT
        });
        
        bargainInitializedBy[msg.sender] = newBargain;

        return true;
    }

    /**
     * @notice this method should be used in order to bring contract to a right state to use other methods
     * @dev main logic is in ```changeStateTo```.
     */
    function pushStateForwardTo(States _state) external onlyParties {
        changeStateTo(_state);

        emit StateChangedToBy(_state, msg.sender);
    }

    /**
     * @notice bargain cancellation could be called only by buyer
     * @dev changes state to ZS with no charge from buyer.
     */
    function cancelBargainBuyer() external {
        require(msg.sender == buyer, "Invalid access");

        changeStateTo(States.ZS);
        (, uint256 buyersRefund) = calculatePaymentsInState(States.INIT);
        
        payable(msg.sender).transfer(buyersRefund);

        emit BargainCancelledBy(msg.sender);
    }

    /**
     * @notice bargain cancellation could be called only by seller
     * @dev changes state to ZS and charges ether from buyer to seller.
     */
    function cancelBargainSeller() external {
        require(msg.sender == seller, "Invalid access");
        
        changeStateTo(States.ZS);
        (uint256 compensationToSeller, uint256 returnedToBuyer) = calculatePaymentsInState(States.SENT);
        
        payable(msg.sender).transfer(compensationToSeller);
        payable(buyer).transfer(returnedToBuyer);
        
        emit BargainCancelledBy(msg.sender);
    }

    /**
     * @notice "pulls" ethers from a contract when letter of credit is accepted/declined
     */
    function transferPaymentsToParties() external {
        (uint256 sumToSeller, uint256 sumToBuyer) = calculatePaymentsInState(bargainInitializedBy[buyer].bargainState);
        changeStateTo(States.FINISHED);

        if (sumToBuyer != 0) {
            payable(buyer).transfer(sumToBuyer);
        }
        payable(seller).transfer(sumToSeller);
        
        emit StateChangedToBy(States.FINISHED, msg.sender);
    }

    /**
     * @notice a private method that changes states in accordance to some conditions
     * these conditions are: current state, msg.sender.
     */
    function changeStateTo(States _state) private {
        if (_state == States.VALIDATED) {
            require(
                msg.sender == buyer &&
                bargainInitializedBy[msg.sender].bargainState == States.INIT
            );

            bargainInitializedBy[msg.sender].bargainState = States.VALIDATED;
        }

        if (_state == States.SENT) {
            require(
                msg.sender == shippingManager &&
                bargainInitializedBy[buyer].bargainState == States.VALIDATED
            );

            bargainInitializedBy[buyer].bargainState = States.SENT;
        }

        if (_state == States.ACCEPTED || _state == States.DECLINED) {
            require(
                msg.sender == buyer &&
                bargainInitializedBy[buyer].bargainState == States.SENT
            );

            bargainInitializedBy[msg.sender].bargainState = _state;
        }

        if (_state == States.ZS) {
            if (msg.sender == buyer) {
                require(
                    bargainInitializedBy[msg.sender].bargainState == States.INIT ||
                    (bargainInitializedBy[msg.sender].bargainState == States.VALIDATED && 
                    block.timestamp > bargainInitializedBy[msg.sender].bargainDeadline),
                    "Not correct state for buyer cancellation"
                );
            }
            
            if (msg.sender == seller) {
                require(
                    bargainInitializedBy[buyer].bargainState == States.SENT &&
                    block.timestamp > bargainInitializedBy[buyer].bargainDeadline,
                    "Not correct state for seller cancellation"
                );
            }

            bargainInitializedBy[buyer].bargainState = States.ZS;
        }

        if (_state == States.FINISHED) {
            require(
                bargainInitializedBy[buyer].bargainState == States.ACCEPTED ||
                bargainInitializedBy[buyer].bargainState == States.DECLINED,
                "Bargain wasn't accpeted, neither declined"
            );

            bargainInitializedBy[buyer].bargainState = States.FINISHED;
        }
    }

    /**
     * @notice calculates withdrawal amounts in accordance to bargain state
     */
    function calculatePaymentsInState(States _state) private view returns(uint256 sumToSeller, uint256 sumToBuyer) {
        if (_state == States.INIT || _state == States.VALIDATED) {
            sumToBuyer = bargainInitializedBy[buyer].bargainSum;
            sumToSeller = 0;
        }
        if (_state == States.SENT) {
            sumToSeller = bargainInitializedBy[buyer].bargainSum * 30/100;
            sumToBuyer = bargainInitializedBy[buyer].bargainSum - sumToSeller;
        }
        if (_state == States.ACCEPTED) {
            sumToBuyer = 0;
            sumToSeller = bargainInitializedBy[buyer].bargainSum;
        }
        if (_state == States.DECLINED) {
            sumToSeller = bargainInitializedBy[buyer].bargainSum * 15/100;
            sumToBuyer = bargainInitializedBy[buyer].bargainSum - sumToSeller;
        }
    }
}