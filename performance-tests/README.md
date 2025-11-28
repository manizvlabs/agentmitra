# Agent Mitra Performance Testing Suite

Comprehensive load testing suite for the Agent Mitra backend API using Locust.

## Overview

This performance testing suite simulates real-world usage patterns with different user types and behaviors to ensure the system can handle various load conditions.

## Prerequisites

1. Python 3.8+
2. Backend server running (default: http://localhost:8015)
3. Database with seeded test data

## Installation

```bash
# Install dependencies
pip install -r requirements.txt

# Or use the built-in installer
python run_performance_tests.py --install-deps
```

## Quick Start

```bash
# Run basic load test (10 users, 1 minute)
python run_performance_tests.py

# Run with custom parameters
python run_performance_tests.py --users 50 --duration 5m --spawn-rate 5

# Run multiple scenarios
python run_performance_tests.py --multiple
```

## Test Scenarios

### User Types & Behaviors

1. **Super Admin** (1 user)
   - Dashboard KPIs, user management, system health, feature flags

2. **Provider Admin** (2 users)
   - Dashboard analytics, agent management, policy oversight, reporting

3. **Regional Manager** (3 users)
   - Team performance, agent oversight, policy reviews

4. **Senior Agent** (10 users)
   - Personal dashboard, customer management, policy creation, analytics

5. **Junior Agent** (20 users)
   - Profile access, policy browsing, basic analytics

6. **Policyholder** (50 users)
   - Profile access, policy viewing, payment access

7. **Support Staff** (5 users)
   - Ticket management, customer data access, reporting

### Load Scenarios

- **Basic**: 10 users, 1 minute - Quick functionality test
- **Moderate**: 50 users, 2 minutes - Normal load testing
- **Heavy**: 100 users, 3 minutes - High load testing
- **Peak**: 100 users, 5 minutes - Peak usage simulation
- **Stress**: 200 users, 10 minutes - System limits testing
- **Endurance**: 50 users, 30 minutes - Stability testing

## Usage Examples

```bash
# Basic load test
python run_performance_tests.py --scenario basic

# Peak load test
python run_performance_tests.py --scenario peak

# Custom load test
python run_performance_tests.py --users 75 --spawn-rate 7.5 --duration 10m

# Test different host
python run_performance_tests.py --host http://staging-api.agentmitra.com

# Run all scenarios sequentially
python run_performance_tests.py --multiple
```

## Results & Analysis

Results are saved in the `results/` directory:

- **CSV Files**: Detailed metrics for each test
- **HTML Reports**: Visual reports with charts and statistics

### Key Metrics

- **Response Time**: Average, min, max, percentiles
- **Requests per Second**: Throughput measurement
- **Failure Rate**: Error percentage
- **User Behavior**: Task success rates

### Performance Targets

- **Response Time**: < 500ms average, < 2s 95th percentile
- **Failure Rate**: < 1% under normal load
- **Throughput**: > 100 requests/second
- **Concurrent Users**: > 200 simultaneous users

## Monitoring During Tests

While tests are running, monitor:

1. **Backend Server**: CPU, memory, database connections
2. **Database**: Query performance, connection pooling
3. **Redis**: Cache hit rates, memory usage
4. **Network**: Response times, error rates

## Troubleshooting

### Common Issues

1. **Connection Refused**: Ensure backend server is running
2. **Authentication Failures**: Check test user credentials
3. **High Failure Rates**: Check server logs for errors
4. **Memory Issues**: Monitor resource usage during tests

### Debug Mode

```bash
# Run with debug output
locust -f locustfile.py --host http://localhost:8015 --users 10 --spawn-rate 2 --run-time 30s
```

## Integration with CI/CD

Add to your CI/CD pipeline:

```yaml
- name: Performance Tests
  run: |
    cd performance-tests
    python run_performance_tests.py --scenario basic --users 20 --duration 2m
  continue-on-error: true
```

## Best Practices

1. **Run tests in staging first**: Never load test production directly
2. **Monitor resources**: Track CPU, memory, and database performance
3. **Gradual scaling**: Start with small loads and increase gradually
4. **Realistic scenarios**: Use user behavior patterns that match production
5. **Regular testing**: Include performance tests in regular CI/CD

## Report Analysis

### Interpreting Results

- **Average Response Time**: Should be < 500ms for good UX
- **95th Percentile**: Critical for ensuring no slow requests
- **Failure Rate**: Should be < 1% under normal conditions
- **Requests/sec**: Indicates system throughput capacity

### Performance Regression Detection

Compare results against baselines:
- Historical performance data
- Previous release benchmarks
- Industry standards for similar applications

## Support

For issues or questions:
1. Check server logs during test failures
2. Monitor database query performance
3. Review system resource usage
4. Analyze network latency and throughput
