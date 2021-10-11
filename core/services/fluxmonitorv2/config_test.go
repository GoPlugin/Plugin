package fluxmonitorv2_test

import (
	"testing"
	"time"

	"github.com/GoPlugin/Plugin/core/assets"
	"github.com/GoPlugin/Plugin/core/internal/cltest"
	"github.com/GoPlugin/Plugin/core/services/fluxmonitorv2"
	"github.com/stretchr/testify/assert"
)

func TestConfig(t *testing.T) {
	flagsContractAddress := cltest.NewAddress()

	cfg := &fluxmonitorv2.Config{
		DefaultHTTPTimeout:       time.Minute,
		FlagsContractAddress:     flagsContractAddress.Hex(),
		MinContractPayment:       assets.NewLink(1),
		EthGasLimit:              21000,
		EthMaxQueuedTransactions: 0,
	}

	t.Run("MinimumPollingInterval", func(t *testing.T) {
		assert.Equal(t, time.Minute, cfg.MinimumPollingInterval())
	})
}
