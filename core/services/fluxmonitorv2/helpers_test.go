package fluxmonitorv2

import (
	"github.com/GoPlugin/Plugin/core/internal/gethwrappers/generated/flux_aggregator_wrapper"
	"github.com/GoPlugin/Plugin/core/services/log"
	"github.com/GoPlugin/Plugin/core/utils"
)

func (fm *FluxMonitor) ExportedPollIfEligible(threshold, absoluteThreshold float64) {
	fm.pollIfEligible(PollRequestTypePoll, NewDeviationChecker(threshold, absoluteThreshold), nil)
}

func (fm *FluxMonitor) ExportedProcessLogs() {
	fm.processLogs()
}

func (fm *FluxMonitor) ExportedBacklog() *utils.BoundedPriorityQueue {
	return fm.backlog
}

func (fm *FluxMonitor) ExportedRoundState() {
	fm.roundState(0)
}

func (fm *FluxMonitor) ExportedRespondToNewRoundLog(log *flux_aggregator_wrapper.FluxAggregatorNewRound, broadcast log.Broadcast) {
	fm.respondToNewRoundLog(*log, broadcast)
}
