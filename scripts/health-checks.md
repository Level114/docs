# Health Checks Guide

Comprehensive monitoring and health check procedures for Bittensor Minecraft subnet miners and validators.

## Overview

This guide provides tools and procedures for monitoring the health of subnet participants, identifying issues early, and maintaining optimal performance.

## Quick Health Check Scripts

### Universal Health Check

```bash
#!/bin/bash
# universal_health_check.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

echo "=== Bittensor Minecraft Subnet Health Check ==="
echo "Timestamp: $(date)"
echo "Host: $(hostname)"
echo ""

# System Health
check_system_health() {
    log "Checking system health..."
    
    # CPU Usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
        warn "High CPU usage: ${CPU_USAGE}%"
    else
        info "CPU usage: ${CPU_USAGE}%"
    fi
    
    # Memory Usage
    MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    if (( $(echo "$MEMORY_USAGE > 85" | bc -l) )); then
        warn "High memory usage: ${MEMORY_USAGE}%"
    else
        info "Memory usage: ${MEMORY_USAGE}%"
    fi
    
    # Disk Usage
    DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | cut -d'%' -f1)
    if (( DISK_USAGE > 85 )); then
        warn "High disk usage: ${DISK_USAGE}%"
    else
        info "Disk usage: ${DISK_USAGE}%"
    fi
    
    # Load Average
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    info "Load average: $LOAD_AVG"
    
    echo ""
}

# Network Connectivity
check_network() {
    log "Checking network connectivity..."
    
    # Check internet connectivity
    if ping -c 1 8.8.8.8 &> /dev/null; then
        info "✓ Internet connectivity OK"
    else
        error "✗ No internet connectivity"
    fi
    
    # Check Subtensor connectivity
    if curl -s --connect-timeout 5 https://entrypoint-finney.opentensor.ai:443 &> /dev/null; then
        info "✓ Subtensor network reachable"
    else
        warn "✗ Cannot reach Subtensor network"
    fi
    
    echo ""
}

# Process Checks
check_processes() {
    log "Checking critical processes..."
    
    # Java processes (Minecraft servers)
    JAVA_PROCESSES=$(pgrep -f "java.*paper\|java.*spigot" | wc -l)
    if [ $JAVA_PROCESSES -gt 0 ]; then
        info "✓ Found $JAVA_PROCESSES Minecraft server(s)"
    else
        warn "✗ No Minecraft servers running"
    fi
    
    # Python processes (agents)
    PYTHON_PROCESSES=$(pgrep -f "python.*miner\|python.*validator" | wc -l)
    if [ $PYTHON_PROCESSES -gt 0 ]; then
        info "✓ Found $PYTHON_PROCESSES subnet agent(s)"
    else
        warn "✗ No subnet agents running"
    fi
    
    echo ""
}

# Port Checks
check_ports() {
    log "Checking port availability..."
    
    # Common Minecraft ports
    for port in 25565 25566 25567; do
        if netstat -tlnp | grep ":$port " &> /dev/null; then
            info "✓ Port $port is in use"
        fi
    done
    
    # Common agent ports
    for port in 8080 8081 8082 9090 9091; do
        if netstat -tlnp | grep ":$port " &> /dev/null; then
            info "✓ Port $port is in use"
        fi
    done
    
    echo ""
}

# Run all checks
main() {
    check_system_health
    check_network
    check_processes  
    check_ports
    
    log "Health check completed!"
}

main "$@"
```

### Miner Health Check

