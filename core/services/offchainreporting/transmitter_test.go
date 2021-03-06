package offchainreporting_test

import (
	"context"
	"testing"

	"github.com/GoPlugin/Plugin/core/internal/cltest"
	bptxmmocks "github.com/GoPlugin/Plugin/core/services/bulletprooftxmanager/mocks"
	"github.com/GoPlugin/Plugin/core/services/offchainreporting"
	"github.com/GoPlugin/Plugin/core/store/models"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

func Test_Transmitter_CreateEthTransaction(t *testing.T) {
	store, cleanup := cltest.NewStore(t)
	defer cleanup()

	key := cltest.MustInsertRandomKey(t, store.DB, 0)

	gasLimit := uint64(1000)
	fromAddress := key.Address.Address()
	toAddress := cltest.NewAddress()
	payload := []byte{1, 2, 3}
	txm := new(bptxmmocks.TxManager)

	transmitter := offchainreporting.NewTransmitter(txm, store.DB, fromAddress, gasLimit)

	txm.On("CreateEthTransaction", mock.Anything, fromAddress, toAddress, payload, gasLimit, nil).Return(models.EthTx{}, nil).Once()
	require.NoError(t, transmitter.CreateEthTransaction(context.Background(), toAddress, payload))

	txm.AssertExpectations(t)
}
