import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Hatchy.sol";

pragma solidity ^0.8.0;

contract HatchyPocketEggs is OwnableUpgradeable, ERC1155Upgradeable {

    using Strings for uint256;

    uint public PRICE;

    IERC20 HatchyToken;

    address public HatchyPocketGen2;

    // TODO, adjust on mainnet.
    uint public constant MAX_LUNAR = 249990;
    uint public constant MAX_SOLAR = 249990;
    uint public constant MAX_PER_TX = 40;

    mapping(Hatchy.Egg => uint) public eggSupplies;

    modifier onlyHatchyGen2 {
        require(msg.sender == HatchyPocketGen2, "h4x0r");
        _;
    }


    function initialize(string memory _baseUri, uint _price, address _erc20) external initializer {
        __ERC1155_init(_baseUri);
        __Ownable_init();
        PRICE = _price;
        HatchyToken = IERC20(_erc20);
    }

    function setHatchyGen2(address _gen2Address) external onlyOwner {
        HatchyPocketGen2 = _gen2Address;
    }

    function setPrice(uint _price) external onlyOwner {
        PRICE = _price;
    }

    function setHatchy(address _hatchy) external onlyOwner {
        HatchyToken = IERC20(_hatchy);
    }

    function mintEgg(Hatchy.Egg egg, uint amount) external {
        egg == Hatchy.Egg.LUNAR ?
        require(eggSupplies[egg] + amount <= MAX_LUNAR, "max.")
        :
        require(eggSupplies[egg] + amount <= MAX_SOLAR, "max.");

        require(amount <= MAX_PER_TX);

        if (PRICE > 0) {
            require(
                HatchyToken.transferFrom(
                    msg.sender,
                    owner(),
                    PRICE * amount)
            );
        }


        eggSupplies[egg] += amount;
        _mint(msg.sender, uint(egg), amount, new bytes(0));
    }

    function burn(Hatchy.Egg egg, uint amount) external {
        _burn(msg.sender, uint(egg), amount);
    }

    function burnEggOfUser(Hatchy.Egg egg, address account, uint amount) external onlyHatchyGen2 {
        require(balanceOf(account, uint(egg)) >= amount && amount > 0, "bal.");
        _burn(account, uint(egg), amount);
    }

    function setBaseMetadataURI(
        string memory _newBaseMetadataURI
    ) public onlyOwner {
        _setURI(_newBaseMetadataURI);
    }

    function tokenURI(uint256 id) public view returns (string memory) {
        return string(abi.encodePacked(uri(id), id.toString()));
    }

    function uri(
        uint256 _id
    ) public view override returns (string memory) {
        return tokenURI(_id);
    }

    function accountBalanceBatch(address account, uint[] memory ids) external view returns (uint[] memory){
        uint[] memory result = new uint[](ids.length);
        for (uint i = 0; i < ids.length;) {
            result[i] = balanceOf(account, ids[i]);
        unchecked{i++;}
        }
    }

}
