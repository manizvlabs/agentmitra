# Agent Mitra - Complete Pages & Screens Design

> **Note:** This document demonstrates [Separation of Concerns](./glossary.md#separation-of-concerns) through distinct UI/UX designs for mobile app, configuration portal, and LIC system interfaces.

## 1. Pages Design Philosophy & Architecture

### 1.1 Design System Principles
- **Mobile-First Responsive Design**: Optimized for mobile (375x667px) with tablet/desktop scaling
- **Progressive Enhancement**: Core functionality works on all devices, enhanced features on capable devices
- **Accessibility-First**: WCAG 2.1 AA compliance with screen reader support and keyboard navigation
- **Performance-Optimized**: Lazy loading, code splitting, and intelligent caching
- **Feature Flag Integration**: All pages conditionally rendered based on feature flags and permissions

### 1.2 Page Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT MITRA - PAGE ARCHITECTURE               │
├─────────────────────────────────────────────────────────────────┤
│  📱 Mobile Pages (Primary Focus)                               │
│  ├── Flutter Material Design 3.0 (Android)                     │
│  ├── Cupertino Design (iOS)                                   │
│  ├── Responsive Layouts (Adaptive to screen size)             │
│  └── Touch-Optimized (48pt minimum touch targets)             │
├─────────────────────────────────────────────────────────────────┤
│  💻 Web Pages (Progressive Web App)                            │
│  ├── React-based SPA (Future enhancement)                     │
│  ├── Responsive Design (Desktop/Mobile)                       │
│  ├── Offline Support (Service Workers)                        │
│  └── Cross-Platform Consistency                              │
├─────────────────────────────────────────────────────────────────┤
│  🎨 Design System Components                                   │
│  ├── Atomic Design Methodology                                 │
│  ├── Reusable Component Library                               │
│  ├── Theme-Based Styling (CSS Variables)                     │
│  └── Internationalization Support                            │
├─────────────────────────────────────────────────────────────────┤
│  🔒 Security & Performance                                     │
│  ├── RBAC Permission Checking                                 │
│  ├── Feature Flag Validation                                  │
│  ├── Lazy Loading & Code Splitting                           │
│  └── Error Boundaries & Graceful Degradation                 │
└─────────────────────────────────────────────────────────────────┘
```

## 1.5 CDN-Based Multilingual Support & Localization

### Flutter Internationalization Architecture
```
🌐 CDN-BASED MULTILINGUAL SUPPORT ARCHITECTURE

📁 Project Structure:
├── lib/
│   ├── services/
│   │   ├── localization_service.dart    # CDN localization loader
│   │   └── cdn_service.dart              # CDN communication service
│   ├── generated/
│   │   └── l10n/
│   │       ├── app_localizations.dart   # Generated fallback
│   │       └── app_localizations_en.dart
│   └── main.dart

🔧 Dependencies (pubspec.yaml):
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  http: ^1.1.0
  shared_preferences: ^2.2.0

flutter:
  generate: true
  assets:
    - assets/l10n/  # Fallback ARB files for offline

🌐 CDN Architecture:
├── CDN URLs:
│   ├── https://cdn.agentmitra.com/l10n/v1/app_en.arb
│   ├── https://cdn.agentmitra.com/l10n/v1/app_hi.arb
│   └── https://cdn.agentmitra.com/l10n/v1/app_te.arb
├── Cache Strategy: Local storage with version checking
├── Update Mechanism: Background sync with app updates
└── Fallback: Bundled ARB files for offline/critical strings
```

### ARB File Structure & CDN Content Keys

#### Base ARB File Structure
```json
// https://cdn.agentmitra.com/l10n/v1/app_en.arb
{
  "@@locale": "en",
  "@@lastModified": "2025-01-03T10:00:00Z",
  "@@version": "1.0.0",

  // App Common Strings
  "appName": "Agent Mitra",
  "@appName": {
    "description": "Application name displayed in app",
    "type": "text"
  },

  "tagline": "Friend of Agents",
  "@tagline": {
    "description": "App tagline",
    "type": "text"
  },

  // Navigation & Common UI
  "home": "Home",
  "@home": {
    "description": "Home navigation label",
    "type": "text"
  },

  "policies": "My Policies",
  "@policies": {
    "description": "Policies section label",
    "type": "text"
  },

  "chat": "Chat",
  "@chat": {
    "description": "Chat section label",
    "type": "text"
  },

  "settings": "Settings",
  "@settings": {
    "description": "Settings section label",
    "type": "text"
  },

  // Authentication Strings
  "welcomeBack": "Welcome back, {name}!",
  "@welcomeBack": {
    "description": "Welcome message with user name",
    "type": "text",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "Rajesh"
      }
    }
  },

  "login": "Login",
  "@login": {
    "description": "Login button text",
    "type": "text"
  },

  "phoneNumber": "Phone Number",
  "@phoneNumber": {
    "description": "Phone number input label",
    "type": "text"
  },

  // Dashboard Strings
  "totalRevenue": "Total Revenue",
  "@totalRevenue": {
    "description": "Revenue metric label",
    "type": "text"
  },

  "activePolicies": "Active Policies",
  "@activePolicies": {
    "description": "Active policies count label",
    "type": "text"
  },

  // Chatbot Strings
  "chatbotGreeting": "Hi! I'm your Policy Assistant. How can I help?",
  "@chatbotGreeting": {
    "description": "Chatbot welcome message",
    "type": "text"
  },

  "callAgent": "Call Agent",
  "@callAgent": {
    "description": "Agent callback request button",
    "type": "text"
  },

  "agentWillCallBack": "Agent will call you back soon",
  "@agentWillCallBack": {
    "description": "Callback confirmation message",
    "type": "text"
  },

  // Error Messages
  "networkError": "Network connection error. Please try again.",
  "@networkError": {
    "description": "Network error message",
    "type": "text"
  },

  "retry": "Retry",
  "@retry": {
    "description": "Retry button text",
    "type": "text"
  }
}
```

#### Hindi ARB File (app_hi.arb)
```json
{
  "@@locale": "hi",
  "@@lastModified": "2025-01-03T10:00:00Z",
  "@@version": "1.0.0",

  "appName": "एजेंट मित्र",
  "@appName": {
    "description": "एप्लिकेशन का नाम",
    "type": "text"
  },

  "tagline": "एजेंटों का दोस्त",
  "@tagline": {
    "description": "एप्लिकेशन का टैगलाइन",
    "type": "text"
  },

  "home": "होम",
  "@home": {
    "description": "होम नेविगेशन लेबल",
    "type": "text"
  },

  "policies": "मेरी पॉलिसियां",
  "@policies": {
    "description": "पॉलिसी सेक्शन लेबल",
    "type": "text"
  },

  "welcomeBack": "वापसी पर स्वागत है, {name}!",
  "@welcomeBack": {
    "description": "उपयोगकर्ता नाम के साथ स्वागत संदेश",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "राजेश"
      }
    }
  }
}
```

#### Telugu ARB File (app_te.arb)
```json
{
  "@@locale": "te",
  "@@lastModified": "2025-01-03T10:00:00Z",
  "@@version": "1.0.0",

  "appName": "ఏజెంట్ మిత్ర",
  "@appName": {
    "description": "అప్లికేషన్ పేరు",
    "type": "text"
  },

  "tagline": "ఏజెంట్ల మిత్రుడు",
  "@tagline": {
    "description": "అప్ ట్యాగ్‌లైన్",
    "type": "text"
  },

  "home": "హోమ్",
  "@home": {
    "description": "హోమ్ నావిగేషన్ లేబుల్",
    "type": "text"
  },

  "policies": "నా పాలసీలు",
  "@policies": {
    "description": "పాలసీ విభాగం లేబుల్",
    "type": "text"
  }
}
```

### CDN Localization Service Implementation

#### Localization Service Architecture
```dart
// lib/services/localization_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class LocalizationService {
  static const String cdnBaseUrl = 'https://cdn.agentmitra.com/l10n/v1';
  static const String versionKey = 'localization_version';
  static const String cacheKeyPrefix = 'l10n_cache_';

  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  final Map<String, Map<String, String>> _localizedStrings = {};
  final Map<String, String> _fallbackStrings = {};

  // CDN version checking
  Future<bool> checkForUpdates(String locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion = prefs.getString('$versionKey_$locale') ?? '0.0.0';

      final response = await http.get(
        Uri.parse('$cdnBaseUrl/app_$locale.arb'),
        headers: {'Cache-Control': 'no-cache'},
      );

      if (response.statusCode == 200) {
        final arbData = json.decode(response.body);
        final cdnVersion = arbData['@@version'] ?? '1.0.0';

        return _isNewerVersion(cdnVersion, currentVersion);
      }
    } catch (e) {
      debugPrint('Failed to check localization updates: $e');
    }
    return false;
  }

  // Load localization from CDN with fallback
  Future<Map<String, String>> loadLocalization(String locale) async {
    // Try CDN first
    try {
      final cdnStrings = await _loadFromCDN(locale);
      if (cdnStrings.isNotEmpty) {
        _localizedStrings[locale] = cdnStrings;
        await _cacheLocalization(locale, cdnStrings);
        return cdnStrings;
      }
    } catch (e) {
      debugPrint('CDN load failed, using cache: $e');
    }

    // Try cache
    try {
      final cachedStrings = await _loadFromCache(locale);
      if (cachedStrings.isNotEmpty) {
        _localizedStrings[locale] = cachedStrings;
        return cachedStrings;
      }
    } catch (e) {
      debugPrint('Cache load failed, using fallback: $e');
    }

    // Use bundled fallback
    return await _loadFallbackLocalization(locale);
  }

  Future<Map<String, String>> _loadFromCDN(String locale) async {
    final response = await http.get(
      Uri.parse('$cdnBaseUrl/app_$locale.arb'),
      headers: {
        'Cache-Control': 'no-cache',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final arbData = json.decode(response.body);
      final strings = <String, String>{};

      arbData.forEach((key, value) {
        if (!key.startsWith('@')) {
          strings[key] = value.toString();
        }
      });

      // Cache version info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$versionKey_$locale', arbData['@@version'] ?? '1.0.0');

      return strings;
    }

    throw Exception('Failed to load from CDN');
  }

  Future<Map<String, String>> _loadFromCache(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('$cacheKeyPrefix$locale');

    if (cachedData != null) {
      return Map<String, String>.from(json.decode(cachedData));
    }

    return {};
  }

  Future<Map<String, String>> _loadFallbackLocalization(String locale) async {
    try {
      final jsonString = await rootBundle.loadString('assets/l10n/app_$locale.arb');
      final arbData = json.decode(jsonString);
      final strings = <String, String>{};

      arbData.forEach((key, value) {
        if (!key.startsWith('@')) {
          strings[key] = value.toString();
        }
      });

      _fallbackStrings.addAll(strings);
      return strings;
    } catch (e) {
      debugPrint('Fallback localization failed: $e');
      return {};
    }
  }

  Future<void> _cacheLocalization(String locale, Map<String, String> strings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$cacheKeyPrefix$locale', json.encode(strings));
  }

  // Get localized string with fallback
  String getString(String key, {String? locale, Map<String, String>? placeholders}) {
    final currentLocale = locale ?? 'en'; // Default fallback

    // Try current locale
    var localizedString = _localizedStrings[currentLocale]?[key];

    // Try fallback strings
    localizedString ??= _fallbackStrings[key];

    // Try English fallback
    localizedString ??= _localizedStrings['en']?[key] ?? key;

    // Apply placeholders
    if (placeholders != null && localizedString != null) {
      placeholders.forEach((placeholder, value) {
        localizedString = localizedString!.replaceAll('{$placeholder}', value);
      });
    }

    return localizedString ?? key;
  }

  // Background sync for updates
  Future<void> syncLocalizations(List<String> locales) async {
    for (final locale in locales) {
      if (await checkForUpdates(locale)) {
        await loadLocalization(locale);
      }
    }
  }

  bool _isNewerVersion(String newVersion, String currentVersion) {
    final newParts = newVersion.split('.').map(int.parse).toList();
    final currentParts = currentVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      if (newParts[i] > currentParts[i]) return true;
      if (newParts[i] < currentParts[i]) return false;
    }
    return false;
  }
}
```

### App-Level Localization Integration

#### Main.dart Localization Setup
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/localization_service.dart';
import 'services/auth_service.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization service
  final localizationService = LocalizationService();

  // Pre-load common locales
  await Future.wait([
    localizationService.loadLocalization('en'),
    localizationService.loadLocalization('hi'),
    localizationService.loadLocalization('te'),
  ]);

  // Background sync for updates
  localizationService.syncLocalizations(['en', 'hi', 'te']);

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalizationService>.value(value: localizationService),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const AgentMitraApp(),
    ),
  );
}

class AgentMitraApp extends StatefulWidget {
  const AgentMitraApp({Key? key}) : super(key: key);

  @override
  State<AgentMitraApp> createState() => _AgentMitraAppState();
}

class _AgentMitraAppState extends State<AgentMitraApp> {
  Locale _locale = const Locale('en');

  void _changeLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agent Mitra',
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
        Locale('te', ''), // Telugu
      ],
      localizationsDelegates: const [
        // Use custom localization delegate
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // CDN-based locale resolution
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first; // Default to English
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRoutes.welcome,
    );
  }
}

// Custom localization delegate for CDN integration
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizationService = LocalizationService();
    final strings = await localizationService.loadLocalization(locale.languageCode);
    return AppLocalizations(locale, strings);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

// App localizations wrapper
class AppLocalizations {
  final Locale locale;
  final Map<String, String> _localizedStrings;
  final LocalizationService _service;

  AppLocalizations(this.locale, this._localizedStrings)
      : _service = LocalizationService();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String getString(String key, {Map<String, String>? placeholders}) {
    return _service.getString(key, locale: locale.languageCode, placeholders: placeholders);
  }

  // Convenience getters for common strings
  String get appName => getString('appName');
  String get home => getString('home');
  String get policies => getString('policies');
  String get chat => getString('chat');
  String get settings => getString('settings');

  String welcomeBack(String name) => getString('welcomeBack', placeholders: {'name': name});
  String get login => getString('login');
  String get callAgent => getString('callAgent');
  String get agentWillCallBack => getString('agentWillCallBack');
}
```

