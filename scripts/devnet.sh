#!/bin/bash
set -e

# Bittensor Minecraft Subnet - Local Development Network Setup
# This script sets up a complete local development environment for testing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEVNET_DIR="$PROJECT_ROOT/devnet"

# Configuration
SUBNET_ID="999"  # Local devnet subnet ID
MINER_COUNT=3
VALIDATOR_COUNT=2
JAVA_HEAP_SIZE="2G"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

check_requirements() {
    log "Checking system requirements..."
    
    # Check Java
    if ! command -v java &> /dev/null; then
        error "Java is not installed. Please install Java 17 or higher."
    fi
    
    local java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
    if [[ "$java_version" -lt 17 ]]; then
        error "Java 17 or higher is required. Current version: $java_version"
    fi
    
    # Check Python and Bittensor
    if ! command -v python3 &> /dev/null; then
        error "Python 3 is not installed."
    fi
    
    if ! python3 -c "import bittensor" &> /dev/null; then
        warn "Bittensor is not installed. Installing..."
        pip3 install bittensor
    fi
    
    # Check Docker (optional but recommended)
    if ! command -v docker &> /dev/null; then
        warn "Docker is not installed. Some features may be limited."
    fi
    
    log "Requirements check passed!"
}

setup_devnet_directory() {
    log "Setting up devnet directory structure..."
    
    mkdir -p "$DEVNET_DIR"
    mkdir -p "$DEVNET_DIR/miners"
    mkdir -p "$DEVNET_DIR/validators"
    mkdir -p "$DEVNET_DIR/wallets"
    mkdir -p "$DEVNET_DIR/logs"
    mkdir -p "$DEVNET_DIR/config"
    mkdir -p "$DEVNET_DIR/data"
    
    log "Directory structure created at $DEVNET_DIR"
}

generate_wallets() {
    log "Generating development wallets..."
    
    cd "$DEVNET_DIR/wallets"
    
    # Generate miner wallets
    for i in $(seq 1 $MINER_COUNT); do
        if [[ ! -d "miner$i" ]]; then
            info "Creating wallet for miner$i..."
            btcli wallet create --wallet.name "miner$i" --wallet.hotkey "miner$i" --no_prompt --overwrite_coldkey --overwrite_hotkey
        fi
    done
    
    # Generate validator wallets
    for i in $(seq 1 $VALIDATOR_COUNT); do
        if [[ ! -d "validator$i" ]]; then
            info "Creating wallet for validator$i..."
            btcli wallet create --wallet.name "validator$i" --wallet.hotkey "validator$i" --no_prompt --overwrite_coldkey --overwrite_hotkey
        fi
    done
    
    log "Wallets generated successfully!"
}

download_server_software() {
    log "Downloading Minecraft server software..."
    
    local paper_url="https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/196/downloads/paper-1.20.1-196.jar"
    local server_dir="$DEVNET_DIR/server"
    
    mkdir -p "$server_dir"
    
    if [[ ! -f "$server_dir/paper.jar" ]]; then
        info "Downloading Paper server..."
        wget -O "$server_dir/paper.jar" "$paper_url" || error "Failed to download Paper server"
    fi
    
    # Create EULA acceptance
    echo "eula=true" > "$server_dir/eula.txt"
    
    log "Server software ready!"
}

create_miner_configs() {
    log "Creating miner configurations..."
    
    for i in $(seq 1 $MINER_COUNT); do
        local miner_dir="$DEVNET_DIR/miners/miner$i"
        mkdir -p "$miner_dir"
        
        # Copy server files
        cp -r "$DEVNET_DIR/server/"* "$miner_dir/"
        
        # Create server.properties
        cat > "$miner_dir/server.properties" << EOF
server-port=$((25564 + $i))
server-ip=127.0.0.1
online-mode=false
white-list=false
max-players=20
view-distance=6
simulation-distance=6
spawn-protection=0
allow-flight=true
difficulty=normal
gamemode=survival
motd=Devnet Miner $i - Bittensor Minecraft Subnet
enable-rcon=true
rcon.port=$((25574 + $i))
rcon.password=devnet_rcon_$i
EOF
        
        # Create startup script
        cat > "$miner_dir/start.sh" << EOF
#!/bin/bash
cd "\$(dirname "\$0")"
echo "Starting Miner $i..."
java -Xms$JAVA_HEAP_SIZE -Xmx$JAVA_HEAP_SIZE -jar paper.jar --nogui
EOF
        chmod +x "$miner_dir/start.sh"
        
        # Create miner agent config
        cat > "$miner_dir/miner_config.yaml" << EOF
wallet:
  name: "miner$i"
  hotkey: "miner$i"
  path: "$DEVNET_DIR/wallets"

subtensor:
  network: "local"
  endpoint: "ws://127.0.0.1:9944"
  netuid: $SUBNET_ID

minecraft:
  host: "127.0.0.1"
  port: $((25564 + $i))
  rcon_port: $((25574 + $i))
  rcon_password: "devnet_rcon_$i"

network:
  bind_address: "127.0.0.1"
  bind_port: $((8080 + $i))
  external_ip: "127.0.0.1"

logging:
  level: "debug"
  file: "$DEVNET_DIR/logs/miner$i.log"
EOF
    done
    
    log "Miner configurations created!"
}

