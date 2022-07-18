// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

interface IComplianceClaimsRequired {

    event ClaimVerifiersRegistrySet(address indexed trustedVerifiersRegistry);

    event ClaimTopicAdded(uint256 indexed claimTopic);

    event ClaimTopicRemoved(uint256 indexed claimTopic);

    function addClaimTopic(uint256 _claimTopic) external;

    function removeClaimTopic(uint256 _claimTopic) external;

    function getClaimTopics() external view returns (uint256[] memory);

    function transferOwnershipOnComplianceClaimsRequiredContract(address _newOwner) external;
    
    function isVerified(address _account) external view returns (bool);
    
}