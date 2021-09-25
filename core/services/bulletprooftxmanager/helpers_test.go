package bulletprooftxmanager

import (
	"github.com/GoPlugin/Plugin/core/services/eth"
)

func SetEthClientOnEthConfirmer(ethClient eth.Client, ethConfirmer *EthConfirmer) {
	ethConfirmer.ethClient = ethClient
}