create_validator_configs() {
    log "Creating validator configurations..."
    
    for i in $(seq 1 $VALIDATOR_COUNT); do
        local validator_dir="$DEVNET_DIR/validators/validator$i"
        mkdir -p "$validator_dir"
        
        # Create validator config
        cat > "$validator_dir/validator_config.yaml" << EOF
wallet:
  name: "validator$i"
  hotkey: "validator$i"  
  path: "$DEVNET_DIR/wallets"

subtensor:
  network: "local"
  endpoint: "ws://127.0.0.1:9944"
  netuid: $SUBNET_ID

network:
  bind_address: "127.0.0.1"
  bind_port: $((9090 + $i))

validation:
  evaluation_interval: 60  # Faster for devnet
  probe_timeout: 10
  target_miners: [
$(for j in $(seq 1 $MINER_COUNT); do
  echo "    \"127.0.0.1:$((25564 + $j))\","
done)
  ]

logging:
  level: "debug"
  file: "$DEVNET_DIR/logs/validator$i.log"
EOF
    done
    
    log "Validator configurations created!"
}

create_docker_compose() {
    log "Creating Docker Compose configuration..."
    
    cat > "$DEVNET_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  # Local Subtensor node for development
  subtensor:
    image: opentensorai/subtensor:latest
    container_name: devnet-subtensor
    command: ["--dev", "--ws-external", "--rpc-external", "--rpc-cors", "all"]
    ports:
      - "9944:9944"
      - "9933:9933"
    networks:
      - devnet

  # Prometheus for metrics
  prometheus:
    image: prom/prometheus:latest
    container_name: devnet-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - devnet

  # Grafana for monitoring
  grafana:
    image: grafana/grafana:latest
    container_name: devnet-grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - devnet

networks:
  devnet:
    driver: bridge

volumes:
  grafana-data:
EOF
    
    # Create Prometheus config
    mkdir -p "$DEVNET_DIR/config"
    cat > "$DEVNET_DIR/config/prometheus.yml" << EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'miners'
    static_configs:
      - targets:
$(for i in $(seq 1 $MINER_COUNT); do
  echo "        - '127.0.0.1:$((8080 + $i))'"
done)

  - job_name: 'validators'
    static_configs:
      - targets:
$(for i in $(seq 1 $VALIDATOR_COUNT); do
  echo "        - '127.0.0.1:$((9090 + $i))'"
done)
EOF
    
    log "Docker Compose configuration created!"
}

create_management_scripts() {
    log "Creating management scripts..."
    
    # Start script
    cat > "$DEVNET_DIR/start_devnet.sh" << 'EOF'
#!/bin/bash
set -e

DEVNET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting Bittensor Minecraft Subnet Devnet..."

# Start infrastructure
echo "Starting infrastructure services..."
docker-compose up -d

# Wait for Subtensor to be ready
echo "Waiting for Subtensor to be ready..."
while ! curl -s http://127.0.0.1:9944 > /dev/null; do
    sleep 2
done

echo "Infrastructure ready! Starting miners and validators..."

# Start miners in background
for i in {1..3}; do
    echo "Starting miner$i..."
    cd "$DEVNET_DIR/miners/miner$i"
    screen -dmS "miner$i" ./start.sh
done

# Wait a bit for miners to start
sleep 10

# Start validators in background  
for i in {1..2}; do
    echo "Starting validator$i..."
    cd "$DEVNET_DIR/validators/validator$i"
    # screen -dmS "validator$i" python3 validator_agent.py --config validator_config.yaml
done

echo "Devnet started successfully!"
echo "Services:"
echo "  - Subtensor: http://127.0.0.1:9944"
echo "  - Prometheus: http://127.0.0.1:9090" 
echo "  - Grafana: http://127.0.0.1:3000 (admin/admin)"
echo "  - Miners: ports 25565-25567"
echo ""
echo "Use './stop_devnet.sh' to stop all services"
EOF
    chmod +x "$DEVNET_DIR/start_devnet.sh"
    
    # Stop script
    cat > "$DEVNET_DIR/stop_devnet.sh" << 'EOF'
#!/bin/bash
DEVNET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Stopping Bittensor Minecraft Subnet Devnet..."

# Stop screen sessions
for session in $(screen -ls | grep -E "(miner|validator)" | cut -d. -f1 | tr -d '\t'); do
    echo "Stopping screen session: $session"
    screen -S "$session" -X quit 2>/dev/null || true
done

# Stop Docker services
cd "$DEVNET_DIR"
docker-compose down

echo "Devnet stopped successfully!"
EOF
    chmod +x "$DEVNET_DIR/stop_devnet.sh"
    
    # Status script
    cat > "$DEVNET_DIR/status.sh" << 'EOF'
#!/bin/bash
echo "=== Devnet Status ==="

echo "Docker Services:"
docker-compose ps

echo -e "\nScreen Sessions:"
screen -ls | grep -E "(miner|validator)" || echo "No active sessions"

echo -e "\nMinecraft Servers:"
for port in {25565..25567}; do
    if nc -z 127.0.0.1 $port 2>/dev/null; then
        echo "  Port $port: ONLINE"
    else
        echo "  Port $port: OFFLINE"
    fi
done

echo -e "\nValidator APIs:"
for port in {9091..9092}; do
    if nc -z 127.0.0.1 $port 2>/dev/null; then
        echo "  Port $port: ONLINE"
    else
        echo "  Port $port: OFFLINE"
    fi
done
EOF
    chmod +x "$DEVNET_DIR/status.sh"
    
    log "Management scripts created!"
}

