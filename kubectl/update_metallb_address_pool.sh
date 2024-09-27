#!/bin/bash

# ============================================
# Script: update_metallb_ip_pool.sh
# Description: Periodically checks the current external IP address and updates
#              the specified MetalLB IPAddressPool resource in Kubernetes.
# ============================================

# Function to display usage
usage() {
  echo "Usage: INTERVAL_TIME=<seconds> POOL_NAME=<pool-name> POOL_NAMESPACE=<namespace> ./update_metallb_ip_pool.sh"
  echo "Example: INTERVAL_TIME=60 POOL_NAME=router-orange POOL_NAMESPACE=metallb ./update_metallb_ip_pool.sh"
  exit 1
}

# Check if required environment variables are set
if [[ -z "$INTERVAL_TIME" || -z "$POOL_NAME" || -z "$POOL_NAMESPACE" ]]; then
  echo "Error: One or more required environment variables are not set."
  usage
fi

# Function to get the current external IP
get_external_ip() {
  # Using ipify as the external IP service
  curl -s https://api.ipify.org || true
}

# Function to get the current IP from the IPAddressPool
get_pool_ip() {
  kubectl get IPAddressPool "$POOL_NAME" -n "$POOL_NAMESPACE" -o jsonpath='{.spec.addresses[0]}' 2>/dev/null
}

# Function to update the IPAddressPool with a new IP
update_pool_ip() {
  local new_ip="$1"
  
  # JSON Patch to replace the first address in the addresses list
  kubectl patch IPAddressPool "$POOL_NAME" -n "$POOL_NAMESPACE" --type=json -p="[
    {
      \"op\": \"replace\",
      \"path\": \"/spec/addresses/0\",
      \"value\": \"${new_ip}/32\"
    }
  ]"
}

# Function to handle script termination gracefully
cleanup() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]: Script terminated. Exiting."
  exit 0
}

# Trap termination signals to perform cleanup
trap cleanup SIGINT SIGTERM

echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]: Starting MetalLB IPAddressPool updater script."
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]: Checking every $INTERVAL_TIME seconds."
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]: IPAddressPool: $POOL_NAME"
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]: Namespace: $POOL_NAMESPACE"
echo "----------------------------------------"

# Infinite loop to perform the check and update at specified intervals
while true; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') [CHECK]: Starting IP check operation."

  # Fetch the current external IP
  CURRENT_IP=$(get_external_ip)
  
  if [[ -z "$CURRENT_IP" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR]: Failed to retrieve external IP. Retrying in $INTERVAL_TIME seconds."
    sleep "$INTERVAL_TIME"
    continue
  fi
  
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]: Current external IP is $CURRENT_IP"
  
  # Fetch the current IP from the IPAddressPool
  POOL_IP=$(get_pool_ip)
  
  if [[ -z "$POOL_IP" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR]: Failed to retrieve IP from IPAddressPool '$POOL_NAME' in namespace '$POOL_NAMESPACE'."
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR]: Ensure that the IPAddressPool exists and kubectl is configured correctly."
    sleep "$INTERVAL_TIME"
    continue
  fi
  
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]: Current IP in IPAddressPool '$POOL_NAME' is $POOL_IP"
  
  # Compare the external IP with the pool IP (ignoring the /32 suffix)
  if [[ "$POOL_IP" != "${CURRENT_IP}/32" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING]: IP mismatch detected."
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ACTION]: Updating IPAddressPool with new IP: $CURRENT_IP/32"
    
    # Attempt to update the IPAddressPool
    if update_pool_ip "$CURRENT_IP"; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS]: Successfully updated IPAddressPool '$POOL_NAME' with IP: $CURRENT_IP/32"
    else
      echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR]: Failed to update IPAddressPool '$POOL_NAME'."
    fi
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]: IPAddressPool '$POOL_NAME' is up-to-date. No action needed."
  fi
  
  echo "----------------------------------------"
  
  # Wait for the specified interval before the next check
  sleep "$INTERVAL_TIME"
done