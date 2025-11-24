# FeatureHub Admin Service

Reusable Java service for programmatic FeatureHub feature flag management using the FeatureHub Admin SDK.

## Overview

This service provides a clean, reusable interface to the FeatureHub Admin SDK for creating and managing feature flags programmatically. It's designed to be used standalone or integrated into other projects.

## Features

- ✅ Create feature flags programmatically
- ✅ Set feature values for environments
- ✅ Bulk create default feature flags
- ✅ List features for an application
- ✅ Command-line interface (CLI)
- ✅ Reusable Java library

## Requirements

- Java 11 or higher
- Maven 3.6+

## Installation

### Build the Service

```bash
cd featurehub-admin-service
mvn clean package
```

This creates a standalone JAR file: `target/featurehub-admin-service-1.0.0.jar`

## Configuration

Set environment variables or pass as CLI arguments:

- `FEATUREHUB_ADMIN_SDK_URL`: Admin SDK base URL (e.g., `https://app.featurehub.io/vanilla/{id}`)
- `FEATUREHUB_ADMIN_TOKEN`: Admin service account access token
- `FEATUREHUB_APPLICATION_ID`: Application UUID
- `FEATUREHUB_ENVIRONMENT_ID`: Environment UUID (optional for listing)

## Usage

### Command-Line Interface

#### Create All Default Flags

```bash
java -jar target/featurehub-admin-service-1.0.0.jar create-all \
  --base-url https://app.featurehub.io/vanilla/913a7a7d-3523-4f7b-85ca-9564ad10e858 \
  --token jchXNvoni0GetAPN2byZ6SRt4OoDAEcJI8lfV0CC6yLDfdUI \
  --application-id 4538b168-ba55-4ae8-a815-f99f03fd630a \
  --environment-id IYGsPENvJifyLJZCXYdrsOToNTGke3*csNZJpKrCoMkHkmBkAyS
```

#### Create a Single Feature

```bash
java -jar target/featurehub-admin-service-1.0.0.jar create \
  phone_auth_enabled "Phone Authentication" \
  --description "Enable phone number-based authentication" \
  --type BOOLEAN \
  --value true \
  --base-url https://app.featurehub.io/vanilla/913a7a7d-3523-4f7b-85ca-9564ad10e858 \
  --token jchXNvoni0GetAPN2byZ6SRt4OoDAEcJI8lfV0CC6yLDfdUI \
  --application-id 4538b168-ba55-4ae8-a815-f99f03fd630a \
  --environment-id IYGsPENvJifyLJZCXYdrsOToNTGke3*csNZJpKrCoMkHkmBkAyS
```

#### List All Features

```bash
java -jar target/featurehub-admin-service-1.0.0.jar list \
  --base-url https://app.featurehub.io/vanilla/913a7a7d-3523-4f7b-85ca-9564ad10e858 \
  --token jchXNvoni0GetAPN2byZ6SRt4OoDAEcJI8lfV0CC6yLDfdUI \
  --application-id 4538b168-ba55-4ae8-a815-f99f03fd630a
```

### As a Java Library

```java
import com.agentmitra.featurehub.FeatureHubAdminService;
import io.featurehub.admin.model.FeatureValueType;
import java.util.UUID;

// Initialize service
FeatureHubAdminService service = new FeatureHubAdminService(
    "https://app.featurehub.io/vanilla/913a7a7d-3523-4f7b-85ca-9564ad10e858",
    "your-access-token"
);

// Create a feature
UUID appId = UUID.fromString("4538b168-ba55-4ae8-a815-f99f03fd630a");
Feature feature = service.createFeature(
    appId,
    "phone_auth_enabled",
    "Phone Authentication",
    "Enable phone number-based authentication",
    FeatureValueType.BOOLEAN
);

// Set feature value
UUID envId = UUID.fromString("environment-id");
UUID featureId = feature.getId();
service.setFeatureValue(envId, featureId, true, false);

// Create all default flags
Map<String, Object> results = service.createAllDefaultFlags(appId, envId);

// Cleanup
service.close();
```

## Default Feature Flags

The service creates 29 default feature flags:

### Authentication (6 flags)
- `phone_auth_enabled`
- `email_auth_enabled`
- `otp_verification_enabled`
- `biometric_auth_enabled`
- `mpin_auth_enabled`
- `agent_code_login_enabled`

### Core Features (5 flags)
- `dashboard_enabled`
- `policies_enabled`
- `payments_enabled` (default: false)
- `chat_enabled`
- `notifications_enabled`

### Presentation (6 flags)
- `presentation_carousel_enabled`
- `presentation_editor_enabled`
- `presentation_templates_enabled`
- `presentation_offline_mode_enabled`
- `presentation_analytics_enabled`
- `presentation_branding_enabled`

### Communication (3 flags)
- `whatsapp_integration_enabled`
- `chatbot_enabled`
- `callback_management_enabled`

### Analytics (3 flags)
- `analytics_enabled`
- `roi_dashboards_enabled`
- `smart_dashboards_enabled`

### Portal (3 flags)
- `portal_enabled`
- `data_import_enabled`
- `excel_template_config_enabled`

### Environment (3 flags)
- `debug_mode`
- `enable_logging`
- `development_tools_enabled`

## Integration with Python Backend

### Option 1: Call Java Service from Python

```python
import subprocess
import json

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

### Option 2: Use as Standalone Service

Run the Java service independently and integrate via API or file-based communication.

## Documentation

- [FeatureHub Admin SDK Documentation](https://docs.featurehub.io/featurehub/latest/admin-development-kit.html)
- [FeatureHub API Definition](https://docs.featurehub.io/featurehub/latest/api-definition.html)

## License

Same as parent project.

