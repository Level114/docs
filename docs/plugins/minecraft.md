# Level114 Minecraft Plugin<span class="terminal-cursor">:~$</span>

The Level114 Minecraft Plugin is a comprehensive monitoring and reporting plugin for Bukkit/Paper Minecraft servers. It collects detailed server performance metrics and reports them to the Level114 collector service, enabling miners to earn rewards based on their server's quality and performance.

## Overview

**Plugin Name**: Level114  
**Version**: 0.1.1  
**Compatibility**: Bukkit/Paper 1.20+  
**Java Version**: 21+  
**Build System**: Gradle 8.8  

## Features

### Comprehensive Metric Collection

- **Player Statistics**: Active players, maximum capacity, player UUIDs and names
- **Server Performance**: TPS (Ticks Per Second), uptime, plugin list
- **System Resources**: CPU model/cores/threads, RAM usage (both JVM and system), OS details
- **Real-time Monitoring**: Configurable reporting intervals with automatic retries

### Secure Reporting

- **Authenticated API**: Uses server ID and API key for secure communication
- **Cryptographic Security**: Reports are hashed and signed for integrity
- **Nonce Protection**: Time-limited nonces prevent replay attacks
- **Retry Logic**: Automatic retry with exponential backoff for failed requests

### Administrative Tools

- **Status Command**: `/level114 status` provides comprehensive server status
- **Real-time Monitoring**: View active reporting status and server health
- **Configuration Validation**: Automatic validation of server credentials

## Installation

### Prerequisites

1. **Minecraft Server**: Bukkit or Paper 1.20+
2. **Java Runtime**: Java 21 or higher
3. **Level114 Registration**: Server must be registered with Level114 collector service

### Download & Installation

1. Download the latest plugin JAR from the `subnet/plugins/monitor-plugin/` directory
2. Place the JAR file in your server's `plugins/` directory
3. Start your Minecraft server to generate the default configuration
4. Configure the plugin with your server credentials
5. Restart the server to begin reporting

## Configuration

The plugin configuration is stored in `plugins/Level114/config.yml`:

```yaml
# Level114 Collector Service URL
url: "http://collector.level114.io"

# Your unique server ID (obtained during registration)
serverId: ""

# Your server API key (obtained during registration)  
serverApiKey: ""

# Reporting interval in ticks (1200 = 60 seconds)
sendReportPeriodTicks: 1200
```

### Configuration Options

| Setting | Description | Default | Required |
|---------|-------------|---------|----------|
| `url` | Level114 collector service endpoint | `http://collector.level114.io` | Yes |
| `serverId` | UUID of your registered server | None | Yes |
| `serverApiKey` | Authentication token for your server | None | Yes |
| `sendReportPeriodTicks` | Report frequency in Minecraft ticks | `1200` (60s) | Yes |

### Obtaining Credentials

To get your `serverId` and `serverApiKey`:

1. Register your server with the Level114 miner setup process
2. Run the miner registration as described in [Miner Setup Guide](../getting-started/setup-miner.md)
3. Copy the credentials from your saved registration files
4. Add them to the plugin configuration

## Collected Metrics

### Player Data
```json
{
  "activePlayers": [
    {
      "name": "PlayerName",
      "uuid": "player-uuid-here"
    }
  ],
  "maxPlayers": 20
}
```

### Server Performance
```json
{
  "tpsMillis": 20000,
  "uptimeMs": 3600000,
  "plugins": ["PluginName1", "PluginName2"]
}
```

### System Information
```json
{
  "systemInfo": {
    "cpuModel": "Intel(R) Core(TM) i7-9700K CPU @ 3.60GHz",
    "cpuCores": 8,
    "cpuThreads": 8,
    "javaVersion": "21.0.1",
    "osName": "Linux",
    "osVersion": "6.8.0-79-generic",
    "osArch": "amd64",
    "memoryRamInfo": {
      "totalMemoryBytes": 34359738368,
      "usedMemoryBytes": 16106127360,
      "freeMemoryBytes": 18253611008
    }
  }
}
```