create_readme() {
    log "Creating devnet README..."
    
    cat > "$DEVNET_DIR/README.md" << 'EOF'
# Bittensor Minecraft Subnet - Development Network

This directory contains a complete local development environment for the Bittensor Minecraft subnet.

## Quick Start

1. **Start the devnet:**
   ```bash
   ./start_devnet.sh
   ```

2. **Check status:**
   ```bash
   ./status.sh
   ```

3. **Stop the devnet:**
   ```bash
   ./stop_devnet.sh
   ```

## Services

### Infrastructure
- **Subtensor Node**: `ws://127.0.0.1:9944` - Local blockchain node
- **Prometheus**: `http://127.0.0.1:9090` - Metrics collection
- **Grafana**: `http://127.0.0.1:3000` - Monitoring dashboard (admin/admin)

### Miners
- **Miner 1**: `127.0.0.1:25565` - Minecraft server
- **Miner 2**: `127.0.0.1:25566` - Minecraft server  
- **Miner 3**: `127.0.0.1:25567` - Minecraft server

### Validators
- **Validator 1**: `127.0.0.1:9091` - Quality assessment API
- **Validator 2**: `127.0.0.1:9092` - Quality assessment API

## Testing

### Connect to a Miner
```bash
# Using Minecraft client, connect to:
127.0.0.1:25565  # Miner 1
127.0.0.1:25566  # Miner 2
127.0.0.1:25567  # Miner 3
```

### Check Miner Status
```bash
curl http://127.0.0.1:8081/health  # Miner 1 agent
curl http://127.0.0.1:8082/health  # Miner 2 agent
curl http://127.0.0.1:8083/health  # Miner 3 agent
```

### View Logs
```bash
tail -f logs/miner1.log      # Miner 1 logs
tail -f logs/validator1.log  # Validator 1 logs
```

## Development Workflow

1. Make changes to the subnet code
2. Restart affected services
3. Test with multiple miners and validators
4. Monitor through Grafana dashboard
5. Check logs for issues

## Troubleshooting

### Common Issues

**Miners not starting:**
- Check Java is installed and version 17+
- Verify ports are not in use
- Check logs in `logs/` directory

**Validators not connecting to miners:**
- Ensure miners are fully started (check server.log)
- Verify firewall isn't blocking connections
- Check validator configuration

**Subtensor connection issues:**
- Ensure Docker is running
- Check if port 9944 is accessible
- Restart Docker services if needed

### Clean Reset
```bash
./stop_devnet.sh
rm -rf data/  # Clear all data
./start_devnet.sh
```

## File Structure

```
devnet/
├── miners/           # Miner configurations and servers
├── validators/       # Validator configurations
├── wallets/         # Development wallets
├── logs/            # All service logs
├── config/          # Configuration files
├── data/            # Runtime data
├── docker-compose.yml
├── start_devnet.sh
├── stop_devnet.sh
├── status.sh
└── README.md
```
EOF
    
    log "Devnet README created!"
}

main() {
    log "Starting Bittensor Minecraft Subnet Devnet Setup..."
    
    check_requirements
    setup_devnet_directory
    generate_wallets
    download_server_software
    create_miner_configs
    create_validator_configs
    create_docker_compose
    create_management_scripts
    create_readme
    
    log "Devnet setup completed successfully!"
    info "To start the devnet: cd $DEVNET_DIR && ./start_devnet.sh"
    info "For more information: cd $DEVNET_DIR && cat README.md"
}

# Handle command line arguments
case "${1:-setup}" in
    setup)
        main
        ;;
    start)
        cd "$DEVNET_DIR" && ./start_devnet.sh
        ;;
    stop)
        cd "$DEVNET_DIR" && ./stop_devnet.sh
        ;;
    status)
        cd "$DEVNET_DIR" && ./status.sh
        ;;
    clean)
        warn "This will delete all devnet data. Continue? [y/N]"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -rf "$DEVNET_DIR"
            log "Devnet cleaned successfully!"
        fi
        ;;
    *)
        echo "Usage: $0 {setup|start|stop|status|clean}"
        echo ""
        echo "Commands:"
        echo "  setup  - Set up the devnet environment (default)"
        echo "  start  - Start all devnet services"
        echo "  stop   - Stop all devnet services"
        echo "  status - Show status of all services"
        echo "  clean  - Remove all devnet data"
        exit 1
        ;;
esac
