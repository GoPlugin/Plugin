<br/>
<p align="center">
<a href="https://goplugin.co" target="_blank">
<img src="https://github.com/GoPlugin/Plugin/blob/main/docs/logo-dark-2.png" width="225" alt="Plugin logo">
</a>
</p>
<br/>

[Plugin](https://goplugin.co/) is middleware to simplify communication with blockchains.
Here you'll find the Plugin Golang node, currently in alpha.
This initial implementation is intended for use and review by developers,
and will go on to form the basis for Plugin's [decentralized oracle network](https://goplugin.co/goAssets/White%20Paper%20-%20Decentralized%20Oracle%20Network%20Powered%20by%20XinFin%20Blockchain%20Network.pdf).
Further development of the Plugin Node and Plugin Network will happen here,
if you are interested in contributing please see our [contribution guidelines](./docs/CONTRIBUTING.md).

## Features

- easy connectivity of on-chain contracts to any off-chain computation or API
- multiple methods for scheduling both on-chain and off-chain computation for a user's smart contract
- automatic gas price bumping to prevent stuck transactions, assuring your data is delivered in a timely manner
- push notification of smart contract state changes to off-chain systems, by tracking Xinfin logs
- translation of various off-chain data types into EVM consumable types and transactions
- easy to implement smart contract libraries for connecting smart contracts directly to their preferred oracles
- easy to install node, which runs natively across operating systems, blazingly fast, and with a low memory footprint


## Community

Plugin has an active and ever growing community. [Discord](https://discord.gg/4ATypYHudd)
is the primary communication channel used for day to day communication,
answering development questions, and aggregating Chainlink related content. Take
a look at the [community docs](./docs/COMMUNITY.md) for more information
regarding Chainlink social accounts, news, and networking.

## Install

1. [Install Go 1.15](https://golang.org/doc/install), and add your GOPATH's [bin directory to your PATH](https://golang.org/doc/code.html#GOPATH)
   - Example Path for macOS `export PATH=$GOPATH/bin:$PATH` & `export GOPATH=/Users/$USER/go`
2. Install [NodeJS 12.18](https://nodejs.org/en/download/package-manager/) & [Yarn](https://yarnpkg.com/lang/en/docs/install/)
   - It might be easier long term to use [nvm](https://nodejs.org/en/download/package-manager/#nvm) to switch between node versions for different projects: `nvm install 12.18 && nvm use 12.18`
3. Install [Postgres (>= 11.x)](https://wiki.postgresql.org/wiki/Detailed_installation_guides).
   - You should [configure Postgres](https://www.postgresql.org/docs/12/ssl-tcp.html) to use SSL connection
4. Download Plugin: `git clone https://github.com/GoPlugin/Plugin.git && cd Plugin`
5. Build and install Plugin: `make install`
   - If you got any errors regarding locked yarn package, try running `yarn install` before this step
6. Run the node: `plugin help`

### Xinfin Node Requirements

In order to run the Plugin node you must have access to a running Xinfin node with an open websocket connection.
Any Xinfin based network will work once you've [configured](https://github.com/XinFinOrg/XinFin-Node) the chain ID.
Xinfin node versions currently tested and supported:

- [Parity 1.11+](https://github.com/paritytech/parity-ethereum/releases) (due to a [fix with pubsub](https://github.com/paritytech/parity/issues/6590).)
- [Geth 1.8+](https://github.com/ethereum/go-ethereum/releases)

## Run

**NOTE**: By default, Plugin will run in TLS mode. For local development you can either disable this by setting PLUGIN_DEV to true, or generate self signed certificates using `tools/bin/self-signed-certs`

To start your Plugin node, simply run:

```bash
plugin node start
```

By default this will start on port 6688.

Once your node has started, you can view your current jobs with:

```bash
plugin job_specs list # v1 jobs
plugin jobs list # v2 jobs
```

View details of a specific job with:

```bash
plugin job_specs show "$JOB_ID # v1 jobs"
```

To find out more about the plugin CLI, you can always run `plugin help`.

Check out the [docs'](https://docs.plugin.co/) pages on [Adapters](https://docs.goplugin.co/docs/adapters) and [Initiators](https://docs.goplugin.co/docs/initiators) to learn more about how to create Jobs and Runs.

## Configure

You can configure your node's behavior by setting environment variables. All the environment variables can be found in the `ConfigSchema` struct of `schema.go`. You can also read the [official documentation](https://docs.goplugin.co/docs/configuration-variables) to learn the most up to date information on each of them. For every variable, default values get used if no corresponding environment variable is found.

## External Adapters

External adapters are what make Plugin easily extensible, providing simple integration of custom computations and specialized APIs.
A Plugin node communicates with external adapters via a simple REST API.

### Build your current version

```bash
go build -o Plugin ./core/
```

- Run the binary:

```bash
./Plugin
```

### Test Core

1. [Install Yarn](https://yarnpkg.com/lang/en/docs/install)

2. Install [gencodec](https://github.com/fjl/gencodec), [mockery version 1.0.0](https://github.com/vektra/mockery/releases/tag/v1.0.0), and [jq](https://stedolan.github.io/jq/download/) to be able to run `go generate ./...` and `make abigen`

3. Build contracts:

```bash
yarn
yarn setup:contracts
```

4. Generate and compile static assets:

```bash
go generate ./...
go run ./packr/main.go ./core/services/eth/
```

5. Prepare your development environment:

```bash
export DATABASE_URL=postgresql://127.0.0.1:5432/chainlink_test?sslmode=disable
export PLUGIN_DEV=true # I prefer to use direnv and skip this
```

6.  Drop/Create test database and run migrations:

```
go run ./core/main.go local db preparetest
```

If you do end up modifying the migrations for the database, you will need to rerun

7. Run tests:

```bash
go test -parallel=1 ./...
```

### Solidity Development

> Note: `evm-contracts/` directory houses Solidity versions <=0.7. New contracts, using v0.8, are being developed in the `contracts/` directory, using hardhat.

Inside the `evm-contracts/` directory:

1. [Install Yarn](https://yarnpkg.com/lang/en/docs/install)
2. Install the dependencies:

```bash
yarn
yarn setup
```

3. Run tests:

   i. Solidity versions `0.4.x` to `0.7.x`:

   ```bash
   yarn test
   ```

#### Solidity >=v0.8

Inside the `contracts/` directory:
1. Install dependencies:

```bash
yarn
```

2. Run tests:

```bash
yarn test
```

### Use of Go Generate

Go generate is used to generate mocks in this project. Mocks are generated with [mockery](https://github.com/vektra/mockery) and live in core/internal/mocks.

### Nix Flake

A [flake](https://nixos.wiki/wiki/Flakes) is provided for use with the [Nix
package manager](https://nixos.org/). It defines a declarative, reproducible
development environment.

To use it:

1. [Nix has to be installed with flake support](https://nixos.wiki/wiki/Flakes#Installing_flakes).
2. Run `nix develop`. You will be put in shell containing all the dependencies.
   Alternatively, a `direnv` integration exists to automatically change the
   environment when `cd`-ing into the folder.
3. Create a local postgres database:

```
cd $PGDATA/
initdb
pg_ctl -l $PGDATA/postgres.log -o "--unix_socket_directories='$PWD'" start
createdb chainlink_test -h localhost
createuser --superuser --no-password chainlink -h localhost
```

4. Start postgres, `pg_ctl -l $PGDATA/postgres.log -o "--unix_socket_directories='$PWD'" start`

Now you can run tests or compile code as usual.

### Development Tips

For more tips on how to build and test Chainlink, see our [development tips page](https://github.com/smartcontractkit/chainlink/wiki/Development-Tips).

## Contributing

Plugin's source code is [licensed under the MIT License](./LICENSE), and contributions are welcome.

Please check out our [contributing guidelines](./docs/CONTRIBUTING.md) for more details.

Thank you!

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Inspiration

Chainlink