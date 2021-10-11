package vrf

import (
	"github.com/GoPlugin/Plugin/core/services/keystore/keys/vrfkey"
)

func GenerateProofResponseFromProof(proof vrfkey.Proof, s PreSeedData) (
	MarshaledOnChainResponse, error) {
	return generateProofResponseFromProof(proof, s)
}
