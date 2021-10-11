package adapters

import (
	"time"

	"github.com/GoPlugin/Plugin/core/logger"
	"github.com/GoPlugin/Plugin/core/services/keystore"
	"github.com/GoPlugin/Plugin/core/store"
	"github.com/GoPlugin/Plugin/core/store/models"
	"github.com/GoPlugin/Plugin/core/utils"
)

// Sleep adapter allows a job to do nothing for some amount of wall time.
type Sleep struct {
	Until models.AnyTime `json:"until"`
}

// TaskType returns the type of Adapter.
func (adapter *Sleep) TaskType() models.TaskType {
	return TaskTypeSleep
}

// Perform returns the input RunResult after waiting for the specified Until parameter.
func (adapter *Sleep) Perform(input models.RunInput, str *store.Store, _ *keystore.Master) models.RunOutput {
	duration := adapter.Duration()
	if duration > 0 {
		logger.Debugw("Task sleeping...", "duration", duration)
		<-str.Clock.After(duration)
	}

	return models.NewRunOutputComplete(models.JSON{})
}

// Duration returns the amount of sleeping this task should be paused for.
func (adapter *Sleep) Duration() time.Duration {
	return utils.DurationFromNow(adapter.Until.Time)
}
