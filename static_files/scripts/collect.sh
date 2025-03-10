#!/usr/bin/env bash

set -euo pipefail

export ETH_RPC_URL="$L1_RPC_URL"

addr=$(cast wallet address "$FUND_PRIVATE_KEY")

deployer_addr=$(cast wallet address "$DEPLOYER_PRIVATE_KEY")

roles=("l2ProxyAdmin" "l1ProxyAdmin" "baseFeeVaultRecipient" "l1FeeVaultRecipient" "sequencerFeeVaultRecipient" "systemConfigOwner")
funded_roles=("proposer" "batcher" "sequencer" "challenger")

IFS=',';read -r -a chain_ids <<< "$1"

write_keyfile() {
  echo "{\"address\":\"$1\",\"privateKey\":\"$2\"}" > "/network-data/$3.json"
}

# Create a JSON object to store all the wallet addresses and private keys, start with an empty one
wallets_json=$(jq -n '{}')
for chain_id in "${chain_ids[@]}"; do
  chain_wallets=$(jq -n '{}')

  for index in "${!funded_roles[@]}"; do
    role="${funded_roles[$index]}"
    role_idx=$((index+1))

    echo "Setting up $role role for chain $chain_id"

    # Dynamically extract role-specific private key and signer address
    
    address=""
    private_key=""
    
    role_private_key=$(echo "$SIGNER_INFORMATION" | jq -r --arg role "$role" '.[$role].private_key // empty' | xargs)
    role_signer_address=$(echo "$SIGNER_INFORMATION" | jq -r --arg role "$role" '.[$role].signer_address // empty' | xargs)
    
    if [ -n "$role_private_key" ]; then
      # Use the private key from SIGNER_INFORMATION and derive the address
      private_key="$role_private_key"
      address=$(cast wallet address "$private_key")
    else
      # Use the signer address from SIGNER_INFORMATION and spoof the private key for now
      # TODO: allow signer information to be used. For now we will 
        echo "not implemented"
    fi

    write_keyfile "${address}" "${private_key}" "${role}-$chain_id"

    chain_wallets=$(echo "$chain_wallets" | jq \
      --arg role "$role" \
      --arg private_key "$private_key" \
      --arg address "$address" \
      '.[$role + "PrivateKey"] = $private_key | .[$role + "Address"] = $address')
  done

  for index in "${!roles[@]}"; do
    role="${roles[$index]}"

    write_keyfile "${deployer_addr}" "${DEPLOYER_PRIVATE_KEY}" "${role}-$chain_id"

    chain_wallets=$(echo "$chain_wallets" | jq \
      --arg role "$role" \
      --arg private_key "$DEPLOYER_PRIVATE_KEY" \
      --arg address "$deployer_addr" \
      '.[$role + "PrivateKey"] = $private_key | .[$role + "Address"] = $address')
  done

  chain_wallets=$(echo "$chain_wallets" | jq \
    --arg addr "0xafF0CA253b97e54440965855cec0A8a2E2399896" \
    --arg private_key "0x04b9f63ecf84210c5366c66d68fa1f5da1fa4f634fad6dfc86178e4d79ff9e59" \
    '.["l1FaucetPrivateKey"] = $private_key | .["l1FaucetAddress"] = $addr')

  chain_wallets=$(echo "$chain_wallets" | jq \
    --arg addr "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" \
    --arg private_key "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" \
    '.["l2FaucetPrivateKey"] = $private_key | .["l2FaucetAddress"] = $addr')
    
  # Add this chain's wallet information to the main JSON object
  wallets_json=$(echo "$wallets_json" | jq \
    --arg chain_id "$chain_id" \
    --argjson chain_wallets "$chain_wallets" \
    '.[$chain_id] = $chain_wallets')
done

echo "Wallet private key and addresses"
echo "$wallets_json" > "/network-data/wallets.json"
echo "$wallets_json"

wait