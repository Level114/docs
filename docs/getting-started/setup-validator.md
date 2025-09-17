# Validator Setup Guide<span class="terminal-cursor">:~$</span>

## Overview

Level114 validators monitor server performance by querying the **Level114 collector service** for metrics and setting weights on the Bittensor network. Validators earn rewards for maintaining network quality and ensuring fair evaluation of registered miners.

The collector service is operated by the Level114 team and provides API access for validators to query registered server data.

## Prerequisites

### System Requirements
- **OS**: Linux, macOS, or Windows
- **Python**: 3.8 or higher  
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: At least 10GB free space
- **Network**: Stable internet connection

### Bittensor Requirements
- **Bittensor Wallet**: Validator hotkey with sufficient TAO stake
- **Registration**: Hotkey must be registered as validator on subnet 114
- **Stake**: Minimum stake requirement for validator registration

### Level114 Collector Access
- **Validator API Key**: Must be obtained from Level114 team
- **Network Access**: Connection to Level114 collector service endpoints

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/level114/level114-subnet.git
cd level114-subnet
```

### 2. Install Dependencies

```bash
pip install -e .
```

### 3. Verify Bittensor Setup

```bash
# Check wallet
btcli wallet list

# Verify validator registration  
btcli subnet list --netuid 114

# Check your stake
btcli wallet overview --wallet.name your_wallet
```

## Configuration

### Environment Setup

```bash
cp config.env.example .env
nano .env
```

### Key Configuration

```bash
# Network Configuration
LEVEL114_NETUID=114
LEVEL114_NETWORK=finney

# Wallet Configuration
LEVEL114_WALLET_NAME=your_validator_wallet
LEVEL114_WALLET_HOTKEY=your_validator_hotkey

# Collector Configuration
LEVEL114_COLLECTOR_URL=http://collector-server:3000
LEVEL114_COLLECTOR_API_KEY=vk_live_your_validator_api_key

# Validation Configuration
LEVEL114_VALIDATOR_QUERY_TIMEOUT=12.0
LEVEL114_VALIDATOR_SAMPLE_SIZE=10
```

## Getting Validator API Key

Validator API keys must be obtained from the Level114 team. These keys provide authenticated access to the collector service for querying registered miners and their performance data.

### API Key Format
```
vk_live_1234567890abcdef...   # Production key
vk_dev_1234567890abcdef...    # Development key
```

## Running the Validator

### Using the Script

```bash
./scripts/run_validator.sh \
  --wallet.name your_validator_wallet \
  --wallet.hotkey your_validator_hotkey \
  --collector.api_key your_validator_api_key
```

### Direct Python Execution

```bash
python neurons/validator.py \
  --netuid 114 \
  --subtensor.network finney \
  --wallet.name your_validator_wallet \
  --wallet.hotkey your_validator_hotkey \
  --collector.url http://collector-server:3000 \
  --collector.api_key vk_live_your_api_key \
  --neuron.sample_size 10
```

### Command Line Options

**Network Options:**
- `--netuid`: Subnet network UID (default: 114)
- `--subtensor.network`: Bittensor network (finney/test/local)

**Wallet Options:**
- `--wallet.name`: Your validator wallet name
- `--wallet.hotkey`: Your validator hotkey

**Collector Options:**
- `--collector.url`: Collector service URL
- `--collector.api_key`: Your validator API key

**Validation Options:**
- `--neuron.sample_size`: Miners to query per cycle (default: 10)
- `--neuron.query_timeout`: Timeout for collector queries (default: 12.0)

## Validator Operation

### 1. Initialization
```bash
[INFO] Starting Level114 Validator
[INFO] Wallet: your_validator_wallet/your_validator_hotkey  
[INFO] Network: finney, NetUID: 114
[INFO] Collector: http://collector-server:3000
[INFO] Initializing collector API client...
```

### 2. Metagraph Sync
```bash
[INFO] Syncing metagraph...
[INFO] Found 47 registered miners
[INFO] Metagraph synced, block: 2847563
```

### 3. Validation Cycle
```bash
[INFO] Starting validation cycle...
[INFO] Querying collector for miner server IDs...
[INFO] Found 23 registered miners with servers
[INFO] Sampling 10 miners for validation...
[INFO] Querying server metrics...
```

### 4. Performance Evaluation
```bash
[INFO] Evaluating miner performance...
[INFO] Miner 12: Score 0.85 (uptime: 99.2%, reports: 145)
[INFO] Miner 34: Score 0.72 (uptime: 95.1%, reports: 89)
[INFO] Miner 45: Score 0.91 (uptime: 99.8%, reports: 203)
```

### 5. Weight Setting
```bash
[INFO] Setting weights on subnet...
[INFO] Weights set for 23 miners
[INFO] Next validation cycle in 60 seconds...
```

## Validation Logic

### Metric Collection
The validator queries the collector service for:

1. **Server Registration Data**: Which miners have registered servers
2. **Performance Reports**: Recent metrics submissions from servers
3. **Historical Data**: Trends in server performance over time

### Performance Scoring

Miners are evaluated based on:

**Server Availability (40%)**
- Registration status and validity
- API response consistency
- Long-term availability trends

**Metrics Quality (30%)**
- Frequency of metric submissions
- Data completeness and validity  
- Consistency over time

**Performance Indicators (30%)**
- Server uptime and stability
- Resource utilization efficiency
- Error rates and reliability

### Weight Calculation

```python
# Simplified scoring algorithm
def calculate_score(miner_data):
    availability_score = evaluate_availability(miner_data)
    metrics_score = evaluate_metrics_quality(miner_data)  
    performance_score = evaluate_performance(miner_data)
    
    final_score = (
        availability_score * 0.4 +
        metrics_score * 0.3 + 
        performance_score * 0.3
    )
    
    return min(max(final_score, 0.0), 1.0)
