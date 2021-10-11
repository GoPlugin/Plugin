package main

import (
	"context"
	"fmt"
	"net/url"
	"time"

	"github.com/GoPlugin/Plugin/core/internal/mocks"
	"github.com/GoPlugin/Plugin/core/store/models"

	"github.com/ethereum/go-ethereum"
	"github.com/GoPlugin/Plugin/core/services"
	"github.com/GoPlugin/Plugin/core/services/eth"
)

func panicErr(err error) {
	if err != nil {
		panic(err)
	}
}

func main() {
	cb := func(rm services.RunManager, lr models.LogRequest) {}
	c, err := eth.NewClient("ws://localhost:8546", nil, []url.URL{})
	panicErr(err)
	err = c.Dial(context.Background())
	panicErr(err)
	rm := new(mocks.RunManager)
	sub, err := services.NewInitiatorSubscription(models.Initiator{}, c, rm, ethereum.FilterQuery{}, 0, cb)
	panicErr(err)
	fmt.Println(sub)
	time.Sleep(30 * time.Second)
	// While this is connected run:
	// docker stop <id of node container>
	// docker start <id of node container>
	// and ensure you see reconnection logs.
}
