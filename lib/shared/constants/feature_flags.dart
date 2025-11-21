/// Feature Flags Configuration
/// Controls feature availability at runtime
/// NO MOCK DATA - Use real data from database seed data only

class FeatureFlags {
  // Authentication Features
  static const bool phoneAuthEnabled = true;
  static const bool otpVerificationEnabled = true;
  static const bool biometricAuthEnabled = true;
  static const bool agentCodeLoginEnabled = true;

  // Core Features
  static const bool dashboardEnabled = true;
  static const bool policiesEnabled = true;
  static const bool paymentsEnabled = false; // DEFERRED - Regulatory compliance
  static const bool chatEnabled = true;
  static const bool notificationsEnabled = true;

  // Presentation Carousel Features
  static const bool presentationCarouselEnabled = true;
  static const bool presentationEditorEnabled = true;
  static const bool presentationTemplatesEnabled = true;
  static const bool presentationOfflineModeEnabled = true;
  static const bool presentationAnalyticsEnabled = true;
  static const bool presentationBrandingEnabled = true;

  // Communication Features
  static const bool whatsappIntegrationEnabled = true;
  static const bool chatbotEnabled = true;
  static const bool callbackManagementEnabled = true;

  // Analytics Features
  static const bool analyticsEnabled = true;
  static const bool roiDashboardsEnabled = true;
  static const bool smartDashboardsEnabled = true;

  // Portal Features
  static const bool portalEnabled = true;
  static const bool dataImportEnabled = true;
  static const bool excelTemplateConfigEnabled = true;

  // Data Strategy
  static const bool useMockData = false; // ALWAYS FALSE - Use seed data only
  static const bool useSeedData = true; // Use real seed data from database

  // Development Features
  static const bool debugMode = true; // Set to false in production
  static const bool enableLogging = true;
}

