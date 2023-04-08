// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract NftMarketplace is ReentrancyGuard, Ownable {
    IERC20 paymentToken;
    IERC721 nft;
    struct item{
        uint256 price;
        bool listed;
    }
    mapping (uint256 => item ) listItem;
    mapping (address => uint256) usernounce;
    constructor(IERC20 _paymentToken,IERC721 _nft){
        paymentToken = _paymentToken;
        nft = _nft;
    }
    function list(uint256 tokenid,uint256 _price) public returns(bool){
        listItem[tokenid] = item(_price,true);
        nft.transferFrom(msg.sender,address(this),tokenid);
        return true;
    }
    function purchaseItem(uint256 tokenId) external nonReentrant {
        require(listItem[tokenId].listed == false,"TokenId is not listed");
        require(usernounce[msg.sender] <= 5,"user exceed his limit");
        paymentToken.transferFrom(msg.sender,address(this),listItem[tokenId].price);
        nft.safeTransferFrom(address(this),msg.sender,tokenId);
        listItem[tokenId].listed = false;
        usernounce[msg.sender] +=1;
    }
    function withdrawpaymentToken(address recipient, uint256 amount, bytes32[] memory sigs) public {
    require(sigs.length >= 2, "At least two signatures are required");
    bytes32 txHash = keccak256(abi.encodePacked(address(this), recipient, amount));
    address[] memory signers = new address[](sigs.length);
    for (uint i = 0; i < sigs.length; i++) {
        address signer = recoverSigner(txHash, sigs[i]);
        signers[i] = signer;
    }
    require(allSignersUnique(signers), "Duplicate signers are not allowed");
    paymentToken.transferFrom(address(this),recipient,amount);
    }
    function recoverSigner(bytes32 hash, bytes32 sig) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
        r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := byte(0, mload(add(sig, 96)))
    }
    if (v < 27) {
        v += 27;
    }
    require(v == 27 || v == 28, "Invalid signature version");
    return ecrecover(hash, v, r, s);
    }
    function allSignersUnique(address[] memory signers) internal pure returns (bool) {
    for (uint i = 0; i < signers.length; i++) {
        for (uint j = i + 1; j < signers.length; j++) {
            if (signers[i] == signers[j]) {
                return false;
            }
        }
    }
    return true;
    }
}