pragma solidity 0.5.15;

// https://github.com/makerdao/sai/blob/master/src/tap.sol
contract SaiTapInterface {
    function sai() public view returns (address);
    function cash(uint256) public;
}

contract TokenInterface {
    function approve(address, uint256) public;
    function transferFrom(address, address, uint256) public returns (bool);
    function withdraw(uint256) public;
    function balanceOf(address) public view returns (uint256);
}

// User must approve() this contract on Sai prior to calling.
contract CageFree {

    address public tap;
    address public sai;
    address public weth;

    event FreeCash(address sender, uint256 amount);

    constructor(address _tap, address _weth) public {
        tap  = _tap;
        sai  = SaiTapInterface(tap).sai();
        weth = _weth;
        TokenInterface(sai).approve(tap, uint256(-1));
    }

    function freeCash(uint256 wad) public returns (uint256) {
        TokenInterface(sai).transferFrom(msg.sender, address(this), wad);
        SaiTapInterface(tap).cash(wad);
        uint256 cashoutBalance = TokenInterface(weth).balanceOf(address(this));
        TokenInterface(weth).withdraw(cashoutBalance);
        msg.sender.transfer(cashoutBalance);
        emit FreeCash(msg.sender, cashoutBalance);
        return cashoutBalance;
    }

    function() external payable {
        require(msg.sender == weth, "Only WETH can send ETH");
    }
}
