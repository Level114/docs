# Level114 Documentation

> **Documentation for Level 114 - the first gaming subnet on Bittensor**

This documentation covers the Level114 subnet ecosystem, which consists of:

- **Collector-Center Service**: Rust-based central registry and gaming metrics collection service
- **Bittensor Subnet**: Python implementation with gaming-focused miners and validators
- **Gaming Infrastructure**: Minecraft server performance validation with monitoring and monetization plugins

## Quick Links

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **Overview** | Understanding the Level114 ecosystem | [Home](docs/00-index.md) |
| **Miners** | Register server infrastructure | [Miner Setup](docs/getting-started/setup-miner.md) |
| **Validators** | Validate network performance | [Validator Setup](docs/getting-started/setup-validator.md) |
| **Plugins** | Server monitoring and metric collection | [Plugin Overview](docs/plugins/overview.md) |
| **Architecture** | System design and data flow | [Architecture Overview](docs/architecture/overview.md) |
| **Tokenomics** | Reward mechanisms and economics | [Tokenomics](docs/tokenomics/rewards.md) |

## System Architecture

Level114 pioneers decentralized gaming infrastructure validation through:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│ Minecraft Servers│    │   Collector      │    │   Validators        │
│ (Server Operators)│───►│   Service        │◄───│ (Quality Control)   │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
         │                        │                        │
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  ▼
                      ┌─────────────────────┐
                      │ Bittensor Network   │
                      │ (Reward Distribution)│
                      └─────────────────────┘
```

**Key Features:**
- Decentralized Minecraft server performance validation
- Server-specific monetization tools and revenue tracking  
- Performance-driven quality assessment and rewards
- Merit-based TAO distribution for server operators and validators
- Plugin-based monitoring and economy management

## Getting Started

### Prerequisites
- **For Minecraft Server Operators**: Public IP, Bittensor wallet, Minecraft server (Bukkit/Paper)
- **For Validators**: Bittensor validator setup, Level114 API access
- **For Players**: Access to Level114-enabled Minecraft servers

### Quick Start
1. **Run Minecraft Server**: Operate Minecraft servers with Level114 plugin integration
2. **Install Monitoring Plugin**: Implement Level114 performance tracking and metrics reporting
3. **Earn Rewards**: TAO distributed based on server performance, player engagement, and validation work

## Documentation

This site is built with MkDocs and uses a terminal-inspired theme. To run locally:

```bash
# Install MkDocs
pip install mkdocs mkdocs-material mkdocs-mermaid2-plugin

# Serve locally
mkdocs serve

# Build static site
mkdocs build
```

## Repository Structure

```
docs/
├── 00-index.md                    # Main overview
├── getting-started/                
│   ├── deploy-collector.md        # Collector service deployment
│   ├── setup-miner.md            # Miner registration guide
│   └── setup-validator.md        # Validator setup guide
├── architecture/
│   └── overview.md                # System architecture
├── tokenomics/
│   └── rewards.md                 # Reward mechanisms
└── stylesheets/
    └── extra.css                  # Terminal theme styling
```

## Contributing

This documentation reflects the actual implementation of:
- **collector-center-main**: Rust service for registration and metrics
- **subnet**: Python Bittensor subnet implementation

To contribute:
1. Review the actual source code to understand implementation details
2. Update documentation to match code reality
3. Test setup procedures on clean environments
4. Submit PRs with accurate, verified information

## Support

- **GitHub**: [Level114 Organization](https://github.com/level114)
- **Discord**: [Community Server](https://discord.level114.io)
- **Documentation Issues**: [Report Here](https://github.com/level114/docs/issues)

---

*Level114: Proving the value of decentralized infrastructure through Bittensor's validation network.*