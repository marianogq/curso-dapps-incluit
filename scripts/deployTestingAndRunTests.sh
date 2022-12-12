#! /bin/bash

# Exit when any command fails
set -e

NETWORK_NAME="testing"

echo "---------------COMPILE-------------------"
echo "truffle compile --network $NETWORK_NAME"
truffle compile --network $NETWORK_NAME

echo "---------------MIGRATE-------------------"
echo "truffle compile --network $NETWORK_NAME"
truffle migrate --network $NETWORK_NAME

echo "---------------TEST-------------------"
echo "truffle compile --network $NETWORK_NAME"
truffle test --network $NETWORK_NAME