```bash
#!/bin/bash
# miner_health_check.sh

MINER_HOST="${1:-localhost}"
MINER_PORT="${2:-25565}"
AGENT_PORT="${3:-8080}"

echo "=== Miner Health Check ==="
echo "Target: $MINER_HOST:$MINER_PORT"
echo "Agent: $MINER_HOST:$AGENT_PORT"
echo "Time: $(date)"
echo ""

# Minecraft Server Check
check_minecraft_server() {
    log "Checking Minecraft server..."
    
    # Test connection
    if timeout 5 bash -c "</dev/tcp/$MINER_HOST/$MINER_PORT" &>/dev/null; then
        info "✓ Server is accepting connections"
        
        # Get server status using mcstatus (if available)
        if command -v mcstatus &> /dev/null; then
            SERVER_STATUS=$(mcstatus $MINER_HOST:$MINER_PORT status 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "$SERVER_STATUS" | while read line; do
                    info "  $line"
                done
            fi
        fi
    else
        error "✗ Server is not responding"
        return 1
    fi
}

# Agent API Check  
check_agent_api() {
    log "Checking miner agent API..."
    
    # Health endpoint
    HEALTH_RESPONSE=$(curl -s --connect-timeout 5 "http://$MINER_HOST:$AGENT_PORT/health" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$HEALTH_RESPONSE" ]; then
        info "✓ Agent API is responding"
        
        # Parse response if JSON
        if command -v jq &> /dev/null && echo "$HEALTH_RESPONSE" | jq . &>/dev/null; then
            STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.status // "unknown"')
            info "  Status: $STATUS"
            
            UPTIME=$(echo "$HEALTH_RESPONSE" | jq -r '.uptime_seconds // 0')
            if [ "$UPTIME" -gt 0 ]; then
                UPTIME_HOURS=$((UPTIME / 3600))
                info "  Uptime: ${UPTIME_HOURS}h"
            fi
        else
            info "  Response: $HEALTH_RESPONSE"
        fi
    else
        error "✗ Agent API is not responding"
        return 1
    fi
    
    # Metrics endpoint
    METRICS_RESPONSE=$(curl -s --connect-timeout 5 "http://$MINER_HOST:$AGENT_PORT/metrics" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$METRICS_RESPONSE" ]; then
        info "✓ Metrics endpoint available"
        
        if command -v jq &> /dev/null && echo "$METRICS_RESPONSE" | jq . &>/dev/null; then
            TPS=$(echo "$METRICS_RESPONSE" | jq -r '.performance.tps_avg // "unknown"')
            PLAYERS=$(echo "$METRICS_RESPONSE" | jq -r '.players.online // "unknown"')
            MEMORY=$(echo "$METRICS_RESPONSE" | jq -r '.performance.memory_used_mb // "unknown"')
            
            info "  TPS: $TPS"
            info "  Players online: $PLAYERS"
            info "  Memory usage: ${MEMORY}MB"
        fi
    else
        warn "✗ Metrics endpoint not available"
    fi
}

# Performance Check
check_performance() {
    log "Checking performance metrics..."
    
    # TPS check via RCON (if configured)
    if command -v mcrcon &> /dev/null && [ -n "$RCON_PASSWORD" ]; then
        TPS_OUTPUT=$(mcrcon -H $MINER_HOST -P ${RCON_PORT:-25575} -p "$RCON_PASSWORD" "tps" 2>/dev/null)
        if [ $? -eq 0 ]; then
            info "✓ TPS data available"
            echo "$TPS_OUTPUT" | while read line; do
                info "  $line"
            done
        fi
    fi
    
    # Check server.log for issues
    if [ -f "logs/latest.log" ]; then
        ERROR_COUNT=$(grep -c "ERROR" logs/latest.log | tail -100)
        if [ "$ERROR_COUNT" -gt 0 ]; then
            warn "Found $ERROR_COUNT recent errors in server log"
        fi
        
        WARN_COUNT=$(grep -c "WARN" logs/latest.log | tail -100)
        if [ "$WARN_COUNT" -gt 10 ]; then
            warn "Found $WARN_COUNT recent warnings in server log"
        fi
    fi
}

# Network Registration Check
check_registration() {
    log "Checking network registration..."
    
    if [ -n "$WALLET_NAME" ] && [ -n "$HOTKEY" ]; then
        REG_STATUS=$(btcli wallet overview --wallet.name "$WALLET_NAME" --wallet.hotkey "$HOTKEY" 2>/dev/null)
        if [ $? -eq 0 ]; then
            info "✓ Wallet registration verified"
            # Extract key info
            echo "$REG_STATUS" | grep -E "(Balance|Stake)" | while read line; do
                info "  $line"
            done
        else
            error "✗ Cannot verify wallet registration"
        fi
    else
        warn "Wallet credentials not provided, skipping registration check"
    fi
}

# Main execution
main() {
    check_minecraft_server
    echo ""
    check_agent_api  
    echo ""
    check_performance
    echo ""
    check_registration
    echo ""
    log "Miner health check completed!"
}

main "$@"
```

### Validator Health Check

