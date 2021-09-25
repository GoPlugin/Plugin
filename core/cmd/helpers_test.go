package cmd

import "github.com/GoPlugin/Plugin/core/services/keystore"

func (auth TerminalKeyStoreAuthenticator) ExportedValidatePasswordStrength(ethKeyStore *keystore.Eth, password string) error {
	return auth.validatePasswordStrength(ethKeyStore, password)
}
