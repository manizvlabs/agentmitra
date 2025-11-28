#!/usr/bin/env python3
"""
Agent Mitra Performance Testing Suite
Runs comprehensive load testing scenarios
"""

import subprocess
import sys
import os
import json
import time
from datetime import datetime
import argparse

def run_command(cmd, cwd=None):
    """Run a shell command and return the result"""
    try:
        result = subprocess.run(cmd, shell=True, cwd=cwd,
                              capture_output=True, text=True, check=True)
        return result.stdout, result.stderr, 0
    except subprocess.CalledProcessError as e:
        return e.stdout, e.stderr, e.returncode

def install_dependencies():
    """Install performance testing dependencies"""
    print("📦 Installing performance testing dependencies...")
    stdout, stderr, code = run_command("pip install -r requirements.txt", cwd="performance-tests")
    if code != 0:
        print(f"❌ Failed to install dependencies: {stderr}")
        return False
    print("✅ Dependencies installed successfully")
    return True

def run_load_test(scenario="basic", users=10, spawn_rate=2, duration="1m", host="http://localhost:8015"):
    """Run a specific load testing scenario"""

    scenarios = {
        "basic": {
            "name": "Basic Load Test",
            "description": "Basic load test with mixed user types",
            "users": users,
            "spawn_rate": spawn_rate,
            "run_time": duration
        },
        "peak": {
            "name": "Peak Load Test",
            "description": "High load test simulating peak usage",
            "users": 100,
            "spawn_rate": 10,
            "run_time": "5m"
        },
        "stress": {
            "name": "Stress Test",
            "description": "Stress test to find system limits",
            "users": 200,
            "spawn_rate": 20,
            "run_time": "10m"
        },
        "endurance": {
            "name": "Endurance Test",
            "description": "Long-running test for stability",
            "users": 50,
            "spawn_rate": 5,
            "run_time": "30m"
        }
    }

    if scenario not in scenarios:
        print(f"❌ Unknown scenario: {scenario}")
        print(f"Available scenarios: {', '.join(scenarios.keys())}")
        return False

    config = scenarios[scenario]

    print(f"🚀 Starting {config['name']}")
    print(f"   Description: {config['description']}")
    print(f"   Users: {config['users']}")
    print(f"   Spawn Rate: {config['spawn_rate']} users/second")
    print(f"   Duration: {config['run_time']}")
    print(f"   Host: {host}")
    print("-" * 50)

    # Run Locust test
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results_file = f"performance-tests/results/{scenario}_{timestamp}.csv"

    os.makedirs("performance-tests/results", exist_ok=True)

    cmd = (
        f"locust -f locustfile.py "
        f"--host {host} "
        f"--users {config['users']} "
        f"--spawn-rate {config['spawn_rate']} "
        f"--run-time {config['run_time']} "
        f"--csv {results_file} "
        f"--html performance-tests/results/{scenario}_{timestamp}.html "
        f"--headless"
    )

    print(f"Running: {cmd}")
    start_time = time.time()

    stdout, stderr, code = run_command(cmd, cwd="performance-tests")

    end_time = time.time()
    duration = end_time - start_time

    if code == 0:
        print("✅ Load test completed successfully"        print(".1f"        print(f"📊 Results saved to: {results_file}")
        print(f"🌐 HTML Report: performance-tests/results/{scenario}_{timestamp}.html")
        return True
    else:
        print(f"❌ Load test failed: {stderr}")
        return False

def analyze_results(scenario, timestamp):
    """Analyze load test results"""
    results_file = f"performance-tests/results/{scenario}_{timestamp}.csv"

    if not os.path.exists(results_file):
        print(f"❌ Results file not found: {results_file}")
        return False

    print("📊 Analyzing Results...")

    try:
        # Read and analyze CSV results
        with open(results_file, 'r') as f:
            lines = f.readlines()

        if len(lines) < 2:
            print("❌ Insufficient data in results file")
            return False

        # Parse header and data
        headers = lines[0].strip().split(',')
        data = lines[-1].strip().split(',')  # Last line has summary

        results = dict(zip(headers, data))

        print("📈 Key Metrics:")
        print(f"   Total Requests: {results.get('Total Request Count', 'N/A')}")
        print(f"   Failure Count: {results.get('Total Failure Count', 'N/A')}")
        print(f"   Average Response Time: {results.get('Average Response Time', 'N/A')}ms")
        print(f"   Min Response Time: {results.get('Min Response Time', 'N/A')}ms")
        print(f"   Max Response Time: {results.get('Max Response Time', 'N/A')}ms")
        print(f"   95th Percentile: {results.get('95%ile Response Time', 'N/A')}ms")
        print(f"   Requests/sec: {results.get('Total Average Response Time', 'N/A')}")

        # Basic analysis
        failure_count = int(results.get('Total Failure Count', 0))
        total_requests = int(results.get('Total Request Count', 0))

        if total_requests > 0:
            failure_rate = (failure_count / total_requests) * 100
            print(".2f"
            if failure_rate > 5:
                print("⚠️  High failure rate detected!"            elif failure_rate > 1:
                print("⚠️  Moderate failure rate detected"            else:
                print("✅ Low failure rate - good performance")

        avg_response_time = float(results.get('Average Response Time', 0))
        if avg_response_time > 2000:  # 2 seconds
            print("⚠️  High average response time detected"        elif avg_response_time > 500:  # 500ms
            print("⚠️  Moderate response time"        else:
            print("✅ Good response time performance")

        return True

    except Exception as e:
        print(f"❌ Error analyzing results: {e}")
        return False

def run_multiple_scenarios(host="http://localhost:8015"):
    """Run multiple load testing scenarios"""

    scenarios = [
        {"name": "basic", "users": 10, "duration": "1m"},
        {"name": "moderate", "users": 50, "duration": "2m"},
        {"name": "heavy", "users": 100, "duration": "3m"}
    ]

    results = []

    for scenario in scenarios:
        print(f"\n🔄 Running {scenario['name']} load test...")
        success = run_load_test(
            scenario=scenario["name"],
            users=scenario["users"],
            duration=scenario["duration"],
            host=host
        )

        results.append({
            "scenario": scenario["name"],
            "success": success,
            "users": scenario["users"],
            "duration": scenario["duration"]
        })

        if not success:
            print(f"❌ {scenario['name']} scenario failed, stopping...")
            break

        # Brief pause between tests
        time.sleep(10)

    print("\n📋 Test Summary:")
    for result in results:
        status = "✅ PASSED" if result["success"] else "❌ FAILED"
        print(f"   {result['scenario']}: {status} ({result['users']} users, {result['duration']})")

    return all(r["success"] for r in results)

def main():
    parser = argparse.ArgumentParser(description="Agent Mitra Performance Testing Suite")
    parser.add_argument("--host", default="http://localhost:8015",
                       help="Target host URL (default: http://localhost:8015)")
    parser.add_argument("--scenario", choices=["basic", "peak", "stress", "endurance"],
                       default="basic", help="Test scenario to run")
    parser.add_argument("--users", type=int, default=10,
                       help="Number of concurrent users")
    parser.add_argument("--spawn-rate", type=float, default=2,
                       help="User spawn rate (users/second)")
    parser.add_argument("--duration", default="1m",
                       help="Test duration (e.g., 30s, 5m, 1h)")
    parser.add_argument("--install-deps", action="store_true",
                       help="Install dependencies before running tests")
    parser.add_argument("--multiple", action="store_true",
                       help="Run multiple scenarios sequentially")

    args = parser.parse_args()

    print("🎯 Agent Mitra Performance Testing Suite")
    print("=" * 50)

    # Install dependencies if requested
    if args.install_deps:
        if not install_dependencies():
            sys.exit(1)

    # Run tests
    if args.multiple:
        success = run_multiple_scenarios(host=args.host)
    else:
        success = run_load_test(
            scenario=args.scenario,
            users=args.users,
            spawn_rate=args.spawn_rate,
            duration=args.duration,
            host=args.host
        )

    if success:
        print("\n🎉 Performance testing completed successfully!")
        sys.exit(0)
    else:
        print("\n💥 Performance testing failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