```bash
#!/bin/bash
# validator_health_check.sh

VALIDATOR_HOST="${1:-localhost}"
VALIDATOR_PORT="${2:-9090}"

echo "=== Validator Health Check ==="
echo "Target: $VALIDATOR_HOST:$VALIDATOR_PORT"
echo "Time: $(date)"
echo ""

# Validator API Check
check_validator_api() {
    log "Checking validator API..."
    
    # Health endpoint
    HEALTH_RESPONSE=$(curl -s --connect-timeout 5 "http://$VALIDATOR_HOST:$VALIDATOR_PORT/health" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$HEALTH_RESPONSE" ]; then
        info "✓ Validator API is responding"
        
        if command -v jq &> /dev/null && echo "$HEALTH_RESPONSE" | jq . &>/dev/null; then
            STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.status // "unknown"')
            info "  Status: $STATUS"
        fi
    else
        error "✗ Validator API is not responding"
        return 1
    fi
    
    # Validator status
    STATUS_RESPONSE=$(curl -s --connect-timeout 5 "http://$VALIDATOR_HOST:$VALIDATOR_PORT/status" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$STATUS_RESPONSE" ]; then
        info "✓ Status endpoint available"
        
        if command -v jq &> /dev/null && echo "$STATUS_RESPONSE" | jq . &>/dev/null; then
            MINERS_VALIDATED=$(echo "$STATUS_RESPONSE" | jq -r '.miners_validated_24h // "unknown"')
            PROBE_SUCCESS_RATE=$(echo "$STATUS_RESPONSE" | jq -r '.probe_success_rate // "unknown"')
            CONSENSUS_RATE=$(echo "$STATUS_RESPONSE" | jq -r '.consensus_agreement_rate // "unknown"')
            
            info "  Miners validated (24h): $MINERS_VALIDATED"
            info "  Probe success rate: $PROBE_SUCCESS_RATE"  
            info "  Consensus agreement: $CONSENSUS_RATE"
        fi
    fi
}

# Probe Client Check
check_probe_clients() {
    log "Checking probe clients..."
    
    # Check Docker containers (if using containerized probes)
    if command -v docker &> /dev/null; then
        PROBE_CONTAINERS=$(docker ps --filter "name=probe" --format "table {{.Names}}\t{{.Status}}" | grep -v NAMES)
        if [ -n "$PROBE_CONTAINERS" ]; then
            info "✓ Probe containers found:"
            echo "$PROBE_CONTAINERS" | while read line; do
                info "  $line"
            done
        else
            warn "No probe containers found"
        fi
    fi
    
    # Check probe processes
    PROBE_PROCESSES=$(pgrep -f "probe.*client\|client.*probe" | wc -l)
    if [ $PROBE_PROCESSES -gt 0 ]; then
        info "✓ Found $PROBE_PROCESSES probe processes"
    else
        warn "No probe processes found"
    fi
}

# Validation Performance Check
check_validation_performance() {
    log "Checking validation performance..."
    
    METRICS_RESPONSE=$(curl -s --connect-timeout 5 "http://$VALIDATOR_HOST:$VALIDATOR_PORT/metrics" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$METRICS_RESPONSE" ]; then
        if command -v jq &> /dev/null && echo "$METRICS_RESPONSE" | jq . &>/dev/null; then
            # Performance metrics
            CPU_USAGE=$(echo "$METRICS_RESPONSE" | jq -r '.system.cpu_usage_percent // "unknown"')
            MEMORY_USAGE=$(echo "$METRICS_RESPONSE" | jq -r '.system.memory_usage_mb // "unknown"')
            ACTIVE_PROBES=$(echo "$METRICS_RESPONSE" | jq -r '.validation.active_probes // "unknown"')
            
            info "  CPU usage: $CPU_USAGE%"
            info "  Memory usage: ${MEMORY_USAGE}MB"
            info "  Active probes: $ACTIVE_PROBES"
            
            # Quality metrics
            COVERAGE=$(echo "$METRICS_RESPONSE" | jq -r '.validation.coverage_percentage // "unknown"')
            ACCURACY=$(echo "$METRICS_RESPONSE" | jq -r '.validation.scoring_accuracy // "unknown"')
            
            info "  Validation coverage: $COVERAGE%"
            info "  Scoring accuracy: $ACCURACY"
        fi
    fi
}

# Weight Submission Check
check_weight_submission() {
    log "Checking weight submissions..."
    
    WEIGHTS_RESPONSE=$(curl -s --connect-timeout 5 "http://$VALIDATOR_HOST:$VALIDATOR_PORT/weights/recent" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$WEIGHTS_RESPONSE" ]; then
        info "✓ Recent weight submissions found"
        
        if command -v jq &> /dev/null && echo "$WEIGHTS_RESPONSE" | jq . &>/dev/null; then
            LAST_SUBMISSION=$(echo "$WEIGHTS_RESPONSE" | jq -r '.last_submission_time // "unknown"')
            SUBMISSION_COUNT=$(echo "$WEIGHTS_RESPONSE" | jq -r '.submissions_24h // "unknown"')
            
            info "  Last submission: $LAST_SUBMISSION"
            info "  Submissions (24h): $SUBMISSION_COUNT"
        fi
    else
        warn "No recent weight submission data"
    fi
}

# Main execution
main() {
    check_validator_api
    echo ""
    check_probe_clients
    echo ""
    check_validation_performance
    echo ""
    check_weight_submission
    echo ""
    log "Validator health check completed!"
}

main "$@"
```

