# System Architecture Overview<span class="terminal-cursor">:~$</span>

## Components Overview

The Level114 subnet consists of four main components working together to create a decentralized infrastructure validation network.

### Level114 Collector Service
**A Rust-based central registry operated by the Level114 team**

The collector service is maintained and operated by Level114 as the central hub for server registration and metrics collection. It provides authenticated API access for validators to query server performance data.

**Key Responsibilities:**
- Accept and verify server registrations using cryptographic signatures
- Issue API credentials for authenticated operations
- Collect and store performance metrics from registered servers
- Provide query API for validators to access server data
- Maintain data integrity through cryptographic verification

**Technical Stack:**
- **Language**: Rust with Axum web framework
- **Database**: PostgreSQL for persistent storage
- **Cache**: Redis for performance optimization
- **Authentication**: Ed25519 keypairs + Bearer token API keys
- **Deployment**: Docker containers with health monitoring

### Subnet Miners
**Python processes that register server infrastructure**

Miners represent server operators who want to participate in the validation network. They register once with the collector service and can subsequently report performance metrics.

**Core Responsibilities:**
- Register server with collector service using Substrate signatures
- Save issued credentials (Server ID, API token, Key ID) locally
- Provide infrastructure for metric reporting (optional)
- Maintain server availability for validation assessment

**Registration Process:**
1. Generate registration signature using Bittensor wallet
2. Submit registration request to collector service
3. Receive and store issued credentials
4. Exit successfully after one-time registration

### Subnet Validators
**Python processes that validate server performance**

Validators continuously monitor registered servers by querying the collector service for performance metrics and setting weights on the Bittensor network accordingly.

**Core Responsibilities:**
- Query collector service for registered server information
- Retrieve performance metrics and reports for evaluation
- Assess server quality using multiple performance criteria
- Set weights on Bittensor network based on performance scores
- Maintain network quality standards through continuous monitoring

### Level114 Plugins
**Server monitoring agents that collect performance metrics**

Level114 plugins are server-specific monitoring tools that run on miners' infrastructure to collect detailed performance data and report it to the collector service.

**Available Plugins:**
- **Minecraft Plugin**: Comprehensive monitoring for Bukkit/Paper Minecraft servers
- **Monetization Plugins**: Unified shop systems, player progression, and revenue analytics for Level114 published games

**Core Responsibilities:**
- Collect real-time server performance metrics (players, resources, uptime)
- Format data into standardized reports with cryptographic integrity
- Transmit metrics securely to Level114 collector service
- Provide administrative tools for monitoring and status checking
- Enable automated revenue generation based on server quality

---

## Data Flow Architecture

```mermaid
graph TB
    subgraph "Server Infrastructure"
        S1[Server 1]
        S2[Server 2]
        SN[Server N]
    end
    
    subgraph "Level114 Plugins"
        P1[Minecraft Plugin]
        P2[Future Plugin]
        PN[Plugin N]
    end
    
    subgraph "Level114 Subnet"
        M1[Miner 1] 
        M2[Miner 2]
        MN[Miner N]
        V1[Validator 1]
        V2[Validator 2]
    end
    
    subgraph "Collector Service"
        API[REST API]
        DB[(PostgreSQL)]
        CACHE[(Redis)]
        AUTH[Authentication]
    end
    
    subgraph "Bittensor Network"
        BT[Subtensor]
    end
    
    S1 --> P1
    S2 --> P2
    SN --> PN
    
    P1 -.-> M1
    P2 -.-> M2
    PN -.-> MN
    
    M1 -->|Register Once| API
    M2 -->|Register Once| API  
    MN -->|Register Once| API
    
    P1 -->|Report Metrics| API
    P2 -->|Report Metrics| API
    PN -->|Report Metrics| API
    
    API --> AUTH
    AUTH --> DB
    API --> CACHE
    
    V1 -->|Query Metrics| API
    V2 -->|Query Metrics| API
    
    V1 -->|Set Weights| BT
    V2 -->|Set Weights| BT
    
    BT -->|Rewards| M1
    BT -->|Rewards| M2
    BT -->|Rewards| MN
    BT -->|Rewards| V1
    BT -->|Rewards| V2
```

---

## Registration Flow