### Memory Usage
```json
{
  "memoryRamInfo": {
    "totalMemoryBytes": 2147483648,
    "usedMemoryBytes": 1073741824,
    "freeMemoryBytes": 1073741824
  }
}
```

## Commands & Permissions

### Commands

| Command | Description | Permission |
|---------|-------------|------------|
| `/level114 status` | Display plugin status and server information | `level114.admin` |

### Permissions

| Permission | Default | Description |
|------------|---------|-------------|
| `level114.admin` | `op` | Access to Level114 commands |

## Status Command Output

The `/level114 status` command provides a comprehensive overview:

```
Level114 Miner Monitor
■ URL: https://collector.level114.io
■ Status: Active
■ Host: your-server.com:25565
■ Hotkey: 5GrwvaEF...5fQUhxDQ
■ Last Counter: 1234
■ Registered: Wed, Oct 15 2024 14:30:22 UTC
■ Period: 1200 ticks
```

### Status Indicators

- **Active**: Server is successfully reporting to collector
- **Disabled**: Server has been disabled in collector
- **Revoked**: Server credentials have been revoked
- **Not Initialized**: Plugin configuration is incomplete

## Troubleshooting

### Common Issues

**Plugin Won't Start**
```
serverId is not set in the config. Please set it and restart the server.
```
**Solution**: Add your `serverId` to the configuration file

**Authentication Failed**
```
Failed to get server: body={"error":"unauthorized"}
```
**Solution**: Verify your `serverApiKey` is correct and valid

**Server Not Found**
```
Server not found. Please check the serverId and serverApiKey
```
**Solution**: Confirm your server is properly registered with the collector

**Invalid Server ID**
```
serverId must be a valid UUID. Please set it and restart the server.
```
**Solution**: Ensure `serverId` is a valid UUID format

### Debug Logging

Enable debug logging in your server's `bukkit.yml` or `paper-global.yml`:

```yaml
logging:
  level:
    io.level114: FINE
```

### Network Issues

If you experience connection problems:

1. Verify collector service URL is accessible
2. Check firewall settings allow HTTPS outbound connections
3. Confirm server has internet connectivity
4. Review server logs for detailed error messages

## Performance Impact

The Level114 plugin is designed for minimal performance impact:

- **CPU Usage**: < 0.1% on average
- **Memory Footprint**: < 10MB RAM
- **Network Bandwidth**: < 1KB per report
- **Disk I/O**: Minimal logging only

### Optimization

- Reports are collected on the main thread but sent asynchronously
- HTTP client uses connection pooling and timeout handling
- Failed requests use exponential backoff to prevent flooding
- Large data sets are automatically truncated (e.g., plugin list limited to 1024 entries)

## Plugin Location

The Level114 Minecraft plugins are available in the subnet repository:

```
subnet/
├── plugins/
│   ├── monitor-plugin/          # Performance monitoring plugin
│   ├── monetization-plugin/     # Shop and economy plugin (in development)
│   └── README.md               # Plugin documentation and setup guide
```

Download the latest plugin JARs from the subnet releases or build from the included source code.

## API Integration

The plugin integrates with the Level114 collector service using:

- **Base URL**: Configurable collector endpoint
- **Authentication**: Bearer token (serverApiKey)
- **Content-Type**: `application/json`
- **User-Agent**: `Level114-MinerMonitor/{version}`

### Endpoints Used

- `GET /servers/{serverId}` - Fetch server information
- `GET /reports/nonce` - Get report nonce for security
- `POST /reports/create` - Submit server performance report

## Support & Development

- **Source Code**: Available in Level114 organization
- **Issues**: Report bugs through Level114 support channels
- **Documentation**: This guide and inline code comments
- **Community**: Join Level114 Discord for support

---

*Start earning rewards with your Minecraft server by installing the Level114 plugin today!*
