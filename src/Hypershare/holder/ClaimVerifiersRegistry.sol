// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import 'openzeppelin-contracts/contracts/access/Ownable.sol';

import '../../Interface/IClaimVerifier.sol';
import '../../Interface/IClaimVerifiersRegistry.sol';


contract ClaimVerifiersRegistry is IClaimVerifiersRegistry, Ownable {
    
    /// @dev Array containing all TrustedVerifiers identity contract address.
    IClaimIssuer[] private trustedVerifiers;

    /// @dev Mapping between a trusted issuer index and its corresponding claimsRequired.
    mapping(address => uint256[]) private trustedIssuerClaimTopics;

    /**
     *  @dev See {IClaimVerifiersRegistry-addTrustedVerifier}.
     */
    function addTrustedVerifier(IClaimIssuer _trustedIssuer, uint256[] calldata _claimsRequired) external override onlyOwner {
        require(trustedIssuerClaimTopics[address(_trustedIssuer)].length == 0, 'trusted Issuer already exists');
        require(_claimsRequired.length > 0, 'trusted claim topics cannot be empty');
        trustedVerifiers.push(_trustedIssuer);
        trustedIssuerClaimTopics[address(_trustedIssuer)] = _claimsRequired;
        emit TrustedVerifierAdded(_trustedIssuer, _claimsRequired);
    }

    /**
     *  @dev See {IClaimVerifiersRegistry-removeTrustedVerifier}.
     */
    function removeTrustedVerifier(IClaimIssuer _trustedIssuer) external override onlyOwner {
        require(trustedIssuerClaimTopics[address(_trustedIssuer)].length != 0, 'trusted Issuer doesn\'t exist');
        uint256 length = trustedVerifiers.length;
        for (uint256 i = 0; i < length; i++) {
            if (trustedVerifiers[i] == _trustedIssuer) {
                trustedVerifiers[i] = trustedVerifiers[length - 1];
                trustedVerifiers.pop();
                break;
            }
        }
        delete trustedIssuerClaimTopics[address(_trustedIssuer)];
        emit TrustedVerifierRemoved(_trustedIssuer);
    }

    /**
     *  @dev See {IClaimVerifiersRegistry-updateIssuerClaimTopics}.
     */
    function updateIssuerClaimTopics(IClaimIssuer _trustedIssuer, uint256[] calldata _claimsRequired) external override onlyOwner {
        require(trustedIssuerClaimTopics[address(_trustedIssuer)].length != 0, 'trusted Issuer doesn\'t exist');
        require(_claimsRequired.length > 0, 'claim topics cannot be empty');
        trustedIssuerClaimTopics[address(_trustedIssuer)] = _claimsRequired;
        emit ClaimTopicsUpdated(_trustedIssuer, _claimsRequired);
    }

    /**
     *  @dev See {IClaimVerifiersRegistry-getTrustedVerifiers}.
     */
    function getTrustedVerifiers() external view override returns (IClaimIssuer[] memory) {
        return trustedVerifiers;
    }

    /**
     *  @dev See {IClaimVerifiersRegistry-isTrustedVerifier}.
     */
    function isTrustedVerifier(address _issuer) external view override returns (bool) {
        uint256 length = trustedVerifiers.length;
        for (uint256 i = 0; i < length; i++) {
            if (address(trustedVerifiers[i]) == _issuer) {
                return true;
            }
        }
        return false;
    }

    /**
     *  @dev See {IClaimVerifiersRegistry-getTrustedVerifierClaimTopics}.
     */
    function getTrustedVerifierClaimTopics(IClaimIssuer _trustedIssuer) external view override returns (uint256[] memory) {
        require(trustedIssuerClaimTopics[address(_trustedIssuer)].length != 0, 'trusted Issuer doesn\'t exist');
        return trustedIssuerClaimTopics[address(_trustedIssuer)];
    }

    /**
     *  @dev See {IClaimVerifiersRegistry-hasClaimTopic}.
     */
    function hasClaimTopic(address _issuer, uint256 _claimTopic) external view override returns (bool) {
        uint256 length = trustedIssuerClaimTopics[_issuer].length;
        uint256[] memory claimsRequired = trustedIssuerClaimTopics[_issuer];
        for (uint256 i = 0; i < length; i++) {
            if (claimsRequired[i] == _claimTopic) {
                return true;
            }
        }
        return false;
    }

    /**
     *  @dev See {IClaimVerifiersRegistry-transferOwnershipOnIssuersRegistryContract}.
     */
    function transferOwnershipOnIssuersRegistryContract(address _newOwner) external override onlyOwner {
        transferOwnership(_newOwner);
    }
}