# Key Generation Guide

This document provides comprehensive guidance for generating, managing, and securing cryptographic keys for the Bittensor Minecraft subnet.

## Overview

The subnet uses Bittensor's key management system with additional subnet-specific key requirements:

- **Coldkey**: Long-term storage key (offline security)
- **Hotkey**: Active network participation key (online operations)  
- **Server Keys**: Additional keys for server authentication and replay validation

## Prerequisites

Before generating keys, ensure you have:

```bash
# Install Bittensor CLI
pip install bittensor

# Verify installation
btcli --version

# Check available commands
btcli --help
```

## Production Key Generation

### Step 1: Generate Coldkey (Offline)

The coldkey should be generated on an air-gapped machine for maximum security.

```bash
# Generate new coldkey
btcli wallet create --wallet.name production-wallet

# Verify coldkey creation
btcli wallet list

# Backup the mnemonic (CRITICAL!)
# Store in secure, offline location
# Consider multiple physical backups
```

**⚠️ CRITICAL: Backup your mnemonic phrase immediately and store in multiple secure, offline locations.**

### Step 2: Generate Hotkey

```bash
# Generate hotkey for your coldkey
btcli wallet create --wallet.name production-wallet --wallet.hotkey production-hotkey

# For multiple hotkeys (different miners/validators):
btcli wallet create --wallet.name production-wallet --wallet.hotkey miner-1
btcli wallet create --wallet.name production-wallet --wallet.hotkey miner-2
btcli wallet create --wallet.name production-wallet --wallet.hotkey validator-1
```

### Step 3: Verify Key Generation

```bash
# Check all wallets
btcli wallet list

# Check specific wallet details
btcli wallet overview --wallet.name production-wallet

# Verify key files exist
ls ~/.bittensor/wallets/production-wallet/
# Should show: coldkey  coldkeypub  hotkeys/
```

## Development Key Generation

For development and testing purposes:

```bash
# Quick development wallet creation
btcli wallet create --wallet.name dev-wallet --wallet.hotkey dev-hotkey --no_prompt --overwrite_coldkey --overwrite_hotkey

# Multiple development miners
for i in {1..3}; do
    btcli wallet create --wallet.name "dev-miner-$i" --wallet.hotkey "miner-$i" --no_prompt --overwrite_coldkey --overwrite_hotkey
done

# Multiple development validators  
for i in {1..2}; do
    btcli wallet create --wallet.name "dev-validator-$i" --wallet.hotkey "validator-$i" --no_prompt --overwrite_coldkey --overwrite_hotkey
done
```

## Key Import/Recovery

### Recovering from Mnemonic

```bash
# Recover coldkey from mnemonic
btcli wallet regen_coldkey --wallet.name recovered-wallet
# You'll be prompted to enter your mnemonic phrase

# Recover hotkey from mnemonic (if backed up separately)
btcli wallet regen_hotkey --wallet.name recovered-wallet --wallet.hotkey recovered-hotkey
```

### Importing Existing Keys

```bash
# Import coldkey from file
btcli wallet regen_coldkey --wallet.name imported-wallet --use_password

# Import hotkey from file
btcli wallet regen_hotkey --wallet.name imported-wallet --wallet.hotkey imported-hotkey --use_password
```

## Key Security Best Practices

### 1. Coldkey Security (Critical)

```bash
# Generate coldkey on air-gapped machine
# Never expose coldkey to internet-connected systems

# Backup mnemonic to multiple secure locations:
# - Hardware security module (HSM)
# - Encrypted paper backup in safe deposit box
# - Distributed secret sharing (Shamir's Secret Sharing)

# Test recovery process with small amount first
```

### 2. Hotkey Security (Important)

```bash
# Use separate hotkeys for different operations
btcli wallet create --wallet.name main-wallet --wallet.hotkey miner-operations
btcli wallet create --wallet.name main-wallet --wallet.hotkey validator-operations

# Regularly rotate hotkeys
btcli wallet regen_hotkey --wallet.name main-wallet --wallet.hotkey new-hotkey

# Monitor hotkey usage
btcli wallet overview --wallet.name main-wallet --wallet.hotkey miner-operations
```

### 3. File System Security