### Widget-Level Localization Usage

#### Localized Widget Examples
```dart
// lib/widgets/localized_text.dart
import 'package:flutter/material.dart';
import '../main.dart';

class LocalizedText extends StatelessWidget {
  final String key;
  final Map<String, String>? placeholders;
  final TextStyle? style;
  final TextAlign? textAlign;

  const LocalizedText(
    this.key, {
    this.placeholders,
    this.style,
    this.textAlign,
    Key? super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final text = localizations?.getString(key, placeholders: placeholders) ?? key;

    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }
}

// Usage in pages
class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: LocalizedText('appName'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LocalizedText(
              'welcomeBack',
              placeholders: {'name': 'Rajesh'},
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            LocalizedText('tagline'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {},
              child: LocalizedText('login'),
            ),
          ],
        ),
      ),
    );
  }
}

// Chatbot interface with localization
class ChatbotInterface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              // Chat messages would go here
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.getString('typeMessage') ?? 'Type your message...',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Trigger agent callback
                },
                child: LocalizedText('callAgent'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

### CDN Configuration & Management

#### Localization Configuration
```yaml
# config/localization_config.yaml
cdn:
  base_url: "https://cdn.agentmitra.com/l10n"
  version: "v1"
  cache_ttl_hours: 24

locales:
  - code: "en"
    name: "English"
    flag: "🇺🇸"
    rtl: false
  - code: "hi"
    name: "हिन्दी"
    flag: "🇮🇳"
    rtl: false
  - code: "te"
    name: "తెలుగు"
    flag: "🇮🇳"
    rtl: false