### 1. Server Registration

```mermaid
sequenceDiagram
    participant M as Miner
    participant C as Collector API
    participant DB as Database
    participant BT as Bittensor
    
    M->>M: Generate signature for registration
    M->>C: POST /servers/register
    Note over C: Verify signature against hotkey
    C->>BT: Validate hotkey is registered on subnet
    BT-->>C: Hotkey validation result
    C->>DB: Store server registration
    C->>C: Generate API credentials
    DB-->>C: Registration confirmation
    C-->>M: Return server_id, api_token, key_id
    M->>M: Save credentials locally
```

### 2. Metrics Querying

```mermaid
sequenceDiagram
    participant V as Validator
    participant C as Collector API
    participant DB as Database
    
    V->>C: GET /validators/servers/ids?hotkeys=...
    C->>DB: Query registered servers by hotkeys
    DB-->>C: Return server information
    C-->>V: Return server IDs and metadata
    
    V->>C: GET /validators/servers/{id}/reports
    C->>DB: Query metrics for server
    DB-->>C: Return performance reports
    C-->>V: Return server metrics data
    
    V->>V: Calculate performance scores
    V->>Bittensor: Set weights based on scores
```

---

## API Architecture

### Collector Service Endpoints

#### Public Endpoints
- `GET /health` - Service health check
- `POST /servers/register` - Server registration (rate limited)
- `GET /servers` - List registered servers (rate limited)

#### Server Endpoints (API Key Required)
- `GET /servers/{id}` - Get server details
- `GET /reports/nonce` - Get reporting nonce  
- `POST /reports/create` - Submit performance report

#### Validator Endpoints (Validator API Key Required)
- `GET /validators/servers/ids` - Get server IDs by hotkeys
- `GET /validators/servers/{id}/reports` - Get server performance reports

### Authentication Layers

1. **Public Access**: Rate limited by IP address
2. **Server API Keys**: Generated during registration, scoped to server operations
3. **Validator API Keys**: Manually issued, scoped to validation queries
4. **Signature Verification**: Substrate-compatible signatures for registration

---

## Database Schema

### Core Tables

**servers**: Registered server information
- `id`, `ip`, `port`, `hotkey`, `signature`, `status`, `last_seen`

**server_keypairs**: Cryptographic keys for servers
- `server_id`, `public_key`, `private_key`, `key_id`

**server_api_keys**: API authentication tokens
- `server_id`, `key_id`, `secret_hash`, `status`

**reports**: Performance metrics submissions
- `server_id`, `counter`, `payload`, `signature`, `created_at`

**validator_api_keys**: Validator authentication
- `hotkey`, `key_id`, `secret_hash`, `scopes`

---

## Security Model

### Registration Security
- **Signature Verification**: All registrations require valid Substrate signatures
- **Hotkey Validation**: Hotkeys must be registered on Bittensor subnet
- **Rate Limiting**: IP-based limits prevent spam registrations
- **Unique Constraints**: Prevents duplicate server registrations

### API Security  
- **Bearer Token Authentication**: API keys required for sensitive operations
- **Scoped Access**: Different key types have different permission levels
- **Request Signing**: Critical operations require cryptographic signatures
- **Cache Security**: Sensitive data cached with appropriate TTL

### Network Security
- **TLS Encryption**: All API communication encrypted in transit
- **Input Validation**: Comprehensive request validation and sanitization
- **SQL Injection Prevention**: Parameterized queries throughout
- **DoS Protection**: Rate limiting and timeout mechanisms

---

## Scalability Considerations

### Performance Optimizations
- **Redis Caching**: Frequently accessed data cached for fast retrieval
- **Database Indexing**: Optimized queries for common access patterns  
- **Connection Pooling**: Efficient database connection management
- **Async Processing**: Non-blocking I/O for concurrent request handling

### Horizontal Scaling
- **Stateless Design**: Service can be horizontally scaled behind load balancer
- **Database Sharding**: Preparation for multi-region deployments
- **Cache Distribution**: Redis clustering for high availability
- **Regional Deployment**: Geographic distribution for global access

---

**The Level114 architecture prioritizes simplicity, security, and scalability to create a robust foundation for decentralized infrastructure validation.**