```bash
# Set proper permissions on wallet files
chmod 600 ~/.bittensor/wallets/*/coldkey
chmod 600 ~/.bittensor/wallets/*/hotkeys/*

# Encrypt wallet directory
# Use disk encryption (LUKS, BitLocker, FileVault)

# Regular backups to secure storage
rsync -av --exclude='*.tmp' ~/.bittensor/wallets/ /secure/backup/location/
```

## Subnet Registration

### Register Miner

```bash
# Check subnet information
btcli subnet list --subtensor.network finney

# Register miner hotkey to subnet
btcli subnet register \
    --wallet.name your-wallet \
    --wallet.hotkey your-miner-hotkey \
    --subtensor.network finney \
    --netuid YOUR_SUBNET_ID

# Verify registration
btcli wallet overview --wallet.name your-wallet --wallet.hotkey your-miner-hotkey
```

### Register Validator

```bash
# Register validator hotkey
btcli subnet register \
    --wallet.name your-wallet \
    --wallet.hotkey your-validator-hotkey \
    --subtensor.network finney \
    --netuid YOUR_SUBNET_ID

# Add stake to validator (if required)
btcli stake add \
    --wallet.name your-wallet \
    --wallet.hotkey your-validator-hotkey \
    --amount 100

# Verify registration and stake
btcli wallet overview --wallet.name your-wallet --wallet.hotkey your-validator-hotkey
```

## Key Rotation Procedures

### Planned Hotkey Rotation

```bash
# Generate new hotkey
btcli wallet create --wallet.name your-wallet --wallet.hotkey new-hotkey

# Register new hotkey to subnet
btcli subnet register \
    --wallet.name your-wallet \
    --wallet.hotkey new-hotkey \
    --subtensor.network finney \
    --netuid YOUR_SUBNET_ID

# Update your miner/validator configuration to use new hotkey
# Test operation with new hotkey

# Deregister old hotkey (after successful migration)
# Transfer any remaining stake
btcli stake remove \
    --wallet.name your-wallet \
    --wallet.hotkey old-hotkey \
    --amount ALL
```

### Emergency Key Recovery

If you suspect key compromise:

```bash
# 1. Immediately generate new hotkey
btcli wallet create --wallet.name your-wallet --wallet.hotkey emergency-hotkey

# 2. Register new hotkey
btcli subnet register \
    --wallet.name your-wallet \
    --wallet.hotkey emergency-hotkey \
    --subtensor.network finney \
    --netuid YOUR_SUBNET_ID

# 3. Transfer stake from compromised hotkey
btcli stake remove \
    --wallet.name your-wallet \
    --wallet.hotkey compromised-hotkey \
    --amount ALL

btcli stake add \
    --wallet.name your-wallet \
    --wallet.hotkey emergency-hotkey \
    --amount TRANSFERRED_AMOUNT

# 4. Update all services to use new hotkey
# 5. Monitor for any unauthorized activity
```

## Key Management Scripts

### Automated Key Generation Script

```bash
#!/bin/bash
# generate_subnet_keys.sh

WALLET_NAME="${1:-subnet-wallet}"
KEY_COUNT="${2:-1}"

echo "Generating keys for $WALLET_NAME..."

# Generate coldkey
btcli wallet create --wallet.name "$WALLET_NAME"

# Generate multiple hotkeys
for i in $(seq 1 $KEY_COUNT); do
    btcli wallet create \
        --wallet.name "$WALLET_NAME" \
        --wallet.hotkey "hotkey-$i"
done

# Display overview
btcli wallet overview --wallet.name "$WALLET_NAME"

echo "Keys generated successfully!"
echo "IMPORTANT: Backup your mnemonic phrase now!"
```

### Key Backup Script

```bash
#!/bin/bash
# backup_keys.sh

WALLET_NAME="$1"
BACKUP_DIR="$2"

if [[ -z "$WALLET_NAME" || -z "$BACKUP_DIR" ]]; then
    echo "Usage: $0 <wallet_name> <backup_directory>"
    exit 1
fi

echo "Backing up wallet: $WALLET_NAME"

# Create backup directory
mkdir -p "$BACKUP_DIR/$WALLET_NAME"

# Copy wallet files (excluding sensitive coldkey)
cp -r ~/.bittensor/wallets/"$WALLET_NAME"/hotkeys "$BACKUP_DIR/$WALLET_NAME/"
cp ~/.bittensor/wallets/"$WALLET_NAME"/coldkeypub "$BACKUP_DIR/$WALLET_NAME/"

# Create metadata
cat > "$BACKUP_DIR/$WALLET_NAME/backup_info.txt" << EOF
Wallet Name: $WALLET_NAME
Backup Date: $(date)
Backup Contains: hotkeys, coldkeypub
WARNING: Coldkey NOT included for security
Restore coldkey from mnemonic phrase
EOF

echo "Backup completed: $BACKUP_DIR/$WALLET_NAME"
echo "IMPORTANT: Coldkey not included - ensure mnemonic is backed up separately!"
```

