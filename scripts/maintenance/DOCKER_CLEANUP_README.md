# Docker Cleanup Scripts for Automated Testing

## Problem
Automated testing with frequent Docker builds can quickly fill up disk space, causing builds to fail.

## Solution
Three cleanup scripts optimized for different scenarios:

### 1. `docker-cleanup-light.sh` - Lightweight Cleanup
**Best for:** Frequent automated testing
- Keeps base images intact
- Focuses on build cache and temporary resources
- Safe to run between test runs

**Usage:**
```bash
./docker-cleanup-light.sh
```

### 2. `docker-cleanup-test.sh` - Test-Optimized Cleanup
**Best for:** CI/CD pipelines with test containers
- Stops containers matching test patterns
- Removes old images (24h+)
- Comprehensive but selective cleanup

**Usage:**
```bash
./docker-cleanup-test.sh
```

### 3. `docker-cleanup.sh` - Full Cleanup
**Best for:** Manual maintenance or end of development sessions
- Removes everything possible
- Use with caution - may remove base images

**Usage:**
```bash
./docker-cleanup.sh
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
- name: Clean up Docker
  run: |
    chmod +x docker-cleanup-light.sh
    ./docker-cleanup-light.sh
  continue-on-error: true
```

### Jenkins Pipeline Example
```groovy
stage('Docker Cleanup') {
    steps {
        sh '''
            chmod +x docker-cleanup-light.sh
            ./docker-cleanup-light.sh
        '''
    }
}
```

## Monitoring Disk Usage

Check current Docker disk usage:
```bash
docker system df
```

Monitor disk space in scripts:
```bash
#!/bin/bash
# Check if disk space is getting low
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "Disk usage is ${DISK_USAGE}%, running cleanup..."
    ./docker-cleanup-light.sh
fi
```

## Current Status
- **Total images:** 13 (4.27GB)
- **Running containers:** 14 (keeping images from being pruned)
- **Build cache:** 0B (already optimized)

## Recommendations
1. **For automated testing:** Use `docker-cleanup-light.sh` between test runs
2. **For CI/CD:** Integrate `docker-cleanup-test.sh` in your pipeline
3. **Monitor regularly:** Check `docker system df` to track usage
4. **Schedule cleanup:** Run full cleanup during low-usage periods
