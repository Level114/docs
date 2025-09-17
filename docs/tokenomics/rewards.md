# Tokenomics & Reward Distribution<span class="terminal-cursor">:~$</span>

## Bittensor Subnet Economics

Level114 operates as a **standard Bittensor subnet**, following the established tokenomics model where miners and validators earn TAO tokens through the network's emission schedule.

### Standard Subnet Model
- **Token**: TAO (native Bittensor token)
- **Emission**: Follows Bittensor's global emission schedule
- **Distribution**: Merit-based allocation between miners and validators
- **Network**: Subnet 114 on the Bittensor network

---

## Reward Mechanism

### TAO Emission Schedule
Level114 receives a portion of Bittensor's daily TAO emission based on:
- **Subnet Performance**: Relative to other subnets in the network
- **Activity Level**: Number of active miners and validators
- **Network Value**: Contribution to the overall Bittensor ecosystem
- **Global Schedule**: Fixed daily emission distributed across all subnets

### Distribution Model
```
Daily Subnet Emission → Miners (via Validators) → Individual Rewards
```

**Emission Flow:**
1. Bittensor allocates daily TAO emission to subnet 114
2. Validators evaluate miner performance and set weights
3. Rewards distributed proportionally based on validator consensus
4. Both miners and validators receive TAO based on their contributions

---

## Miner Rewards

### How Miners Earn
Miners earn TAO tokens by:
- **Registering Infrastructure**: Contributing server resources to the network
- **Maintaining Uptime**: Keeping servers available and responsive
- **Quality Metrics**: Providing reliable performance data
- **Network Participation**: Active engagement in the validation process

### Reward Calculation
```
Miner Reward = (Individual Weight / Total Network Weight) × Daily Emission × Miner Share
```

**Weight Factors:**
- **Server Availability**: Uptime and response consistency
- **Registration Quality**: Proper setup and credential management
- **Performance Metrics**: Server performance and reliability indicators
- **Network Contribution**: Overall value provided to the subnet

### Example Scenarios

**High-Performance Miner:**
- Excellent uptime (99.9%+)
- Consistent metric reporting
- Quality server infrastructure
- **Potential Daily Earnings**: 0.5-2.0 TAO (varies with network size)

**Average Miner:**
- Good uptime (95-99%)
- Regular metric submissions
- Standard server setup
- **Potential Daily Earnings**: 0.1-0.5 TAO

**Low-Performance Miner:**
- Poor uptime (<95%)
- Irregular metrics
- Infrastructure issues
- **Potential Daily Earnings**: 0.01-0.1 TAO

*Note: Actual earnings depend on total network emissions and validator consensus*

---

## Validator Rewards

### How Validators Earn
Validators earn TAO by:
- **Network Monitoring**: Continuously assessing miner performance
- **Weight Setting**: Providing accurate performance evaluations
- **Quality Control**: Maintaining network standards and preventing gaming
- **Consensus Building**: Contributing to fair reward distribution

### Validator Economics
```
Validator Reward = Base Reward + Performance Bonus
```

**Base Reward Components:**
- **Validation Activity**: Regular weight setting and network monitoring
- **Accuracy Score**: How well validator assessments match network consensus
- **Uptime Factor**: Consistent operation without interruptions

**Performance Bonuses:**
- **Early Detection**: Identifying poor performers quickly
- **Network Coverage**: Evaluating larger portions of the network
- **Consensus Leadership**: Setting weights that other validators follow

### Validator Requirements
- **Minimum Stake**: TAO stake requirement for validator registration
- **Technical Setup**: Reliable infrastructure for continuous operation
- **API Access**: Collector service credentials for metric queries
- **Network Resources**: Sufficient bandwidth and processing power

---

## Economic Incentives

### For Server Operators (Miners)

**Positive Incentives:**
- Higher uptime = Higher rewards
- Better performance metrics = Higher weights
- Consistent operation = Stable income
- Quality infrastructure = Premium allocation

**Risk Factors:**
- Poor uptime reduces earnings significantly
- Inconsistent metrics can lead to penalty weights
- Server failures impact long-term scoring
- Registration issues may cause temporary exclusion

### For Validators

**Reward Optimization:**
- **Accuracy Focus**: Set weights that match network consensus
- **Comprehensive Coverage**: Monitor more miners for higher earnings
- **Consistent Operation**: Maintain high uptime for maximum rewards
- **Quality Assessment**: Develop effective evaluation methodologies

**Validator Responsibilities:**
- Objective performance assessment
- Resistance to gaming attempts
- Network quality maintenance
- Fair reward distribution

---

## Network Economics

### Subnet Value Proposition
Level114's value to the Bittensor ecosystem:
- **Infrastructure Validation**: Proving utility of decentralized server networks
- **Quality Assurance**: Maintaining standards for server operators
- **Scalable Model**: Demonstrating sustainable subnet economics
- **Real Utility**: Actual infrastructure services rather than synthetic tasks

### Long-term Sustainability

**Growth Drivers:**
- **Network Expansion**: More server operators joining as miners
- **Validator Participation**: Increased validation capacity
- **Quality Improvement**: Better server standards over time
- **Ecosystem Integration**: Potential integration with other Bittensor services

**Economic Stability:**
- **Merit-Based Rewards**: Performance-driven allocation prevents gaming
- **Validator Oversight**: Multiple validators ensure fair assessment
- **Network Effects**: Larger network increases individual opportunities
- **Bittensor Integration**: Benefits from overall network growth

---

## Performance Metrics & Scoring

### Evaluation Criteria
Validators assess miners using multiple factors:

**Infrastructure Quality (40%)**
- Server uptime and availability
- Response time and reliability
- Network connectivity quality
- Hardware performance indicators

**Participation Quality (35%)**
- Registration completeness and accuracy
- Metric reporting consistency
- Protocol compliance
- Network responsiveness

**Long-term Reliability (25%)**
- Historical performance trends
- Consistency over time periods
- Recovery from issues
- Overall network contribution

### Scoring Algorithm
```python
def calculate_miner_score(miner_data):
    # Infrastructure quality assessment
    infra_score = evaluate_infrastructure(miner_data.uptime, 
                                        miner_data.response_time,
                                        miner_data.connectivity)
    
    # Participation quality assessment  
    participation_score = evaluate_participation(miner_data.metrics,
                                               miner_data.registration,
                                               miner_data.compliance)
    
    # Long-term reliability assessment
    reliability_score = evaluate_reliability(miner_data.history,
                                           miner_data.consistency,
                                           miner_data.recovery)
    
    # Weighted final score
    final_score = (infra_score * 0.40 + 
                   participation_score * 0.35 + 
                   reliability_score * 0.25)
    
    return normalize_score(final_score)
```

---

## Getting Started with Rewards

### For New Miners
1. **Register Your Server**: Complete one-time registration process
2. **Monitor Performance**: Ensure consistent uptime and reliability
3. **Track Weights**: Watch validator assessments of your performance  
4. **Optimize Setup**: Improve infrastructure based on scoring feedback
5. **Earn Rewards**: Receive TAO proportional to your network contribution

### For New Validators
1. **Stake TAO**: Meet minimum staking requirements for validation
2. **Get API Access**: Obtain collector service credentials
3. **Deploy Infrastructure**: Set up reliable validator node
4. **Start Monitoring**: Begin evaluating miner performance
5. **Earn Rewards**: Receive TAO for maintaining network quality

---

**Level114's tokenomics align individual incentives with network health, creating a sustainable ecosystem where quality infrastructure providers are rewarded fairly through the established Bittensor emission mechanism.**