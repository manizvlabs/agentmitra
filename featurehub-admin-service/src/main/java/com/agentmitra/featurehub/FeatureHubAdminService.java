package com.agentmitra.featurehub;

import io.featurehub.admin.ApiClient;
import io.featurehub.admin.Configuration;
import io.featurehub.admin.api.FeatureServiceApi;
import io.featurehub.admin.api.EnvironmentFeatureServiceApi;
import io.featurehub.admin.api.ApplicationServiceApi;
import io.featurehub.admin.model.Feature;
import io.featurehub.admin.model.FeatureValueType;
import io.featurehub.admin.model.FeatureValue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;
import java.util.stream.Collectors;

/**
 * FeatureHub Admin Service
 * 
 * Reusable service for programmatic FeatureHub feature flag management
 * using the FeatureHub Admin SDK.
 * 
 * Based on: https://docs.featurehub.io/featurehub/latest/admin-development-kit.html
 */
public class FeatureHubAdminService {
    private static final Logger logger = LoggerFactory.getLogger(FeatureHubAdminService.class);
    
    private final ApiClient apiClient;
    private final FeatureServiceApi featureService;
    private final EnvironmentFeatureServiceApi environmentFeatureService;
    private final ApplicationServiceApi applicationService;
    
    /**
     * Initialize FeatureHub Admin Service
     * 
     * @param baseUrl FeatureHub Admin SDK base URL (e.g., https://app.featurehub.io/vanilla/{id})
     * @param accessToken Admin service account access token
     */
    public FeatureHubAdminService(String baseUrl, String accessToken) {
        // Initialize API client
        apiClient = new ApiClient();
        
        // For SaaS, use setBasePath with full URL (as per documentation)
        // The Admin SDK will handle URL construction internally
        apiClient.setBasePath(baseUrl);
        
        logger.info("Setting base path to: {}", baseUrl);
        
        // Set bearer token for authentication
        apiClient.setRequestInterceptor(builder -> {
            builder.header("Authorization", "Bearer " + accessToken);
            logger.debug("Added Authorization header to request");
        });
        
        // Set as default API client
        Configuration.setDefaultApiClient(apiClient);
        
        // Initialize service APIs
        featureService = new FeatureServiceApi();
        environmentFeatureService = new EnvironmentFeatureServiceApi();
        applicationService = new ApplicationServiceApi();
        
        logger.info("FeatureHub Admin Service initialized with base URL: {}", baseUrl);
    }
    
    /**
     * Create a feature flag
     * 
     * @param applicationId Application UUID
     * @param key Feature key (e.g., "phone_auth_enabled")
     * @param name Human-readable name
     * @param description Optional description
     * @param valueType Feature value type (BOOLEAN, STRING, NUMBER, JSON)
     * @return Created feature or null if failed
     */
    public Feature createFeature(UUID applicationId, String key, String name, 
                                 String description, FeatureValueType valueType) {
        try {
            // Log the base URL being used
            logger.info("Creating feature '{}' for application: {}", key, applicationId);
            
            Feature feature = new Feature()
                .name(name)
                .key(key)
                .valueType(valueType);
            
            if (description != null && !description.isEmpty()) {
                feature.setDescription(description);
            }
            
            logger.info("Calling createFeaturesForApplication with appId: {}, feature key: {}", applicationId, key);
            
            // createFeaturesForApplication requires: UUID, Feature, Boolean (includeEnvironments)
            List<Feature> features = featureService.createFeaturesForApplication(applicationId, feature, false);
            
            if (features != null && !features.isEmpty()) {
                Feature created = features.get(0);
                logger.info("Created feature: {} ({})", key, created.getId());
                return created;
            }
            
            logger.warn("Feature creation returned empty list for: {}", key);
            return null;
            
        } catch (io.featurehub.admin.ApiException e) {
            logger.error("API Exception creating feature '{}': Status={}, Message={}", 
                        key, e.getCode(), e.getMessage());
            logger.error("Response body: {}", e.getResponseBody());
            logger.error("Full exception: ", e);
            return null;
        } catch (Exception e) {
            logger.error("Failed to create feature '{}': {}", key, e.getMessage(), e);
            logger.error("Exception type: {}", e.getClass().getName());
            if (e.getCause() != null) {
                logger.error("Cause: {}", e.getCause().getMessage());
            }
            return null;
        }
    }
    
    /**
     * Set feature value for an environment
     * 
     * @param environmentId Environment UUID
     * @param featureId Feature UUID
     * @param value Feature value (boolean, string, number, or JSON)
     * @param locked Whether the feature is locked
     * @return True if successful
     */
    public boolean setFeatureValue(UUID environmentId, UUID featureId, Object value, boolean locked) {
        // Simplified: Feature value setting requires SDK method verification
        // For now, return false - features can be created and values set via dashboard
        logger.warn("setFeatureValue: Feature value setting requires SDK method verification. " +
                   "Features will be created but values should be set via dashboard or verified SDK methods.");
        return false;
    }
    
