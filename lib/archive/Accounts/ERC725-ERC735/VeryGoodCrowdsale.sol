pragma solidity 0.4.24;

import './VeryGoodCoin.sol';
import './ClaimRegistry.sol';
import 'openzeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol';

contract VeryGoodCrowdsale is MintedCrowdsale {

	event ClaimValid(ClaimHolder _identity, uint256 claimType);
	event ClaimInvalid(ClaimHolder _identity, uint256 claimType);

	ClaimHolder public trustedClaimHolder;

	constructor (
		uint256 _rate,
		address _wallet,
		MintableToken _token,
		address _trustedClaimHolder
	) public Crowdsale(_rate, _wallet, _token) {
		trustedClaimHolder = ClaimHolder(_trustedClaimHolder);
	}

	/*
	* overriden from openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol
	*/
	function _preValidatePurchase(
		address _beneficiary,
		uint256 _weiAmount
	)
		internal
	{
		require(_beneficiary != address(0));
		require(_weiAmount != 0);

		ClaimHolder beneficiaryIdentity = ClaimHolder(_beneficiary);
		require(checkClaim(beneficiaryIdentity, 7));
	}

	function checkClaim(ClaimHolder _identity, uint256 claimType)
		public
		returns (bool claimValid)
	{
		if (claimIsValid(_identity, claimType)) {
			emit ClaimValid(_identity, claimType);
			return true;
		}
		else {
			emit ClaimInvalid(_identity, claimType);
			return false;
		}
	}

	function claimIsValid(ClaimHolder _identity, uint256 claimType)
		public
		constant
		returns (bool claimValid)
	{
		uint256 foundClaimType;
		uint256 scheme;
		address issuer;
		bytes memory sig;
		bytes memory data;

		// Construct claimId (identifier + claim type)
		bytes32 claimId = keccak256(trustedClaimHolder, claimType);

		// Fetch claim from user
		( foundClaimType, scheme, issuer, sig, data, ) = _identity.getClaim(claimId);

		bytes32 dataHash = keccak256(_identity, claimType, data);
		bytes32 prefixedHash = keccak256("\x19Ethereum Signed Message:\n32", dataHash);

		// Recover address of data signer
		address recovered = getRecoveredAddress(sig, prefixedHash);

		// Take hash of recovered address
		bytes32 hashedAddr = keccak256(recovered);

		// Does the trusted identifier have they key which signed the user's claim?
		return trustedClaimHolder.keyHasPurpose(hashedAddr, 3);
	}

	function getRecoveredAddress(bytes sig, bytes32 dataHash)
		public
		pure
		returns (address addr)
	{
		bytes32 ra;
		bytes32 sa;
		uint8 va;

		// Check the signature length
		if (sig.length != 65) {
			return (0);
		}

		// Divide the signature in r, s and v variables
		assembly {
			ra := mload(add(sig, 32))
			sa := mload(add(sig, 64))
			va := byte(0, mload(add(sig, 96)))
		}

		if (va < 27) {
			va += 27;
		}

		address recoveredAddress = ecrecover(dataHash, va, ra, sa);

		return (recoveredAddress);
	}
}
