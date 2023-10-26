pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Airdrop is Pausable {
   
   //The variable for the contract
    address public owner;
    address public immutable token;
    bytes32 public immutable merkleRoot;
    uint256 public immutable airdropAmount;

    bool public claimIsPaused; 


    mapping(address => uint) private addressesClaimed; //set of address that claimed airdrop

    mapping(address => uint) private claimedBitMap ;//an array of booleans

     modifier onlyOwner() {
        require(msg.sender == owner, "Only the ownercan perform this action");
        _;
    }

   // event Claimed(address index _from, uint256 _airdropAmount);



    //the constructor for contract
    constructor (address _token, bytes32 _merkleRoot, uint256 _airdropAmount) {
        token = _token;
        merkleRoot = _merkleRoot;
        airdropAmount = _airdropAmount;
    }

       function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editClaimWindow(
        bool _claimIsPaused
    ) public onlyOwner {
        claimIsPaused = _claimIsPaused;
    }


    function claim(bytes32[] calldata merkleProof) external payable {
        require(claimIsPaused, "claim is paused");
        require(addressesClaimed[msg.sender] == 0, "This motherfucker has claimed once");

        //verifying the merkleproof
        bytes32 node = keccak256(abi.encodePacked(msg.sender));

        require(MerkleProof.verify(merkleProof, merkleRoot, node), "This motherFucker is not eligible");

        require(msg.value == 0.00015 ether, "Please send the correct amount of ETH");
       
        //sinces user has not claimed but eligible from drop, mark it as claimed
        addressesClaimed[msg.sender] = 1;

        //transfer tokens from this to msg.sender
        require(IERC20(token).transfer(msg.sender, airdropAmount),"This motherFucker token claim failed");

       // emit Claimed(msg.sender, airdropAmount);    
    }

    function withdrawFunds() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        payable(owner).transfer(contractBalance);
    }



}