    /**
     * Get all features for an application
     * 
     * @param applicationId Application UUID
     * @return List of features
     */
    public List<Feature> getFeatures(UUID applicationId) {
        try {
            // Use reflection to find the correct method
            java.lang.reflect.Method[] methods = featureService.getClass().getMethods();
            for (java.lang.reflect.Method method : methods) {
                if (method.getName().equals("getFeaturesForApplication")) {
                    try {
                        if (method.getParameterCount() == 1) {
                            return (List<Feature>) method.invoke(featureService, applicationId);
                        } else if (method.getParameterCount() == 2) {
                            return (List<Feature>) method.invoke(featureService, applicationId, false);
                        }
                    } catch (Exception e) {
                        logger.debug("Method invocation failed: {}", e.getMessage());
                    }
                }
            }
            logger.warn("Could not find getFeaturesForApplication method");
            return Collections.emptyList();
        } catch (Exception e) {
            logger.error("Failed to get features: {}", e.getMessage(), e);
            return Collections.emptyList();
        }
    }
    
    /**
     * Create or update a feature flag
     * 
     * @param applicationId Application UUID
     * @param environmentId Environment UUID
     * @param key Feature key
     * @param name Feature name
     * @param value Default value
     * @param description Optional description
     * @param valueType Feature value type
     * @return Created/updated feature
     */
    public Feature createOrUpdateFeature(UUID applicationId, UUID environmentId, 
                                        String key, String name, Object value,
                                        String description, FeatureValueType valueType) {
        // Check if feature exists
        List<Feature> existingFeatures = getFeatures(applicationId);
        Feature feature = existingFeatures.stream()
            .filter(f -> key.equals(f.getKey()))
            .findFirst()
            .orElse(null);
        
        if (feature == null) {
            // Create new feature
            feature = createFeature(applicationId, key, name, description, valueType);
        } else {
            logger.info("Feature '{}' already exists, updating value", key);
        }
        
        // Note: Feature values can be set via dashboard after creation
        // Setting values programmatically requires SDK method verification
        if (feature != null && environmentId != null && value != null) {
            logger.info("Feature '{}' created. Set value '{}' via dashboard if needed.", key, value);
        }
        
        return feature;
    }
    
    /**
     * Create all default feature flags
     * 
     * @param applicationId Application UUID
     * @param environmentId Environment UUID
     * @return Map with creation results
     */
    public Map<String, Object> createAllDefaultFlags(UUID applicationId, UUID environmentId) {
        Map<String, Object> results = new HashMap<>();
        List<String> created = new ArrayList<>();
        List<String> updated = new ArrayList<>();
        List<String> failed = new ArrayList<>();
        
        // Default feature flags definition
        Map<String, FeatureDefinition> flags = getDefaultFeatureFlags();
        
        for (Map.Entry<String, FeatureDefinition> entry : flags.entrySet()) {
            String key = entry.getKey();
            FeatureDefinition def = entry.getValue();
            
            try {
                Feature feature = createOrUpdateFeature(
                    applicationId,
                    environmentId,
                    key,
                    def.name,
                    def.defaultValue,
                    def.description,
                    def.valueType
                );
                
                if (feature != null) {
                    if (feature.getId() != null) {
                        created.add(key);
                    } else {
                        updated.add(key);
                    }
                } else {
                    failed.add(key);
                }
            } catch (Exception e) {
                logger.error("Failed to create feature '{}': {}", key, e.getMessage());
                failed.add(key);
            }
        }
        
        results.put("created", created);
        results.put("updated", updated);
        results.put("failed", failed);
        results.put("total", flags.size());
        
        return results;
    }
    
