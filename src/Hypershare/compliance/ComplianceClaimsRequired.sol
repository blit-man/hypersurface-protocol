// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import 'openzeppelin-contracts/contracts/access/Ownable.sol';

import '../../Interface/IComplianceClaimsRequired.sol';

contract ComplianceClaimsRequired is IComplianceClaimsRequired, Ownable {
    
    // @dev Mapping from token id to required Claim Topics
    mapping(uint256 => uint256[]) private claimTopics[id];

    /**
     *  @dev See {IComplianceClaimsRequired-addClaimTopic}.
     */
    function addClaimTopic(
        uint256 claimTopic,
        uint256 id,
    )
        external
        override
        onlyOwner
    {
        uint256 length = claimTopics[id].length;
        for (uint256 i = 0; i < length; i++) {
            require(claimTopics[id][i] != claimTopic, 'claimTopic already exists');
        }
        claimTopics[id].push(claimTopic);
        emit ClaimTopicAdded(claimTopic);
    }

    /**
     *  @dev See {IComplianceClaimsRequired-removeClaimTopic}.
     */
    function removeClaimTopic(
        uint256 claimTopic
    )
        external
        override
        onlyOwner
    {
        uint256 length = claimTopics[id].length;
        for (uint256 i = 0; i < length; i++) {
            if (claimTopics[id][i] == claimTopic) {
                claimTopics[id][i] = claimTopics[id][length - 1];
                claimTopics[id].pop();
                emit ClaimTopicRemoved(claimTopic);
                break;
            }
        }
    }

    /**
     *  @dev See {IComplianceClaimsRequired-getClaimTopics}.
     */
    function getClaimTopics()
        external
        view
        override
        returns (uint256[] memory)
    {
        return claimTopics[id];
    }

    /**
     *  @dev See {IComplianceClaimsRequired-transferOwnershipOnComplianceClaimsRequiredContract}.
     */
    function transferOwnershipOnComplianceClaimsRequiredContract(
        address _newOwner
    )
        external
        override
        onlyOwner
    {
        transferOwnership(_newOwner);
    }
}