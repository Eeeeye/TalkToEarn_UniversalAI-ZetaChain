// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 1. 引入 Ownable
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

// 2. 继承 Ownable
contract SimpleMintOnlyNFT is IERC721, Ownable {
    string public name;
    string public symbol;

    uint256 private _tokenIdCounter = 1;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => string) private _tokenURIs;

    // 3. 初始化 Ownable (设置部署者为初始 Owner)
    constructor(string memory name_, string memory symbol_) Ownable(msg.sender) {
        name = name_;
        symbol = symbol_;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    // 4. 添加 onlyOwner 修饰符：只有 Owner (也就是 Manager 合约) 能铸造
    function mint(address to, string memory uri) public onlyOwner {
        require(to != address(0), "Mint to zero address");
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }
}