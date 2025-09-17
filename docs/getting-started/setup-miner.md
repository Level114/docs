# Miner Setup Guide<span class="terminal-cursor">:~$</span>

## Overview

Running a Level114 miner means operating a **Minecraft server** and registering it with the **Level114 collector service**. The miner performs a **one-time registration** and saves credentials that you'll use to configure the Level114 monitoring plugin on your Minecraft server.

**Important**: You must have a running Minecraft server (Bukkit/Paper) to participate as a Level114 miner. The credentials from registration are used to configure the monitoring plugin, not the miner itself.

The collector service is operated by the Level114 team at `http://collector.level114.io` - you don't need to deploy or manage it yourself.

## Prerequisites

### System Requirements
- **OS**: Linux, macOS, or Windows
- **Python**: 3.8+ for miner registration
- **Java**: 21+ for Minecraft server
- **RAM**: Minimum 4GB, recommended 8GB+ (for Minecraft server)
- **Storage**: 20GB+ free space for Minecraft server and world data
- **Bittensor Wallet**: Hotkey registered on subnet 114

### Minecraft Server Requirements
- **Server Software**: Bukkit or Paper 1.20+ (required)
- **Public Access**: Server must be publicly accessible for validation
- **Port 25565**: Minecraft server port should be open and accessible

### Network Requirements
- **Public IP**: Your server must have a publicly accessible IP address  
- **Minecraft Port**: Port 25565 open for Minecraft server access
- **Internet**: Stable connection to Bittensor network and `http://collector.level114.io`

## Setting Up Your Minecraft Server

**Important**: You must have a running Minecraft server before registering as a miner.

### 1. Download Minecraft Server Software

**Option A: Paper (Recommended)**
```bash
# Create Minecraft server directory
mkdir minecraft-server
cd minecraft-server

# Download Paper 1.20.6
wget https://api.papermc.io/v2/projects/paper/versions/1.20.6/builds/147/downloads/paper-1.20.6-147.jar
```

**Option B: Bukkit/Spigot**
```bash
# Download from official sources or use BuildTools
# Follow official Spigot build instructions at https://www.spigotmc.org/wiki/buildtools/
```

### 2. Configure and Start Your Server

```bash
# Create start script
echo 'java -Xmx4G -Xms4G -jar paper-*.jar --nogui' > start.sh
chmod +x start.sh

# First run (will generate files and stop)
./start.sh

# Accept EULA
echo "eula=true" > eula.txt

# Configure server.properties for public access
echo "server-port=25565" >> server.properties  
echo "server-ip=" >> server.properties  # Leave empty for all interfaces
echo "online-mode=true" >> server.properties
echo "max-players=20" >> server.properties

# Start server
./start.sh
```

### 3. Verify Server Accessibility

Ensure your server is publicly accessible:
```bash
# Test from another machine or online service
# Your server should be reachable at your-public-ip:25565
```

**Note**: Keep your Minecraft server running - it must be active for Level114 validation.

## Miner Registration Installation

### 1. Clone the Repository

```bash
git clone https://github.com/level114/level114-subnet.git
cd level114-subnet
```

### 2. Install Dependencies

```bash
# Install Python dependencies
pip install -e .

# Or using requirements if available
pip install -r requirements.txt
```

### 3. Verify Bittensor Wallet

Ensure you have a Bittensor wallet with a hotkey registered on subnet 114:

```bash
# Check your wallets
btcli wallet list

# Check if registered on subnet (replace with your wallet details)
btcli subnet list --netuid 114
```

## Configuration

### Environment Setup

Create a configuration file or set environment variables:

```bash
# Copy example config
cp config.env.example .env

# Edit with your values
nano .env
```

### Key Configuration Options

```bash
# Network Configuration  
LEVEL114_NETUID=114
LEVEL114_NETWORK=finney

# Wallet Configuration
LEVEL114_WALLET_NAME=your_wallet_name
LEVEL114_WALLET_HOTKEY=your_hotkey_name

# Collector Configuration  
LEVEL114_COLLECTOR_URL=http://collector.level114.io
```

## Running the Miner

### Using the Convenience Script

```bash
./scripts/run_miner.sh \
  --collector_url http://collector.level114.io \
  --wallet.name your_wallet \
  --wallet.hotkey your_hotkey
```

### Direct Python Execution

```bash
python neurons/miner.py \
  --netuid 114 \
  --subtensor.network finney \
  --wallet.name your_wallet \
  --wallet.hotkey your_hotkey \
  --collector_url http://collector.level114.io
```

### Command Line Options

