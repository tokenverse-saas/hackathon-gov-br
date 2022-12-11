// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IGBRL} from "./GBRL.sol";

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract GovBRPropertyRegistry is
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable
{
    constructor()
        ERC721("GovBRProperyRegistry", "GOVBR")
    {
        _setApprovalForAll(address(this), msg.sender, true);
    }
    
    using Strings for uint256;
    using Counters for Counters.Counter;

    /** EVENTS */

    event PropertyCreated(uint256 _createdAt);
    event PropertyUpdated(uint256 _updatedAt, address _newOwner);

    /** STATES */

    Counters.Counter private _propertyIds;
    IGBRL private constant GBRLStableCoin =
        IGBRL(0x39D3d1FDf7047eF947584AF4785906D0769d6278);

    /** METHODS */

    modifier updateCounter(Counters.Counter storage counter) {
        _;
        counter.increment();
    }

    function propertyRegistration(
        string memory _title,
        string memory _description,
        uint256 _price,
        string memory _address,
        uint256 _registrationNumber
    )
        external
        onlyOwner
        updateCounter(_propertyIds)
    {
        uint256 currentId = _propertyIds.current();

        bytes memory json = abi.encodePacked(
            "{",
            '"id":"',
            currentId.toString(),
            '",'
            '"title":"',
            _title,
            '",',
            '"description":"',
            _description,
            '",',
            '"price":"',
            _price.toString(),
            '",',
            '"address":"',
            _address,
            '",',
            '"registrationNumber":"',
            _registrationNumber.toString(),
            '"',
            "}"
        );

        string memory finalTokenURI = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(json)
            )
        );

        _mint(msg.sender, currentId);
        _setTokenURI(currentId, finalTokenURI);

        emit PropertyCreated(block.timestamp);
    }

    function propertyDestination(
        address _to,
        uint256 _tokenId
    ) external {
        safeTransferFrom(msg.sender, _to, _tokenId);

        emit PropertyUpdated(block.timestamp, _to);
    }

    function propertyTransfer(
        address _buyerWallet,
        uint256 _tokenId,
        uint256 _propertyPrice
    ) external onlyOwner {
        GBRLStableCoin.transferFrom(
            _buyerWallet,
            msg.sender,
            _propertyPrice
        );

        transferFrom(msg.sender, _buyerWallet, _tokenId);

        emit PropertyUpdated(block.timestamp, _buyerWallet);
    }

    /** OVERRIDES */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
