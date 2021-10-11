package keeper

import (
	"github.com/GoPlugin/Plugin/core/internal/gethwrappers/generated/keeper_registry_wrapper"
	"github.com/GoPlugin/Plugin/core/services/eth"
)

var RegistryABI = eth.MustGetABI(keeper_registry_wrapper.KeeperRegistryABI)