## Automated Monitoring Scripts

### Continuous Monitoring

```bash
#!/bin/bash
# continuous_monitor.sh

MONITOR_INTERVAL="${1:-300}"  # 5 minutes default
LOG_FILE="${2:-monitor.log}"

echo "Starting continuous monitoring (interval: ${MONITOR_INTERVAL}s)"
echo "Logs: $LOG_FILE"

while true; do
    echo "=== Monitor Check: $(date) ===" >> "$LOG_FILE"
    
    # Run health checks
    ./universal_health_check.sh >> "$LOG_FILE" 2>&1
    
    # Check for critical issues
    if grep -q "ERROR" <<< "$(tail -50 "$LOG_FILE")"; then
        echo "CRITICAL: Errors detected in monitoring!" | tee -a "$LOG_FILE"
        
        # Send alerts (customize as needed)
        if command -v mail &> /dev/null; then
            tail -50 "$LOG_FILE" | mail -s "Subnet Health Alert" admin@example.com
        fi
    fi
    
    sleep "$MONITOR_INTERVAL"
done
```

### Log Analysis

```bash
#!/bin/bash
# analyze_logs.sh

LOG_DIR="${1:-logs}"
HOURS_BACK="${2:-24}"

echo "=== Log Analysis (Last ${HOURS_BACK}h) ==="
echo "Directory: $LOG_DIR"
echo ""

# Find log files
LOG_FILES=$(find "$LOG_DIR" -name "*.log" -mmin -$((HOURS_BACK * 60)) 2>/dev/null)

if [ -z "$LOG_FILES" ]; then
    warn "No recent log files found in $LOG_DIR"
    exit 1
fi

# Analyze each log file
for logfile in $LOG_FILES; do
    echo "--- $(basename "$logfile") ---"
    
    # Error count
    ERROR_COUNT=$(grep -c "ERROR" "$logfile" 2>/dev/null || echo "0")
    WARN_COUNT=$(grep -c "WARN" "$logfile" 2>/dev/null || echo "0")
    
    echo "Errors: $ERROR_COUNT"
    echo "Warnings: $WARN_COUNT"
    
    # Recent errors
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "Recent errors:"
        grep "ERROR" "$logfile" | tail -5 | while read line; do
            echo "  $line"
        done
    fi
    
    # Performance indicators
    if grep -q "TPS" "$logfile"; then
        echo "TPS mentions:"
        grep "TPS" "$logfile" | tail -3 | while read line; do
            echo "  $line"
        done
    fi
    
    echo ""
done

# Summary
TOTAL_ERRORS=$(find "$LOG_DIR" -name "*.log" -mmin -$((HOURS_BACK * 60)) -exec grep -c "ERROR" {} \; | awk '{sum += $1} END {print sum}')
TOTAL_WARNINGS=$(find "$LOG_DIR" -name "*.log" -mmin -$((HOURS_BACK * 60)) -exec grep -c "WARN" {} \; | awk '{sum += $1} END {print sum}')

echo "=== Summary ==="
echo "Total errors: $TOTAL_ERRORS"
echo "Total warnings: $TOTAL_WARNINGS"

if [ "$TOTAL_ERRORS" -gt 50 ]; then
    error "High error count detected!"
elif [ "$TOTAL_ERRORS" -gt 10 ]; then
    warn "Elevated error count"
else
    info "Error count within normal range"
fi
```

