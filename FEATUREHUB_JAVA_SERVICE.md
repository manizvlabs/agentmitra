# FeatureHub Java Admin Service

## Overview

A reusable Java service for programmatic FeatureHub feature flag management using the FeatureHub Admin SDK. This service is designed to be used standalone or integrated into other projects.

## Location

`featurehub-admin-service/` - Standalone Java project outside Python backend

## Features

- ✅ Full FeatureHub Admin SDK integration
- ✅ Create feature flags programmatically
- ✅ Set feature values for environments
- ✅ Bulk create all 29 default feature flags
- ✅ List features for an application
- ✅ Command-line interface (CLI)
- ✅ Reusable Java library
- ✅ Standalone JAR with all dependencies

## Quick Start

### Build

```bash
cd featurehub-admin-service
mvn clean package
```

### Run

```bash
# Create all default flags
./scripts/create-featurehub-flags-java.sh

# Or manually:
java -jar featurehub-admin-service/target/featurehub-admin-service-1.0.0.jar create-all \
  --base-url https://app.featurehub.io/vanilla/913a7a7d-3523-4f7b-85ca-9564ad10e858 \
  --token jchXNvoni0GetAPN2byZ6SRt4OoDAEcJI8lfV0CC6yLDfdUI \
  --application-id 4538b168-ba55-4ae8-a815-f99f03fd630a \
  --environment-id IYGsPENvJifyLJZCXYdrsOToNTGke3*csNZJpKrCoMkHkmBkAyS
```

## Integration with Python Backend

### Option 1: Shell Script Integration

The `scripts/create-featurehub-flags-java.sh` script:
- Loads configuration from `backend/.env.local`
- Builds the Java service if needed
- Extracts application/environment IDs from SDK key
- Runs the Java service to create all flags

### Option 2: Python Subprocess

```python
import subprocess
import os

def create_featurehub_flags():
    result = subprocess.run([
        "java", "-jar",
        "featurehub-admin-service/target/featurehub-admin-service-1.0.0.jar",
        "create-all",
        "--base-url", os.getenv("FEATUREHUB_ADMIN_SDK_URL"),
        "--token", os.getenv("FEATUREHUB_ADMIN_TOKEN"),
        "--application-id", os.getenv("FEATUREHUB_APPLICATION_ID"),
        "--environment-id", os.getenv("FEATUREHUB_ENVIRONMENT_ID")
    ], capture_output=True, text=True)
    
    return result.returncode == 0
```

## Project Structure

```
featurehub-admin-service/
├── pom.xml                          # Maven configuration
├── README.md                        # Service documentation
├── src/
│   └── main/
│       ├── java/
│       │   └── com/agentmitra/featurehub/
│       │       ├── FeatureHubAdminService.java    # Main service class
│       │       └── FeatureHubAdminCli.java        # CLI interface
│       └── resources/
└── target/                          # Build output (gitignored)
    └── featurehub-admin-service-1.0.0.jar
```

## Usage Examples

### Create All Default Flags

```bash
java -jar featurehub-admin-service/target/featurehub-admin-service-1.0.0.jar create-all \
  --base-url $FEATUREHUB_ADMIN_SDK_URL \
  --token $FEATUREHUB_ADMIN_TOKEN \
  --application-id $FEATUREHUB_APPLICATION_ID \
  --environment-id $FEATUREHUB_ENVIRONMENT_ID
```

### Create Single Feature

```bash
java -jar featurehub-admin-service/target/featurehub-admin-service-1.0.0.jar create \
  phone_auth_enabled "Phone Authentication" \
  --description "Enable phone number-based authentication" \
  --type BOOLEAN \
  --value true \
  --base-url $FEATUREHUB_ADMIN_SDK_URL \
  --token $FEATUREHUB_ADMIN_TOKEN \
  --application-id $FEATUREHUB_APPLICATION_ID \
  --environment-id $FEATUREHUB_ENVIRONMENT_ID
```

### List Features

```bash
java -jar featurehub-admin-service/target/featurehub-admin-service-1.0.0.jar list \
  --base-url $FEATUREHUB_ADMIN_SDK_URL \
  --token $FEATUREHUB_ADMIN_TOKEN \
  --application-id $FEATUREHUB_APPLICATION_ID
```

## Configuration

The service reads configuration from:
1. Command-line arguments (highest priority)
2. Environment variables
3. `backend/.env.local` (via shell script)

Required:
- `FEATUREHUB_ADMIN_SDK_URL`: Admin SDK base URL
- `FEATUREHUB_ADMIN_TOKEN`: Admin service account access token
- `FEATUREHUB_APPLICATION_ID`: Application UUID (or from SDK key)
- `FEATUREHUB_ENVIRONMENT_ID`: Environment UUID (or from SDK key)

## Reusability

This service is designed to be reusable:

1. **Standalone JAR**: All dependencies included, can run anywhere
2. **Library**: Can be imported into other Java projects
3. **CLI**: Command-line interface for scripting
4. **No Dependencies**: Only requires Java 11+

## Dependencies

- FeatureHub Admin SDK (Java 11): `io.featurehub.mr.sdk:java11-admin-client`
- Gson: JSON processing
- SLF4J: Logging
- Picocli: CLI argument parsing

## Documentation

- [FeatureHub Admin SDK Documentation](https://docs.featurehub.io/featurehub/latest/admin-development-kit.html)
- [FeatureHub API Definition](https://docs.featurehub.io/featurehub/latest/api-definition.html)
- Service README: `featurehub-admin-service/README.md`

## Status

✅ **Service Created and Ready**

- Java service structure created
- Admin SDK integration implemented
- CLI interface ready
- Shell script integration ready
- Ready for testing and deployment

