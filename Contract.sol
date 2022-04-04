// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";

contract Contract is ERC721A, PaymentSplitter, Ownable {

    using Strings for uint256;

    uint public constant MAX_SUPPLY = 1000;
    uint public constant MAX_MINT_PER_TRANSACTION = 20;
    uint public price = 0.45 ether;

    string public baseURI;

    bool public paused;
    bool public saleIsActive;

    mapping(address => uint) TotalMintedTokens;

    constructor(string memory _name, string memory _symbol, string memory _baseURI, address[] memory _team, uint[] memory _teamShares)
    ERC721A(_name, _symbol)
    PaymentSplitter(_team, _teamShares) {
        setBaseURI(_baseURI);
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        require(_exists(_tokenId), "This token doesn't exists");

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json")) : "";
    }

    function mint(address _to, uint _amount) external payable {
        uint totSupply = totalSupply();
        require(saleIsActive, "Sale is not active");
        require(!paused, "Paused contract");
        require(_amount > 0, "You can not mint 0 nft");
        require(_amount <= MAX_MINT_PER_TRANSACTION, "You cant mint more than 20 nft");
        require(totSupply + _amount <= MAX_SUPPLY, "Amount is too big");
        
        if(msg.sender != owner()) {
            require(msg.value >= _amount * price);
        }

        _safeMint(_to, _amount);
        TotalMintedTokens[msg.sender] += 1;
    }

    function setBaseURI(string memory _baseURI) internal onlyOwner {
        baseURI = _baseURI;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setPrice(uint _price) external onlyOwner {
        price = _price;
    }

    function setActiveSale(bool _active) external onlyOwner {
        saleIsActive = _active;
    }

    function withdraw() external payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
    
}