## Performance Benchmarking

### TPS Benchmark

```bash
#!/bin/bash
# tps_benchmark.sh

MINER_HOST="${1:-localhost}"
MINER_PORT="${2:-25565}"
DURATION="${3:-300}"  # 5 minutes

echo "=== TPS Benchmark ==="
echo "Target: $MINER_HOST:$MINER_PORT"
echo "Duration: ${DURATION}s"
echo ""

# Create benchmark client script
cat > tps_client.py << 'EOF'
import time
import requests
import statistics
import sys

def benchmark_tps(host, port, duration):
    print(f"Benchmarking TPS for {duration} seconds...")
    
    tps_readings = []
    start_time = time.time()
    
    while time.time() - start_time < duration:
        try:
            # Get TPS from miner agent
            response = requests.get(f"http://{host}:8080/metrics", timeout=5)
            if response.status_code == 200:
                data = response.json()
                tps = data.get('performance', {}).get('tps_avg', 0)
                if tps > 0:
                    tps_readings.append(tps)
                    print(f"TPS: {tps:.2f}")
            
        except Exception as e:
            print(f"Error reading TPS: {e}")
        
        time.sleep(10)  # Sample every 10 seconds
    
    if tps_readings:
        avg_tps = statistics.mean(tps_readings)
        min_tps = min(tps_readings)
        max_tps = max(tps_readings)
        
        print(f"\n=== TPS Benchmark Results ===")
        print(f"Average TPS: {avg_tps:.2f}")
        print(f"Minimum TPS: {min_tps:.2f}")
        print(f"Maximum TPS: {max_tps:.2f}")
        print(f"Samples: {len(tps_readings)}")
        
        # Performance assessment
        if avg_tps >= 19:
            print("✓ Excellent performance")
        elif avg_tps >= 15:
            print("~ Good performance")
        elif avg_tps >= 10:
            print("! Fair performance")
        else:
            print("✗ Poor performance")
    else:
        print("No TPS data collected")

if __name__ == "__main__":
    host = sys.argv[1] if len(sys.argv) > 1 else "localhost"
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 25565
    duration = int(sys.argv[3]) if len(sys.argv) > 3 else 300
    
    benchmark_tps(host, port, duration)
EOF

# Run benchmark
python3 tps_client.py "$MINER_HOST" "$MINER_PORT" "$DURATION"

# Cleanup
rm -f tps_client.py
```

## Health Check Dashboard

### Simple Web Dashboard

```bash
#!/bin/bash
# create_dashboard.sh

DASHBOARD_PORT="${1:-8888}"
DASHBOARD_DIR="health_dashboard"

mkdir -p "$DASHBOARD_DIR"

# Create simple HTML dashboard
cat > "$DASHBOARD_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Subnet Health Dashboard</title>
    <meta http-equiv="refresh" content="30">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .status-ok { color: green; }
        .status-warn { color: orange; }
        .status-error { color: red; }
        .card { border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .header { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Bittensor Minecraft Subnet Health Dashboard</h1>
        <p>Last updated: <span id="timestamp"></span></p>
    </div>
    
    <div class="card">
        <h2>System Health</h2>
        <div id="system-health">Loading...</div>
    </div>
    
    <div class="card">
        <h2>Miners</h2>
        <div id="miners">Loading...</div>
    </div>
    
    <div class="card">
        <h2>Validators</h2>
        <div id="validators">Loading...</div>
    </div>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
        
        // Update every 30 seconds
        setInterval(() => {
            location.reload();
        }, 30000);
    </script>
</body>
</html>
EOF

# Create simple Python server
cat > "$DASHBOARD_DIR/server.py" << EOF
#!/usr/bin/env python3
import http.server
import socketserver
import subprocess
import json
import os

PORT = $DASHBOARD_PORT

class HealthHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            # Run health checks and return JSON
            try:
                result = subprocess.run(['../universal_health_check.sh'], 
                                      capture_output=True, text=True, cwd='..')
                health_data = {
                    'status': 'ok' if result.returncode == 0 else 'error',
                    'output': result.stdout,
                    'timestamp': subprocess.getoutput('date')
                }
            except Exception as e:
                health_data = {
                    'status': 'error',
                    'error': str(e),
                    'timestamp': subprocess.getoutput('date')
                }
            
            self.wfile.write(json.dumps(health_data).encode())
        else:
            super().do_GET()

os.chdir('$DASHBOARD_DIR')
with socketserver.TCPServer(("", PORT), HealthHandler) as httpd:
    print(f"Dashboard available at http://localhost:{PORT}")
    httpd.serve_forever()
EOF

chmod +x "$DASHBOARD_DIR/server.py"

echo "Health dashboard created in $DASHBOARD_DIR/"
echo "Start with: cd $DASHBOARD_DIR && python3 server.py"
echo "Access at: http://localhost:$DASHBOARD_PORT"
```

