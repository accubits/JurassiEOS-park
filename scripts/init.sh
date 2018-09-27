#!/usr/bin/env bash
set -o errexit

echo "=== start of first time setup ==="

# change to script's directory
cd "$(dirname "$0")"

# make sure Docker and Node.js is installed
if [ ! -x "$(command -v docker)" ] ||
   [ ! -x "$(command -v npm)" ]; then
    echo ""
    echo -e "\033[0;31m[Error with Exception]\033[0m"
    echo "Please make sure Docker and Node.js are installed"
    echo ""
    echo "Install Docker: https://docs.docker.com/docker-for-mac/install/"
    echo "Install Node.js: https://nodejs.org/en/"
    echo ""
    exit
fi

# download eosio/eos-dev:v1.2.5 image
echo "=== pull eosio/eos-dev image v1.2.5 from docker hub ==="
docker pull eosio/eos-dev:v1.2.5

# create a clean data folder in eosio_docker to preserve block data
echo "=== setup/reset data for eosio_docker ==="
#docker stop eosio_notechain_container || true && docker rm --force eosio_notechain_container || true
rm -rf "./eosio_docker/data"
mkdir -p "./eosio_docker/data"

sleep 2s

cd "$(dirname "$0")/eosio_docker"

if [ -e "data/initialized" ]
then
    script="./scripts/existingBlockchain.sh"
else
    script="./scripts/newBlockchain.sh"
fi

echo "=== run docker container from the eosio/eos-dev image ==="
docker run --rm --name eosio_notechain_container -d \
-p 8888:8888 -p 9876:9876 \
--mount type=bind,src="$(pwd)"/contracts,dst=/opt/eosio/bin/contracts \
--mount type=bind,src="$(pwd)"/scripts,dst=/opt/eosio/bin/scripts \
--mount type=bind,src="$(pwd)"/data,dst=/mnt/dev/data \
-w "/opt/eosio/bin/" eosio/eos-dev:v1.2.5 /bin/bash -c "$script"