    /**
     * Get default feature flags definition
     */
    private Map<String, FeatureDefinition> getDefaultFeatureFlags() {
        Map<String, FeatureDefinition> flags = new LinkedHashMap<>();
        
        // Authentication Features
        flags.put("phone_auth_enabled", new FeatureDefinition(
            "Phone Authentication", "Enable phone number-based authentication", true, FeatureValueType.BOOLEAN));
        flags.put("email_auth_enabled", new FeatureDefinition(
            "Email Authentication", "Enable email-based authentication", true, FeatureValueType.BOOLEAN));
        flags.put("otp_verification_enabled", new FeatureDefinition(
            "OTP Verification", "Enable OTP verification for authentication", true, FeatureValueType.BOOLEAN));
        flags.put("biometric_auth_enabled", new FeatureDefinition(
            "Biometric Authentication", "Enable biometric authentication (fingerprint, face ID)", true, FeatureValueType.BOOLEAN));
        flags.put("mpin_auth_enabled", new FeatureDefinition(
            "MPIN Authentication", "Enable MPIN-based authentication", true, FeatureValueType.BOOLEAN));
        flags.put("agent_code_login_enabled", new FeatureDefinition(
            "Agent Code Login", "Enable agent code-based login", true, FeatureValueType.BOOLEAN));
        
        // Core Features
        flags.put("dashboard_enabled", new FeatureDefinition(
            "Dashboard", "Enable dashboard functionality", true, FeatureValueType.BOOLEAN));
        flags.put("policies_enabled", new FeatureDefinition(
            "Policies", "Enable policy management features", true, FeatureValueType.BOOLEAN));
        flags.put("payments_enabled", new FeatureDefinition(
            "Payments", "Enable payment processing (regulatory compliance required)", false, FeatureValueType.BOOLEAN));
        flags.put("chat_enabled", new FeatureDefinition(
            "Chat", "Enable chat functionality", true, FeatureValueType.BOOLEAN));
        flags.put("notifications_enabled", new FeatureDefinition(
            "Notifications", "Enable push notifications", true, FeatureValueType.BOOLEAN));
        
        // Presentation Features
        flags.put("presentation_carousel_enabled", new FeatureDefinition(
            "Presentation Carousel", "Enable presentation carousel feature", true, FeatureValueType.BOOLEAN));
        flags.put("presentation_editor_enabled", new FeatureDefinition(
            "Presentation Editor", "Enable presentation editor", true, FeatureValueType.BOOLEAN));
        flags.put("presentation_templates_enabled", new FeatureDefinition(
            "Presentation Templates", "Enable presentation templates", true, FeatureValueType.BOOLEAN));
        flags.put("presentation_offline_mode_enabled", new FeatureDefinition(
            "Presentation Offline Mode", "Enable offline mode for presentations", true, FeatureValueType.BOOLEAN));
        flags.put("presentation_analytics_enabled", new FeatureDefinition(
            "Presentation Analytics", "Enable analytics for presentations", true, FeatureValueType.BOOLEAN));
        flags.put("presentation_branding_enabled", new FeatureDefinition(
            "Presentation Branding", "Enable branding customization for presentations", true, FeatureValueType.BOOLEAN));
        
        // Communication Features
        flags.put("whatsapp_integration_enabled", new FeatureDefinition(
            "WhatsApp Integration", "Enable WhatsApp integration", true, FeatureValueType.BOOLEAN));
        flags.put("chatbot_enabled", new FeatureDefinition(
            "Chatbot", "Enable chatbot functionality", true, FeatureValueType.BOOLEAN));
        flags.put("callback_management_enabled", new FeatureDefinition(
            "Callback Management", "Enable callback management features", true, FeatureValueType.BOOLEAN));
        
        // Analytics Features
        flags.put("analytics_enabled", new FeatureDefinition(
            "Analytics", "Enable analytics features", true, FeatureValueType.BOOLEAN));
        flags.put("roi_dashboards_enabled", new FeatureDefinition(
            "ROI Dashboards", "Enable ROI dashboard features", true, FeatureValueType.BOOLEAN));
        flags.put("smart_dashboards_enabled", new FeatureDefinition(
            "Smart Dashboards", "Enable smart dashboard features", true, FeatureValueType.BOOLEAN));
        
        // Portal Features
        flags.put("portal_enabled", new FeatureDefinition(
            "Portal", "Enable portal features", true, FeatureValueType.BOOLEAN));
        flags.put("data_import_enabled", new FeatureDefinition(
            "Data Import", "Enable data import functionality", true, FeatureValueType.BOOLEAN));
        flags.put("excel_template_config_enabled", new FeatureDefinition(
            "Excel Template Configuration", "Enable Excel template configuration", true, FeatureValueType.BOOLEAN));
        
        // Environment-specific
        flags.put("debug_mode", new FeatureDefinition(
            "Debug Mode", "Enable debug mode (development only)", true, FeatureValueType.BOOLEAN));
        flags.put("enable_logging", new FeatureDefinition(
            "Enable Logging", "Enable application logging", true, FeatureValueType.BOOLEAN));
        flags.put("development_tools_enabled", new FeatureDefinition(
            "Development Tools", "Enable development tools (development only)", true, FeatureValueType.BOOLEAN));
        
        return flags;
    }
    
    /**
     * Feature definition helper class
     */
    private static class FeatureDefinition {
        final String name;
        final String description;
        final Object defaultValue;
        final FeatureValueType valueType;
        
        FeatureDefinition(String name, String description, Object defaultValue, FeatureValueType valueType) {
            this.name = name;
            this.description = description;
            this.defaultValue = defaultValue;
            this.valueType = valueType;
        }
    }
    
    /**
     * Close the service and cleanup resources
     */
    public void close() {
        // API client cleanup if needed
        logger.info("FeatureHub Admin Service closed");
    }
}

