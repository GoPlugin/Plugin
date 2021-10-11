package web

import (
	"github.com/GoPlugin/Plugin/core/services/chainlink"
	"github.com/GoPlugin/Plugin/core/web/presenters"

	"github.com/gin-gonic/gin"
)

// TxAttemptsController lists TxAttempts requests.
type TxAttemptsController struct {
	App chainlink.Application
}

// Index returns paginated transaction attempts
func (tac *TxAttemptsController) Index(c *gin.Context, size, page, offset int) {
	attempts, count, err := tac.App.GetStore().EthTxAttempts(offset, size)
	ptxs := make([]presenters.EthTxResource, len(attempts))
	for i, attempt := range attempts {
		ptxs[i] = presenters.NewEthTxResourceFromAttempt(attempt)
	}
	paginatedResponse(c, "transactions", size, page, ptxs, count, err)
}
