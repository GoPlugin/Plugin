const MyContract = artifacts.require('MyContract')
const { PluginToken } = require('@plugin/contracts/truffle/v0.4/PluginToken')
const { Oracle } = require('@plugin/contracts/truffle/v0.4/Oracle')

module.exports = (deployer, network, [defaultAccount]) => {
  // Local (development) networks need their own deployment of the LINK
  // token and the Oracle contract
  if (!network.startsWith('live')) {
    PluginToken.setProvider(deployer.provider)
    Oracle.setProvider(deployer.provider)

    deployer.deploy(PluginToken, { from: defaultAccount }).then((plugin) => {
      return deployer
        .deploy(Oracle, plugin.address, { from: defaultAccount })
        .then(() => {
          return deployer.deploy(MyContract, plugin.address)
        })
    })
  } else {
    // For live networks, use the 0 address to allow the ChainpluginRegistry
    // contract automatically retrieve the correct address for you
    deployer.deploy(MyContract, '0x0000000000000000000000000000000000000000')
  }
}