## Alert Configuration

### Email Alerts

```bash
#!/bin/bash
# setup_alerts.sh

ALERT_EMAIL="${1:-admin@example.com}"
SMTP_SERVER="${2:-smtp.example.com}"

echo "Setting up email alerts to: $ALERT_EMAIL"

# Install mail utilities if needed
if ! command -v mail &> /dev/null; then
    echo "Installing mail utilities..."
    sudo apt-get update && sudo apt-get install -y mailutils
fi

# Create alert function
cat > alert_functions.sh << EOF
#!/bin/bash

send_alert() {
    local subject="\$1"
    local message="\$2"
    local priority="\${3:-normal}"
    
    echo "\$message" | mail -s "\$subject" "$ALERT_EMAIL"
    
    # Log alert
    echo "[\$(date)] ALERT SENT: \$subject" >> alerts.log
}

check_and_alert() {
    local check_name="\$1"
    local check_command="\$2"
    local alert_threshold="\${3:-1}"
    
    if ! \$check_command; then
        send_alert "Subnet Alert: \$check_name Failed" "Health check '\$check_name' failed at \$(date)"
    fi
}

# Example usage:
# check_and_alert "Miner Connection" "timeout 10 bash -c '</dev/tcp/localhost/25565'"
# check_and_alert "Validator API" "curl -s http://localhost:9090/health"
EOF

chmod +x alert_functions.sh

echo "Alert functions created in alert_functions.sh"
echo "Source this file in your monitoring scripts: source alert_functions.sh"
```

## Troubleshooting Guide

### Common Issues and Solutions

```bash
#!/bin/bash
# troubleshoot.sh

echo "=== Automated Troubleshooting ==="

# Issue: High CPU Usage
check_cpu_issues() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    if (( $(echo "$CPU_USAGE > 90" | bc -l) )); then
        echo "🔍 High CPU usage detected: ${CPU_USAGE}%"
        echo "Top processes:"
        ps aux --sort=-%cpu | head -10
        
        echo "💡 Suggestions:"
        echo "- Check for runaway Java processes"
        echo "- Reduce Minecraft server view distance"
        echo "- Check for infinite loops in plugins"
    fi
}

# Issue: Memory Problems
check_memory_issues() {
    MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    if (( $(echo "$MEMORY_USAGE > 90" | bc -l) )); then
        echo "🔍 High memory usage detected: ${MEMORY_USAGE}%"
        echo "Memory breakdown:"
        free -h
        
        echo "💡 Suggestions:"
        echo "- Increase JVM heap size for Minecraft servers"
        echo "- Check for memory leaks"
        echo "- Reduce server player limit"
    fi
}

# Issue: Network Problems
check_network_issues() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo "🔍 Network connectivity issue detected"
        echo "💡 Suggestions:"
        echo "- Check internet connection"
        echo "- Verify firewall rules"
        echo "- Check DNS resolution"
    fi
}

# Issue: Port Conflicts
check_port_conflicts() {
    echo "🔍 Checking for port conflicts..."
    
    # Check common ports
    for port in 25565 8080 9090; do
        if netstat -tlnp | grep ":$port " &> /dev/null; then
            PROCESS=$(netstat -tlnp | grep ":$port " | awk '{print $7}')
            echo "Port $port in use by: $PROCESS"
        else
            echo "Port $port is available"
        fi
    done
}

# Main troubleshooting
main() {
    check_cpu_issues
    echo ""
    check_memory_issues
    echo ""
    check_network_issues
    echo ""
    check_port_conflicts
}

main "$@"
```

This comprehensive health checks guide provides the tools and procedures needed to maintain optimal subnet performance and quickly identify issues before they impact operations.
