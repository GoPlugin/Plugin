package headtracker

import (
	"github.com/GoPlugin/Plugin/core/logger"
	httypes "github.com/GoPlugin/Plugin/core/services/headtracker/types"
	"github.com/GoPlugin/Plugin/core/store/models"
)

var _ httypes.Tracker = &NullTracker{}

type NullTracker struct{}

func (n *NullTracker) HighestSeenHeadFromDB() (*models.Head, error) {
	return nil, nil
}
func (*NullTracker) Start() error             { return nil }
func (*NullTracker) Stop() error              { return nil }
func (*NullTracker) SetLogger(*logger.Logger) {}