- `--collector_url`: URL of the collector service (use http://collector.level114.io)
- `--wallet.name`: Your Bittensor wallet name (required)
- `--wallet.hotkey`: Your Bittensor hotkey (required)  
- `--minecraft_ip`: Your server's public IP (auto-detected if not provided)
- `--minecraft_port`: Minecraft server port (default: 25565)
- `--netuid`: Subnet network UID (default: 114)
- `--subtensor.network`: Bittensor network (finney/test/local)

## What Happens During Registration

### 1. IP Detection
```bash
[INFO] Detecting public IP address...
[INFO] Public IP detected: 203.0.113.42
```

### 2. Signature Generation
```bash
[INFO] Creating registration signature for hotkey...
[INFO] Message: register:203.0.113.42:8091
[INFO] Signature: 0x1234567890abcdef...
```

### 3. Registration Request
```bash
[INFO] Registering with collector service...
[INFO] Collector URL: http://collector.level114.io
[INFO] Submitting registration request...
```

### 4. Credential Storage
```bash
[INFO] Registration successful!
[INFO] Server ID: 550e8400-e29b-41d4-a716-446655440000
[INFO] Saving credentials to: credentials/minecraft_server_wallet_hotkey_ip.json
[INFO] Registration complete. Miner exiting.
```

## Saved Credentials

After successful registration, credentials are saved to local files:

### File Locations
- **JSON Format**: `credentials/minecraft_server_[wallet]_[hotkey]_[ip].json`
- **Text Format**: `credentials/minecraft_server_[wallet]_[hotkey]_[ip].txt`

### Credential Contents
```json
{
  "server_id": "550e8400-e29b-41d4-a716-446655440000",
  "api_token": "sk_live_abcdef123456789...",
  "key_id": "a1b2c3d4e5f6",
  "server_details": {
    "ip": "203.0.113.42",
    "port": 8091,
    "wallet_name": "your_wallet",
    "hotkey": "your_hotkey",
    "hotkey_address": "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"
  },
  "registration_time": "2024-01-15T10:30:00Z"
}
```

### Security Important
⚠️ **Keep these files secure!** They contain:
- **Server ID**: Unique identifier in the collector database
- **API Token**: Authentication token for collector API access
- **Key ID**: Cryptographic key identifier

The `credentials/` directory is automatically excluded from git commits.

## Using Credentials with Level114 Monitoring Plugin

**Important**: The credentials from miner registration are used to configure the Level114 monitoring plugin on your Minecraft server, NOT the miner itself.

### 1. Install the Level114 Monitoring Plugin

Download the plugin from the subnet repository:
```bash
# Download from subnet/plugins/monitor-plugin/
# Place the JAR file in your Minecraft server's plugins/ directory
cp subnet/plugins/monitor-plugin/miner-monitor-*.jar /path/to/minecraft-server/plugins/
```

### 2. Configure the Plugin with Your Credentials

After installing the plugin and restarting your Minecraft server, edit the generated config file:

```bash
# Edit the plugin configuration
nano /path/to/minecraft-server/plugins/Level114/config.yml
```

Add your registration credentials to the config:
```yaml
# Level114 Plugin Configuration
url: "http://collector.level114.io"
serverId: "550e8400-e29b-41d4-a716-446655440000"  # From your credentials
serverApiKey: "sk_live_abcdef123456789..."        # From your credentials  
sendReportPeriodTicks: 1200  # Report every 60 seconds
```

### 3. Restart Your Minecraft Server

After configuring the plugin, restart your Minecraft server:
```bash
# In your minecraft server directory
./start.sh
```

The plugin will automatically start reporting server metrics to the Level114 collector service.

## Verification

### Check Registration Status
You can verify your registration was successful by checking the collector service:

```bash
# Check if your server appears in the public listing  
curl http://collector.level114.io/servers

# Look for your server ID in the response
```

### Credential File Verification
```bash
# Check that credential files were created
ls -la credentials/

# Verify file contents (be careful not to expose sensitive data)
head -5 credentials/minecraft_server_*_*.txt
```

## Troubleshooting

### Common Issues

#### "Unable to detect public IP"
```bash
# Manually specify your public IP
python neurons/miner.py --miner.external_ip YOUR_PUBLIC_IP
```

#### "Wallet not found"
```bash
# Verify wallet exists
btcli wallet list

# Check wallet path
ls -la ~/.bittensor/wallets/
```

#### "Collector service unreachable"
```bash
# Test collector connectivity
curl http://collector-server:3000/health

# Check network connectivity  
ping collector-server
telnet collector-server 3000
```

#### "Hotkey not registered on subnet"
```bash
# Register your hotkey on subnet 114
btcli subnet register \
  --netuid 114 \
  --wallet.name your_wallet \
  --wallet.hotkey your_hotkey
```

#### "Signature verification failed"
- Ensure you're using the correct wallet and hotkey names
- Verify the wallet files are not corrupted
- Check that your hotkey is properly registered on the subnet

### Debug Mode

Enable debug logging for detailed information:

```bash
python neurons/miner.py \
  --logging.debug \
  --wallet.name your_wallet \
  --wallet.hotkey your_hotkey \
  --collector_url http://collector-server:3000
```

### File Permissions

If you encounter permission issues:

```bash
# Fix credential directory permissions
chmod 755 credentials/
chmod 600 credentials/*

# Fix wallet permissions
chmod 700 ~/.bittensor/wallets/
chmod 600 ~/.bittensor/wallets/*/*
```

## Post-Registration

### What's Next?
After successful registration:

1. **Your miner exits** - This is normal behavior
2. **Credentials are saved** - Keep them secure for future use
3. **Validators can find you** - Your server is now discoverable  
4. **Earn rewards** - Based on your server's evaluated performance

### Optional Metric Reporting
While the subnet miner only registers and exits, you can optionally implement metric reporting using the saved API credentials to enhance your performance evaluation.

### Monitoring Your Performance
- Watch for your server in validator queries
- Monitor your weight allocation in the subnet
- Track your reward earnings over time

---

**Congratulations!** Your server is now registered with the Level114 subnet and ready to participate in the decentralized infrastructure validation network.
