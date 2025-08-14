#!/usr/bin/env bash

set -eou pipefail

# syn-protobuf.sh is a bash script to sync the protobuf
# files using ibc-proto-compiler. This script will checkout
# the protobuf files from the git versions specified in
# proto/src/prost/IBC_GO_COMMIT. If you want to sync
# the protobuf files to a newer version, modify the
# corresponding of those 2 files by specifying the commit ID
# that you wish to checkout from.

# This script should be run from the root directory of ibc-proto-rs.

# We can specify where to clone the git repositories
# for cosmos-sdk and ibc-go. By default they are cloned
# to /tmp/cosmos-sdk.git and /tmp/ibc-go.git.
# We can override this to existing directories
# that already have a clone of the repositories,
# so that there is no need to clone the entire
# repositories over and over again every time
# the script is called.

CACHE_PATH="${XDG_CACHE_HOME:-$HOME/.cache}"/neutron-proto-rs-build
NEUTRON_GO_GIT="${NEUTRON_GO_GIT:-$CACHE_PATH/neutron-go.git}"

NEUTRON_GO_COMMIT="$(cat src/NEUTRON_GO_COMMIT)"

echo "NEUTRON_GO_COMMIT: $NEUTRON_GO_COMMIT"





# If the git directories does not exist, clone them as
# bare git repositories so that no local modification
# can be done there.

if [[ ! -e "$NEUTRON_GO_COMMIT" ]]
then
    echo "Cloning neutron-go source code to as bare git repository to $NEUTRON_GO_GIT"
    git clone --mirror https://github.com/neutron-org/neutron.git "$NEUTRON_GO_GIT"
else
    echo "Using existing neutron-go bare git repository at $NEUTRON_GO_GIT"
fi


pushd "$NEUTRON_GO_GIT"
git fetch
popd

NEUTRON_GO_DIR=$(mktemp -d /tmp/neutron-go-XXXXXXXX)

pushd "$NEUTRON_GO_DIR"
git clone "$NEUTRON_GO_GIT" .
git checkout "$NEUTRON_GO_COMMIT"

popd
cp script/buf.yaml "$NEUTRON_GO_DIR/proto/buf.yaml"
cd proto
buf export -v -o ../proto-include
popd


# Remove the existing generated protobuf files
# so that the newly generated code does not
# contain removed files.

PROST_DIR="prost"

rm -rf "src/$PROST_DIR"
mkdir -p "src/$PROST_DIR"

cd tools/proto-compiler

cargo build

# Run the proto-compiler twice,
# once with transport and once without


cargo run -- compile \
  --transport \
  --neutron "$NEUTRON_GO_DIR/proto-include" \
  --out "../../src/$PROST_DIR"

cd ../..

# Remove generated ICS23 code because it is not used,
# we instead re-exports the `ics23` crate type definitions.
rm -f "src/$PROST_DIR/cosmos.ics23.v1.rs"

# Remove leftover Cosmos SDK modules.
rm -f "src/$PROST_DIR/cosmos.base.store.v1beta1.rs"
rm -f "src/$PROST_DIR/cosmos.auth.v1beta1.rs"
#rm -f "src/$PROST_DIR/cosmos.base.query.v1beta1.rs"
#rm -f "src/$PROST_DIR/cosmos.base.v1beta1.rs"
rm -f "src/$PROST_DIR/cosmos.staking.v1beta1.rs"
rm -f "src/$PROST_DIR/cosmos.upgrade.v1beta1.rs"
rm -f "src/$PROST_DIR/cosmos_proto.rs"
#
rm -f "src/$PROST_DIR/ibc.applications.transfer.v1.rs"
rm -f "src/$PROST_DIR/ibc.applications.transfer.v1.serde.rs"
rm -f "src/$PROST_DIR/ibc.core.channel.v1.rs"
rm -f "src/$PROST_DIR/ibc.core.channel.v1.serde.rs"
rm -f "src/$PROST_DIR/ibc.core.client.v1.rs"
rm -f "src/$PROST_DIR/ibc.core.client.v1.serde.rs"

# The Tendermint ABCI protos are unused from within ibc-proto
rm -f "src/$PROST_DIR/tendermint.abci.rs"

# Remove leftover Google HTTP configuration protos.
rm -f "src/$PROST_DIR/google.api.rs"

# Remove the temporary checkouts of the repositories

rm -rf "$NEUTRON_GO_DIR"