features:
  auto_update: true
  background_sync: true
  offline_fallback: true
  version_checking: true
```

#### CDN Deployment Strategy
```
🌐 CDN LOCALIZATION DEPLOYMENT

📦 Content Management:
├── ARB File Generation: Automated from CMS
├── Version Control: Semantic versioning (1.0.0, 1.0.1, etc.)
├── CDN Invalidation: Automatic on updates
└── Rollback Support: Version-based file serving

🔄 Update Flow:
├── CMS Update → ARB Generation → CDN Upload
├── App Version Check → Background Download
├── Cache Update → UI Refresh (if needed)
└── Offline Fallback → Bundled Files

📊 Monitoring:
├── Download Success Rate
├── Cache Hit Ratio
├── Update Adoption Rate
└── Error Reporting
```

### Feature Flag Integration

#### Localization Feature Flags
```dart
// Feature flags for localization
const localizationFeatureFlags = {
  'cdn_localization_enabled': true,           // Enable CDN-based localization
  'background_sync_enabled': true,            // Background localization updates
  'offline_fallback_enabled': true,           // Offline ARB file fallback
  'multi_language_chatbot': true,              // Chatbot language switching
  'dynamic_content_updates': true,            // Real-time content updates
  'locale_persistence': true,                 // Remember user language choice
};
```

## 2. Authentication & Onboarding Pages

### 2.1 Authentication Flow Pages

#### Welcome & Trial Onboarding Page
```dart
// Flutter page implementation
class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isAuthenticated = await authService.isAuthenticated();

    if (isAuthenticated) {
      // Navigate to appropriate dashboard based on user role
      final user = await authService.getCurrentUser();
      switch (user.role) {
        case 'policyholder':
          Navigator.pushReplacementNamed(context, '/customer-dashboard');
          break;
        case 'agent':
          Navigator.pushReplacementNamed(context, '/agent-dashboard');
          break;
        case 'provider_admin':
          Navigator.pushReplacementNamed(context, '/provider-dashboard');
          break;
        case 'super_admin':
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/trial-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and branding
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.insurance,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Welcome text
                  Text(
                    'Welcome to Agent Mitra',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Connect with your insurance agent and manage your policies with ease',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Trial offer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          color: Colors.green.shade600,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '14-Day Free Trial',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'No credit card required • Full access to all features',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/trial-signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Get Started Free',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Already have an account? Sign In',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Phone Number Registration Page
```dart
class PhoneRegistrationPage extends StatefulWidget {
  @override
  _PhoneRegistrationPageState createState() => _PhoneRegistrationPageState();
}

class _PhoneRegistrationPageState extends State<PhoneRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Agent Mitra'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your mobile number',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll send you an OTP to verify your number',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 48),

                // Phone number input
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: '9876543210',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),

                // Terms and conditions
                Row(
                  children: [
                    Checkbox(
                      value: true, // This should be a state variable
                      onChanged: (value) {
                        // Handle terms acceptance
                      },
                    ),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send OTP',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final phoneNumber = '+91${_phoneController.text.trim()}';
      await AuthService.sendOTP(phoneNumber);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(phoneNumber: phoneNumber),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

#### OTP Verification Page
```dart
class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendCooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter verification code',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 48),

              // OTP input field
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: '123456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 32),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _resendCooldown > 0
                        ? 'Resend OTP in $_resendCooldown seconds'
                        : 'Didn\'t receive OTP?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_resendCooldown == 0) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _handleResendOTP,
                      child: Text(
                        'Resend',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 48),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Alternative verification
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PhoneRegistrationPage()),
                  ),
                  child: Text(
                    'Use different number',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleVerifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.verifyOTP(widget.phoneNumber, _otpController.text);

      // Navigate to trial setup or main dashboard based on user status
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TrialSetupPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResendOTP() async {
    setState(() => _resendCooldown = 30);
    _startResendTimer();

    try {
      await AuthService.sendOTP(widget.phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending OTP: $e')),
      );
    }
  }
}
```

### 2.2 Trial Setup & Profile Creation Pages

#### Trial Setup Page
```dart
class TrialSetupPage extends StatefulWidget {
  @override
  _TrialSetupPageState createState() => _TrialSetupPageState();
}

class _TrialSetupPageState extends State<TrialSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'policyholder';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trial banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration,
                          color: Colors.green.shade600,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🎉 14-Day Free Trial Activated!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Trial ends on ${DateTime.now().add(const Duration(days: 14)).toString().split(' ')[0]}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Complete your profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us personalize your experience',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address (Optional)',
                      hintText: 'your.email@example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),

                  // Role selection
                  Text(
                    'I am a:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          'Policyholder',
                          'I want to manage my insurance policies',
                          Icons.person,
                          _selectedRole == 'policyholder',
                          () => setState(() => _selectedRole = 'policyholder'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRoleCard(
                          'Insurance Agent',
                          'I want to manage customers and sell policies',
                          Icons.business_center,
                          _selectedRole == 'agent',
                          () => setState(() => _selectedRole = 'agent'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Start My Trial',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String title, String subtitle, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = UserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        role: _selectedRole,
        trialStartDate: DateTime.now(),
        trialEndDate: DateTime.now().add(const Duration(days: 14)),
      );

      await AuthService.completeProfile(profile);

      // Navigate to appropriate dashboard based on role
      switch (_selectedRole) {
        case 'policyholder':
          Navigator.pushReplacementNamed(context, '/customer-dashboard');
          break;
        case 'agent':
          Navigator.pushReplacementNamed(context, '/agent-dashboard');
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

## 3. Customer Portal Pages

### 3.1 Customer Dashboard Page

#### Main Dashboard Implementation
```dart
class CustomerDashboardPage extends StatefulWidget {
  @override
  _CustomerDashboardPageState createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  late DashboardViewModel _viewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.getCurrentUser();

      _viewModel = await DashboardService.buildCustomerDashboard(user);
      setState(() => _isLoading = false);
    } catch (e) {
      // Handle error - show error state or retry
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Agent Mitra',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Theme switcher
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                themeProvider.toggleTheme();
              },
            ),
            // Global search
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showGlobalSearch(),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                _buildWelcomeHeader(),

                const SizedBox(height: 24),

                // Quick actions
                _buildQuickActions(),

                const SizedBox(height: 24),

                // Policy overview
                _buildPolicyOverview(),

                const SizedBox(height: 24),

                // Critical notifications
                _buildCriticalNotifications(),

                const SizedBox(height: 24),

                // Quick insights
                _buildQuickInsights(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${_viewModel.userName}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Today: ${DateTime.now().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Notification bell
        IconButton(
          icon: Badge(
            badgeContent: Text(
              '${_viewModel.notificationCount}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildActionCard(
              'Pay Premium',
              Icons.payment,
              Colors.green,
              () => Navigator.pushNamed(context, '/premium-payment'),
            ),
            const SizedBox(width: 16),
            _buildActionCard(
              'Contact Agent',
              Icons.phone,
              Colors.blue,
              () => Navigator.pushNamed(context, '/contact-agent'),
            ),
            const SizedBox(width: 16),
            _buildActionCard(
              'Get Quote',
              Icons.request_quote,
              Colors.orange,
              () => Navigator.pushNamed(context, '/get-quote'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Policy Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Active Policies',
                  '${_viewModel.activePolicies}',
                  Icons.assignment,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Next Payment',
                  '₹${_viewModel.nextPaymentAmount}',
                  Icons.payment,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Total Coverage',
                  '₹${_viewModel.totalCoverage}',
                  Icons.security,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalNotifications() {
    if (_viewModel.criticalNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(
                'Important Notifications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._viewModel.criticalNotifications.map((notification) =>
            _buildNotificationItem(notification)
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.priority == 'high'
            ? Colors.red.shade100
            : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            notification.priority == 'high'
                ? Icons.error
                : Icons.warning,
            color: notification.priority == 'high'
                ? Colors.red.shade600
                : Colors.orange.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notification.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: notification.priority == 'high'
                    ? Colors.red.shade800
                    : Colors.orange.shade800,
              ),
            ),
          ),
          if (notification.actionUrl != null)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, notification.actionUrl!),
              child: Text(
                'View',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'Premium History',
                'On-time payments: 36 months',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInsightCard(
                'Investment Growth',
                '+18% annual growth',
                Icons.show_chart,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      currentIndex: 0, // Dashboard is current
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Navigator.pushNamed(context, '/policies');
            break;
          case 2:
            Navigator.pushNamed(context, '/chat');
            break;
          case 3:
            Navigator.pushNamed(context, '/learning');
            break;
          case 4:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Policies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Learn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _showGlobalSearch() {
    showSearch(
      context: context,
      delegate: GlobalSearchDelegate(),
    );
  }
}

// Global search delegate
class GlobalSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchSuggestions(context, query);
  }

  Widget _buildSearchResults(BuildContext context, String query) {
    // Implement actual search results
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  Widget _buildSearchSuggestions(BuildContext context, String query) {
    // Implement search suggestions
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.search),
          title: Text('Search policies...'),
          onTap: () => Navigator.pushNamed(context, '/policies'),
        ),
        ListTile(
          leading: const Icon(Icons.payment),
          title: Text('Pay premium'),
          onTap: () => Navigator.pushNamed(context, '/premium-payment'),
        ),
        ListTile(
          leading: const Icon(Icons.school),
          title: Text('Learning center'),
          onTap: () => Navigator.pushNamed(context, '/learning'),
        ),
      ],
    );
  }
}
```

### 3.2 Policy Management Pages

#### Policies List Page
```dart
class PoliciesPage extends StatefulWidget {
  @override
  _PoliciesPageState createState() => _PoliciesPageState();
}

class _PoliciesPageState extends State<PoliciesPage> {
  late PoliciesViewModel _viewModel;
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.getCurrentUser();

      _viewModel = await PoliciesService.getUserPolicies(user.id);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Policies'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),

          // Policies list
          Expanded(
            child: _buildPoliciesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/get-quote'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Active', 'active'),
            const SizedBox(width: 8),
            _buildFilterChip('Maturing', 'maturing'),
            const SizedBox(width: 8),
            _buildFilterChip('Lapsed', 'lapsed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildPoliciesList() {
    final filteredPolicies = _viewModel.policies.where((policy) {
      final matchesFilter = _selectedFilter == 'all' || policy.status == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          policy.policyNumber.contains(_searchQuery) ||
          policy.planName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    if (filteredPolicies.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredPolicies.length,
      itemBuilder: (context, index) {
        return _buildPolicyCard(filteredPolicies[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No policies found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get a quote for your first policy',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/get-quote'),
            child: const Text('Get Quote'),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(Policy policy) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PolicyDetailsPage(policy: policy),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy.planName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Policy No: ${policy.policyNumber}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(policy.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPolicyMetric(
                      'Premium',
                      '₹${policy.premiumAmount}',
                      Icons.currency_rupee,
                    ),
                  ),
                  Expanded(
                    child: _buildPolicyMetric(
                      'Coverage',
                      '₹${policy.sumAssured}',
                      Icons.security,
                    ),
                  ),
                  Expanded(
                    child: _buildPolicyMetric(
                      'Next Due',
                      policy.nextDueDate,
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PolicyDetailsPage(policy: policy),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handlePayPremium(policy),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Pay Premium'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'maturing':
        color = Colors.blue;
        label = 'Maturing';
        break;
      case 'lapsed':
        color = Colors.red;
        label = 'Lapsed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: PolicySearchDelegate(_viewModel.policies),
    );
  }

  void _showFilterOptions() {
    // Show filter bottom sheet
  }

  void _handlePayPremium(Policy policy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PremiumPaymentPage(policy: policy),
      ),
    );
  }
}
```

#### Policy Details Page
```dart
class PolicyDetailsPage extends StatefulWidget {
  final Policy policy;

  const PolicyDetailsPage({Key? key, required this.policy}) : super(key: key);

  @override
  _PolicyDetailsPageState createState() => _PolicyDetailsPageState();
}

class _PolicyDetailsPageState extends State<PolicyDetailsPage> {
  late PolicyDetailsViewModel _viewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolicyDetails();
  }

  Future<void> _loadPolicyDetails() async {
    try {
      _viewModel = await PolicyDetailsService.getPolicyDetails(widget.policy.policyId);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.policy.planName),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePolicyDetails,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPolicyDocument,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Policy header card
              _buildPolicyHeader(),

              const SizedBox(height: 24),

              // Basic information
              _buildSectionCard(
                'Basic Information',
                _buildBasicInfoSection(),
              ),

              const SizedBox(height: 16),

              // Premium & payment
              _buildSectionCard(
                'Premium & Payment',
                _buildPaymentSection(),
              ),

              const SizedBox(height: 16),

              // Coverage & benefits
              _buildSectionCard(
                'Coverage & Benefits',
                _buildCoverageSection(),
              ),

              const SizedBox(height: 16),

              // Personal details
              _buildSectionCard(
                'Personal Details',
                _buildPersonalDetailsSection(),
              ),

              const SizedBox(height: 16),

              // Documents
              _buildSectionCard(
                'Documents',
                _buildDocumentsSection(),
              ),

              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.policy.planName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Policy No: ${widget.policy.policyNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Started: ${widget.policy.startDate}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildStatusChip(widget.policy.status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'maturing':
        color = Colors.blue;
        label = 'Maturing';
        break;
      case 'lapsed':
        color = Colors.red;
        label = 'Lapsed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildInfoRow('Plan Name', widget.policy.planName),
        const SizedBox(height: 12),
        _buildInfoRow('Policy Type', widget.policy.policyType),
        const SizedBox(height: 12),
        _buildInfoRow('Agent', _viewModel.agentName),
        const SizedBox(height: 12),
        _buildInfoRow('Issue Date', widget.policy.startDate),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      children: [
        _buildInfoRow('Annual Premium', '₹${widget.policy.premiumAmount}'),
        const SizedBox(height: 12),
        _buildInfoRow('Payment Frequency', widget.policy.premiumFrequency),
        const SizedBox(height: 12),
        _buildInfoRow('Next Due Date', widget.policy.nextDueDate),
        const SizedBox(height: 12),
        _buildInfoRow('Payment Method', _viewModel.paymentMethod),
        const SizedBox(height: 12),
        if (_viewModel.paymentHistory.isNotEmpty)
          _buildPaymentHistory(),
      ],
    );
  }

  Widget _buildCoverageSection() {
    return Column(
      children: [
        _buildInfoRow('Sum Assured', '₹${widget.policy.sumAssured}'),
        const SizedBox(height: 12),
        _buildInfoRow('Bonus Accumulated', '₹${_viewModel.bonusAmount}'),
        const SizedBox(height: 12),
        _buildInfoRow('Maturity Date', widget.policy.maturityDate),
        const SizedBox(height: 12),
        _buildInfoRow('Maturity Benefit', '₹${_viewModel.expectedMaturityAmount}'),
        const SizedBox(height: 12),
        if (_viewModel.riders.isNotEmpty)
          _buildRidersSection(),
      ],
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Column(
      children: [
        _buildInfoRow('Policyholder', _viewModel.policyholderName),
        const SizedBox(height: 12),
        _buildInfoRow('Nominee', _viewModel.nomineeName),
        const SizedBox(height: 12),
        _buildInfoRow('Address', _viewModel.policyholderAddress),
        const SizedBox(height: 12),
        _buildInfoRow('Contact', _viewModel.policyholderContact),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Documents',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._viewModel.documents.map((document) =>
          _buildDocumentItem(document)
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._viewModel.paymentHistory.take(3).map((payment) =>
          _buildPaymentHistoryItem(payment)
        ),
        if (_viewModel.paymentHistory.length > 3)
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/payment-history'),
            child: Text(
              'View All Payments',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentHistoryItem(PaymentHistory payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${payment.amount}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  payment.date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: payment.status == 'paid' ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              payment.status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: payment.status == 'paid' ? Colors.green.shade800 : Colors.orange.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRidersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riders',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._viewModel.riders.map((rider) =>
          _buildRiderItem(rider)
        ),
      ],
    );
  }

  Widget _buildRiderItem(Rider rider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.add_circle, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Coverage: ₹${rider.coverageAmount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(Document document) {
    return ListTile(
      leading: Icon(
        document.type == 'policy' ? Icons.assignment : Icons.receipt,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(document.name),
      subtitle: Text(document.date),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () => _downloadDocument(document),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PremiumPaymentPage(policy: widget.policy),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Pay Premium'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _sharePolicyDetails,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Share',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _contactAgent,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Contact Agent',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _fileClaim,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'File Claim',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _sharePolicyDetails() {
    // Implement share functionality
  }

  void _downloadPolicyDocument() {
    // Implement document download
  }

  void _downloadDocument(Document document) {
    // Implement document download
  }

  void _contactAgent() {
    // Navigate to contact agent
    Navigator.pushNamed(context, '/contact-agent');
  }

  void _fileClaim() {
    // Navigate to claim filing
    Navigator.pushNamed(context, '/file-claim');
  }
}
```

## 4. Agent Portal Pages

### 4.1 Agent Dashboard Page

#### Business Dashboard Implementation
```dart
class AgentDashboardPage extends StatefulWidget {
  @override
  _AgentDashboardPageState createState() => _AgentDashboardPageState();
}

class _AgentDashboardPageState extends State<AgentDashboardPage> {
  late AgentDashboardViewModel _viewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final agent = await authService.getCurrentAgent();

      _viewModel = await AgentDashboardService.buildDashboard(agent.agentId);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Agent Dashboard - ${_viewModel.agentName}'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/agent-notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/agent-settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                _buildWelcomeHeader(),

                const SizedBox(height: 24),

                // KPI cards
                _buildKPICards(),

                const SizedBox(height: 24),

                // Trend charts
                _buildTrendCharts(),

                const SizedBox(height: 24),

                // Action items
                _buildActionItems(),

                const SizedBox(height: 24),

                // Smart alerts
                _buildSmartAlerts(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-customer'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getGreeting()}, ${_viewModel.agentName}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Business Overview • ${DateTime.now().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _viewModel.agentCode,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  Widget _buildKPICards() {
    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            'Monthly Revenue',
            '₹${_viewModel.monthlyRevenue}',
            Icons.currency_rupee,
            Colors.green,
            '${_viewModel.revenueGrowth}% vs last month',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            'Active Customers',
            '${_viewModel.activeCustomers}',
            Icons.people,
            Colors.blue,
            '${_viewModel.customerGrowth} new this month',
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCharts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '6-Month Trends',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Revenue trend chart placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Revenue Trend Chart'),
            ),
          ),
          const SizedBox(height: 16),
          // Customer growth chart placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Customer Growth Chart'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItems() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Priority Action Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._viewModel.actionItems.map((item) =>
            _buildActionItem(item)
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(ActionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPriorityColor(item.priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getPriorityColor(item.priority).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getPriorityIcon(item.priority),
            color: _getPriorityColor(item.priority),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getPriorityColor(item.priority),
              ),
            ),
          ),
          Text(
            item.count.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getPriorityColor(item.priority),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.error;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildSmartAlerts() {
    if (_viewModel.smartAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Alerts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._viewModel.smartAlerts.map((alert) =>
            _buildSmartAlert(alert)
          ),
        ],
      ),
    );
  }

  Widget _buildSmartAlert(SmartAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.blue.shade800,
              ),
            ),
          ),
          Text(
            alert.impact,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      currentIndex: 0, // Dashboard is current
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Navigator.pushNamed(context, '/customers');
            break;
          case 2:
            Navigator.pushNamed(context, '/analytics');
            break;
          case 3:
            Navigator.pushNamed(context, '/campaigns');
            break;
          case 4:
            Navigator.pushNamed(context, '/content');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Customers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign),
          label: 'Campaigns',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library),
          label: 'Content',
        ),
      ],
    );
  }
}
```

## 5. WhatsApp Integration Pages

### 5.1 WhatsApp Chat Interface

#### WhatsApp Chat Page
```dart
class WhatsAppChatPage extends StatefulWidget {
  final String customerId;

  const WhatsAppChatPage({Key? key, required this.customerId}) : super(key: key);

  @override
  _WhatsAppChatPageState createState() => _WhatsAppChatPageState();
}

class _WhatsAppChatPageState extends State<WhatsAppChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<WhatsAppMessage> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      _messages = await WhatsAppService.getChatHistory(widget.customerId);
      setState(() => _isLoading = false);

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCustomerName(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Online',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _makePhoneCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _makeVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showChatOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Typing indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Typing',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 2),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(WhatsAppMessage message) {
    final isAgent = message.senderType == 'agent';
    final isSystem = message.senderType == 'system';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isAgent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAgent && !isSystem) ...[
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(
                message.senderName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAgent
                    ? Theme.of(context).primaryColor
                    : isSystem
                        ? Colors.grey.shade200
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSystem)
                    Text(
                      message.senderName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAgent ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isAgent ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isAgent ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isAgent && !isSystem) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      await WhatsAppService.sendMessage(widget.customerId, message);

      // Add message to local list for immediate UI update
      setState(() {
        _messages.add(WhatsAppMessage(
          id: DateTime.now().toString(),
          senderType: 'agent',
          senderName: 'You',
          content: message,
          timestamp: DateTime.now(),
        ));
      });

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  String _getCustomerName() {
    // Get customer name from context or API
    return 'Customer Name';
  }

  void _makePhoneCall() {
    // Launch phone dialer
  }

  void _makeVideoCall() {
    // Launch video call if supported
  }

  void _showChatOptions() {
    // Show chat options menu
  }
}
```

## 6. Error Handling & Edge Cases

### 6.1 Error Pages

#### Network Error Page
```dart
class NetworkErrorPage extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorPage({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your internet connection and try again',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Trial Expired Page
```dart
class TrialExpiredPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_clock,
              size: 64,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Trial Period Expired',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your 14-day free trial has ended. Subscribe to continue using Agent Mitra.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Subscription options
            _buildSubscriptionOptions(),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/subscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Subscribe Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOptions() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Text(
                'Choose Your Plan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPlanCard(
                      'Policyholder',
                      '₹199/month',
                      'Full policy management',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPlanCard(
                      'Agent',
                      '₹999/month',
                      'Complete CRM & analytics',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String title, String price, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### 6.2 Loading & Empty States

#### Loading State Components
```dart
class LoadingCard extends StatelessWidget {
  final String message;

  const LoadingCard({Key? key, this.message = 'Loading...'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;

  const EmptyStateCard({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: const Text('Get Started'),
            ),
          ],
        ],
      ),
    );
  }
}
```

## 7. Feature Flag Integration in Pages

### 7.1 Conditional Page Rendering

#### Feature Flag-Aware Page Builder
```dart
// Feature flag integration for pages
class FeatureFlagPageBuilder {
  static Widget buildPage(String pageName, Map<String, dynamic> params) {
    switch (pageName) {
      case 'customer_dashboard':
        return FutureBuilder<bool>(
          future: FeatureFlagService.isFeatureEnabled('customer_dashboard_enabled'),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return TrialExpiredPage();
            }
            return CustomerDashboardPage();
          },
        );

      case 'premium_payment':
        return FutureBuilder<bool>(
          future: FeatureFlagService.isFeatureEnabled('premium_payments_enabled'),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return FeatureDisabledPage(featureName: 'Premium Payments');
            }
            return PremiumPaymentPage(policy: params['policy']);
          },
        );

      case 'whatsapp_chat':
        return FutureBuilder<bool>(
          future: FeatureFlagService.isFeatureEnabled('whatsapp_integration_enabled'),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return FeatureDisabledPage(featureName: 'WhatsApp Integration');
            }
            return WhatsAppChatPage(customerId: params['customerId']);
          },
        );

      default:
        return UnknownPage();
    }
  }
}

class FeatureDisabledPage extends StatelessWidget {
  final String featureName;

  const FeatureDisabledPage({Key? key, required this.featureName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              '$featureName Disabled',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This feature is currently disabled for your account.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 7.2 Real-Time Feature Flag Updates

#### Background Feature Flag Sync
```dart
class FeatureFlagSyncService {
  static Timer? _syncTimer;

  static void startFeatureFlagSync() {
    // Sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _syncFeatureFlags();
    });
  }

  static Future<void> _syncFeatureFlags() async {
    try {
      final updatedFlags = await FeatureFlagService.fetchLatestFlags();

      // Update local cache
      await FeatureFlagService.updateLocalCache(updatedFlags);

      // Trigger UI updates if needed
      await _handleFeatureFlagChanges(updatedFlags);
    } catch (e) {
      // Log error but don't crash
      print('Feature flag sync failed: $e');
    }
  }

  static Future<void> _handleFeatureFlagChanges(Map<String, dynamic> updatedFlags) async {
    // Check for critical feature flag changes
    final criticalChanges = await _identifyCriticalChanges(updatedFlags);

    if (criticalChanges.isNotEmpty) {
      // Show notification to user
      await _showFeatureFlagNotification(criticalChanges);

      // Update UI state
      await _updateUIForFeatureChanges(criticalChanges);
    }
  }

  static Future<void> _showFeatureFlagNotification(List<String> changes) async {
    // Show in-app notification about feature changes
    // This could trigger a restart of certain features or show upgrade prompts
  }

  static Future<void> _updateUIForFeatureChanges(List<String> changes) async {
    // Update UI state based on feature flag changes
    // For example, hide/show certain widgets or change navigation
  }
}
```

## 8. Implementation Summary

This comprehensive pages design provides:

### 🎨 **Design System Features**
- **Mobile-first responsive design** with Flutter Material Design 3.0
- **CSS-based theming** with dark/light modes and CSS variables
- **Accessibility compliance** (WCAG 2.1 AA) with screen reader support
- **Internationalization** with CDN-based localization keys

### 🔐 **Security & Permissions**
- **RBAC integration** with permission checking on every page
- **Feature flag control** for all UI elements and functionality
- **Session management** with automatic token refresh
- **Audit logging** for compliance and security monitoring

### 📱 **User Experience**
- **Progressive enhancement** - core features work everywhere, enhanced features on capable devices
- **Offline support** - critical features work without internet connection
- **Error handling** - graceful degradation with retry mechanisms
- **Loading states** - skeleton screens and progress indicators

### 🚀 **Performance Optimizations**
- **Lazy loading** - pages and components load on demand
- **Code splitting** - smaller bundle sizes for faster loading
- **Caching strategies** - intelligent caching for improved performance
- **Background sync** - real-time updates without blocking UI

### 🔄 **Feature Flag Integration**
- **Dynamic UI rendering** - pages adapt based on feature flag status
- **Real-time updates** - feature flags sync in background
- **Gradual rollouts** - new features can be enabled for specific users
- **Emergency controls** - ability to disable features instantly

This pages design ensures Agent Mitra provides a world-class, secure, and performant user experience while maintaining the flexibility to adapt to changing business requirements through feature flags and comprehensive role-based access control.
