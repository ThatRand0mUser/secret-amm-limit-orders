#!/bin/bash

cd ./contracts/factory

echo Build new contracts to deploy? [yn]
read toBuild

function wait_for_tx() {
  until (secretcli q tx "$1"); do
      sleep 5
  done
}

if [ "$toBuild" != "${toBuild#[Yy]}" ] ;then
    #cargo clean
    RUST_BACKTRACE=1 cargo unit-test
    rm -f ./contract.wasm ./contract.wasm.gz
    cargo wasm
    cargo schema
    docker run --rm -v $PWD:/contract \
        --mount type=volume,source=factory_cache,target=/code/target \
        --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
        enigmampc/secret-contract-optimizer
fi

secretcli q account $(secretcli keys show -a a)

deployed=$(secretcli tx compute store "contract.wasm.gz" --from a --gas 2000000 -b block -y)
factory_code_id=$(secretcli query compute list-code | jq '.[-1]."id"')
factory_code_hash=$(secretcli query compute list-code | jq '.[-1]."data_hash"')
echo "Stored contract: '$factory_code_id', '$factory_code_hash'"

label=$(date +"%T")
deployer_name_a=a

STORE_TX_HASH=$( 
  secretcli tx compute instantiate $factory_code_id '{"entropy": "'$RANDOM'", "secret_order_book_code_id": 1, "secret_order_book_code_hash": "aa", "amm_factory_contract_address": "secret1ypfxpp4ev2sd9vj9ygmsmfxul25xt9cfadrxxy", "amm_factory_contract_hash": "0xb66c6aca95004916baa13f8913ff1222c3e1775aaaf60f011cfaba7296d59d2c"}' --from $deployer_name_a --gas 1500000 --label Secret_Order_Book_Factory_$label -b block -y |
  jq -r .txhash
)
wait_for_tx "$STORE_TX_HASH" "Waiting for instantiate to finish on-chain..."

factory_contract_address=$(secretcli query compute list-contract-by-code $factory_code_id | jq '.[-1].address')
echo "factory_contract_address: '$factory_contract_address'"