### Key Health Check Script

```bash
#!/bin/bash
# check_key_health.sh

WALLET_NAME="$1"

if [[ -z "$WALLET_NAME" ]]; then
    echo "Usage: $0 <wallet_name>"
    exit 1
fi

echo "=== Key Health Check: $WALLET_NAME ==="

# Check file existence
echo "Checking file existence..."
WALLET_DIR="$HOME/.bittensor/wallets/$WALLET_NAME"

if [[ -f "$WALLET_DIR/coldkey" ]]; then
    echo "✓ Coldkey exists"
else
    echo "✗ Coldkey missing"
fi

if [[ -f "$WALLET_DIR/coldkeypub" ]]; then
    echo "✓ Coldkey public key exists"  
else
    echo "✗ Coldkey public key missing"
fi

# Check hotkeys
echo -e "\nHotkeys:"
if [[ -d "$WALLET_DIR/hotkeys" ]]; then
    for hotkey in "$WALLET_DIR/hotkeys"/*; do
        if [[ -f "$hotkey" ]]; then
            echo "✓ $(basename "$hotkey")"
        fi
    done
else
    echo "✗ No hotkeys directory"
fi

# Check permissions
echo -e "\nFile permissions:"
find "$WALLET_DIR" -type f -exec ls -la {} \;

# Check network registration
echo -e "\nNetwork registration status:"
btcli wallet overview --wallet.name "$WALLET_NAME" 2>/dev/null || echo "Unable to check registration"

echo -e "\n=== Health Check Complete ==="
```

## Troubleshooting

### Common Key Issues

**Issue: "Wallet not found"**
```bash
# Check wallet exists
btcli wallet list

# Verify wallet path
ls ~/.bittensor/wallets/

# Check file permissions
ls -la ~/.bittensor/wallets/your-wallet/
```

**Issue: "Invalid mnemonic"**
```bash
# Ensure mnemonic is exactly as recorded
# Check for extra spaces or characters
# Verify mnemonic word count (usually 12 or 24 words)

# Test with small recovery first
btcli wallet create --wallet.name test-recovery
btcli wallet regen_coldkey --wallet.name test-recovery
```

**Issue: "Registration failed"**
```bash
# Check balance for registration fee
btcli wallet balance --wallet.name your-wallet

# Verify subnet ID
btcli subnet list --subtensor.network finney

# Check network connectivity
btcli subnet hyperparameters --subtensor.network finney --netuid YOUR_SUBNET_ID
```

## Security Incident Response

If you suspect key compromise:

1. **Immediate Response**
   - Generate new hotkeys immediately
   - Transfer stake to new hotkeys
   - Update all service configurations
   - Monitor for unauthorized transactions

2. **Investigation**
   - Review access logs
   - Check for unauthorized service usage
   - Analyze network activity
   - Document timeline of events

3. **Recovery**
   - Implement new key rotation schedule
   - Update security procedures
   - Consider coldkey rotation if compromise suspected
   - Review and update access controls

## Best Practices Summary

✅ **DO:**
- Generate coldkeys on air-gapped machines
- Backup mnemonics to multiple secure locations
- Use separate hotkeys for different operations
- Regularly rotate hotkeys
- Monitor wallet activity
- Use proper file permissions
- Test recovery procedures

❌ **DON'T:**
- Share mnemonic phrases
- Store keys in cloud storage unencrypted
- Use the same hotkey for multiple purposes
- Ignore suspicious wallet activity
- Skip backup verification
- Use weak passwords for key encryption

## Support

For additional help with key management:

- **Documentation**: [Full key management guide](../06-api/auth-and-keys.md)
- **Community**: [Discord support channel](https://discord.gg/your-server)
- **Issues**: [GitHub repository](https://github.com/your-org/minecraft-subnet/issues)
