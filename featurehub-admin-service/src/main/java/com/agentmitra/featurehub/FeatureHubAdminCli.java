package com.agentmitra.featurehub;

import io.featurehub.admin.model.Feature;
import io.featurehub.admin.model.FeatureValueType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

import java.util.*;
import java.util.concurrent.Callable;

/**
 * FeatureHub Admin CLI
 * 
 * Command-line interface for FeatureHub Admin operations
 */
@Command(name = "featurehub-admin", 
         mixinStandardHelpOptions = true,
         version = "1.0.0",
         description = "FeatureHub Admin Service - Programmatic feature flag management")
public class FeatureHubAdminCli implements Callable<Integer> {
    private static final Logger logger = LoggerFactory.getLogger(FeatureHubAdminCli.class);
    
    @Option(names = {"--base-url", "-u"}, 
            required = true,
            description = "FeatureHub Admin SDK base URL (e.g., https://app.featurehub.io/vanilla/{id})")
    private String baseUrl;
    
    @Option(names = {"--token", "-t"}, 
            required = true,
            description = "Admin service account access token")
    private String accessToken;
    
    @Option(names = {"--application-id", "-a"}, 
            required = true,
            description = "Application UUID")
    private String applicationId;
    
    @Option(names = {"--environment-id", "-e"}, 
            description = "Environment UUID (required for setting values)")
    private String environmentId;
    
    @Command(name = "create-all", description = "Create all default feature flags")
    public Integer createAll() {
        try {
            FeatureHubAdminService service = new FeatureHubAdminService(baseUrl, accessToken);
            UUID appId = UUID.fromString(applicationId);
            UUID envId = environmentId != null ? UUID.fromString(environmentId) : null;
            
            System.out.println("=".repeat(80));
            System.out.println("CREATING ALL DEFAULT FEATURE FLAGS");
            System.out.println("=".repeat(80));
            System.out.println("Application ID: " + appId);
            System.out.println("Environment ID: " + envId);
            System.out.println();
            
            Map<String, Object> results = service.createAllDefaultFlags(appId, envId);
            
            @SuppressWarnings("unchecked")
            List<String> created = (List<String>) results.get("created");
            @SuppressWarnings("unchecked")
            List<String> updated = (List<String>) results.get("updated");
            @SuppressWarnings("unchecked")
            List<String> failed = (List<String>) results.get("failed");
            
            System.out.println("=".repeat(80));
            System.out.println("RESULTS");
            System.out.println("=".repeat(80));
            System.out.println("✅ Created: " + created.size() + " flags");
            System.out.println("⚠️  Updated: " + updated.size() + " flags");
            System.out.println("❌ Failed: " + failed.size() + " flags");
            System.out.println("Total: " + results.get("total"));
            System.out.println();
            
            if (!created.isEmpty()) {
                System.out.println("Created flags:");
                created.forEach(flag -> System.out.println("  ✅ " + flag));
                System.out.println();
            }
            
            if (!updated.isEmpty()) {
                System.out.println("Updated flags:");
                updated.forEach(flag -> System.out.println("  ⚠️  " + flag));
                System.out.println();
            }
            
            if (!failed.isEmpty()) {
                System.out.println("Failed flags:");
                failed.forEach(flag -> System.out.println("  ❌ " + flag));
                System.out.println();
            }
            
            service.close();
            
            System.out.println("=".repeat(80));
            System.out.println("✅ Feature flag creation complete!");
            System.out.println("=".repeat(80));
            
            return failed.isEmpty() ? 0 : 1;
            
        } catch (Exception e) {
            logger.error("Error creating feature flags", e);
            System.err.println("❌ Error: " + e.getMessage());
            return 1;
        }
    }
    
    @Command(name = "create", description = "Create a single feature flag")
    public Integer create(
            @Parameters(index = "0", description = "Feature key") String key,
            @Parameters(index = "1", description = "Feature name") String name,
            @Option(names = {"--description", "-d"}, description = "Feature description") String description,
            @Option(names = {"--type", "-T"}, defaultValue = "BOOLEAN", 
                   description = "Feature type: BOOLEAN, STRING, NUMBER, JSON") String type,
            @Option(names = {"--value", "-v"}, description = "Default value") String value) {
        try {
            FeatureHubAdminService service = new FeatureHubAdminService(baseUrl, accessToken);
            UUID appId = UUID.fromString(applicationId);
            UUID envId = environmentId != null ? UUID.fromString(environmentId) : null;
            
            FeatureValueType valueType = FeatureValueType.valueOf(type.toUpperCase());
            Object defaultValue = value != null ? parseValue(value, valueType) : null;
            
            Feature feature = service.createOrUpdateFeature(
                appId, envId, key, name, defaultValue, description, valueType);
            
            if (feature != null) {
                System.out.println("✅ Created feature: " + key);
                System.out.println("   ID: " + feature.getId());
                System.out.println("   Name: " + feature.getName());
                return 0;
            } else {
                System.out.println("❌ Failed to create feature: " + key);
                return 1;
            }
        } catch (Exception e) {
            logger.error("Error creating feature", e);
            System.err.println("❌ Error: " + e.getMessage());
            return 1;
        }
    }
    
    @Command(name = "list", description = "List all features for an application")
    public Integer list() {
        try {
            FeatureHubAdminService service = new FeatureHubAdminService(baseUrl, accessToken);
            UUID appId = UUID.fromString(applicationId);
            
            List<Feature> features = service.getFeatures(appId);
            
            System.out.println("=".repeat(80));
            System.out.println("FEATURES FOR APPLICATION: " + appId);
            System.out.println("=".repeat(80));
            System.out.println("Total: " + features.size());
            System.out.println();
            
            features.forEach(feature -> {
                System.out.println("Key: " + feature.getKey());
                System.out.println("  Name: " + feature.getName());
                System.out.println("  Type: " + feature.getValueType());
                System.out.println("  ID: " + feature.getId());
                System.out.println();
            });
            
            service.close();
            return 0;
            
        } catch (Exception e) {
            logger.error("Error listing features", e);
            System.err.println("❌ Error: " + e.getMessage());
            return 1;
        }
    }
    
    @Override
    public Integer call() {
        // Default command - show help
        new CommandLine(this).usage(System.out);
        return 0;
    }
    
    private Object parseValue(String value, FeatureValueType type) {
        switch (type) {
            case BOOLEAN:
                return Boolean.parseBoolean(value);
            case NUMBER:
                if (value.contains(".")) {
                    return Double.parseDouble(value);
                }
                return Long.parseLong(value);
            case JSON:
                return value; // JSON string
            case STRING:
            default:
                return value;
        }
    }
    
    public static void main(String[] args) {
        int exitCode = new CommandLine(new FeatureHubAdminCli()).execute(args);
        System.exit(exitCode);
    }
}