```

## Monitoring Your Validator

### Performance Metrics

Check validator performance:

```bash
# View recent logs
tail -f ~/.bittensor/logs/validators.log

# Check weight setting success
grep "Setting weights" ~/.bittensor/logs/validators.log

# Monitor query success rates
grep "collector" ~/.bittensor/logs/validators.log
```

### Validator Health

Key indicators of healthy operation:

- **Regular Weight Setting**: Weights updated every few minutes
- **Successful Queries**: Collector API calls succeeding
- **Miner Coverage**: Adequate sample of miners being evaluated
- **Network Sync**: Metagraph staying synchronized

### Troubleshooting Commands

```bash
# Test collector connectivity
curl -H "Authorization: Bearer vk_live_your_key" \
     http://collector-server:3000/validators/servers/ids?hotkeys=test

# Check Bittensor connectivity
btcli subnet metagraph --netuid 114

# Verify validator registration
btcli wallet overview --wallet.name your_validator_wallet
```

## Optimization Tips

### Maximize Validator Rewards

**Consistent Operation**
- Maintain 99%+ uptime for maximum weight setting frequency
- Ensure stable network connection to both Bittensor and collector
- Monitor and restart if validation cycles stop

**Accurate Assessment**
- Use appropriate sample sizes for network coverage
- Set reasonable query timeouts to balance speed and accuracy
- Keep validator software updated for latest evaluation algorithms

**Network Contribution**
- Provide feedback on miner performance trends
- Report any anomalies or potential gaming attempts
- Participate in governance discussions about evaluation criteria

### Resource Management

**Memory Usage**: Monitor memory consumption, especially with large sample sizes
**Network Bandwidth**: Collector queries can be bandwidth intensive
**Storage**: Log files can grow large over time, implement rotation

## Troubleshooting

### Common Issues

#### "Collector API authentication failed"
- Verify your API key is correct and has validator permissions
- Check API key format (should start with `vk_live_` or `vk_dev_`)
- Ensure API key hasn't expired or been revoked

#### "No miners found with servers"
- Wait for miners to register with collector service
- Check collector service is running and accessible
- Verify you're querying the correct collector endpoint

#### "Weight setting failed"
- Check your validator has sufficient stake
- Verify wallet credentials are correct
- Ensure network connectivity to Bittensor

#### "Timeout errors during validation"
- Increase `--neuron.query_timeout` value
- Reduce `--neuron.sample_size` if network is slow
- Check collector service performance and load

### Debug Mode

```bash
python neurons/validator.py \
  --logging.debug \
  --wallet.name your_validator_wallet \
  --wallet.hotkey your_validator_hotkey \
  --collector.api_key your_api_key
```

### Health Check Script

Create `validator_health.sh`:

```bash
#!/bin/bash
echo "=== Level114 Validator Health Check ==="
echo "Timestamp: $(date)"

# Check validator process
if pgrep -f "validator.py" > /dev/null; then
    echo "[OK] Validator process running"
else
    echo "[ERROR] Validator process not running"
fi

# Check collector connectivity
if curl -s -H "Authorization: Bearer $API_KEY" \
        http://collector-server:3000/health > /dev/null; then
    echo "[OK] Collector service accessible"
else
    echo "[ERROR] Collector service unreachable"
fi

# Check recent weight settings
recent_weights=$(tail -100 ~/.bittensor/logs/validators.log | grep -c "Setting weights")
echo "[INFO] Recent weight settings: $recent_weights"
```

---

**Your validator is now contributing to the Level114 network by ensuring fair evaluation of server infrastructure and maintaining network quality standards.**