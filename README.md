# Agent Mitra - Flutter UI Demo

This is a Flutter implementation of the unauthenticated UI screens for Agent Mitra mobile app, based on the wireframes from `discovery/content/wireframes.md`.

## Features Implemented

### Unauthenticated Screens (User Onboarding):
1. **Splash Screen** - Animated logo with loading indicator
2. **Welcome Screen** - Trial onboarding with CTA buttons
3. **Phone Verification** - Mobile number input with validation
4. **OTP Verification** - 6-digit OTP input with resend timer
5. **Trial Setup** - Profile setup form with insurance preferences
6. **Trial Expiration** - Subscription upgrade screen

### Customer Portal Screens (Post-Authentication):
7. **Customer Dashboard** - Home screen with policy overview, quick actions, and notifications
8. **Policy Details** - Individual policy information, premium details, and action buttons
9. **WhatsApp Integration** - Agent communication via WhatsApp with message templates
10. **Smart Chatbot** - AI assistant for policy queries with step-by-step guidance
11. **Learning Center** - Educational videos, tutorials, and progress tracking

### Agent Portal Screens (Business Management):
12. **Agent Config Dashboard** - Data import statistics and management portal
13. **ROI Analytics** - Revenue analytics, performance metrics, and predictive insights
14. **Campaign Builder** - Marketing campaign creation with audience segmentation

### Total: 14 Complete Screens with Demo Data

## Navigation Flow
```
Unauthenticated Flow:
Splash → Welcome → Phone → OTP → Trial Setup → Trial Expiration

Customer Portal Flow:
Dashboard → Policy Details → WhatsApp → Chatbot → Learning Center

Agent Portal Flow:
Config Dashboard → ROI Analytics → Campaign Builder

Demo Navigation: All screens accessible from main menu
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

### Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Run on web (if configured)
flutter run -d chrome
```

## Screen Details

### 1. Splash Screen
- Animated logo with fade and scale transitions
- Loading animation with feature flag simulation
- Auto-navigates to Welcome screen after 3 seconds

### 2. Welcome Screen
- Clean, centered layout with app branding
- 14-day free trial promotion banner
- GET STARTED and LOGIN action buttons

### 3. Phone Verification
- Country code (+91) with phone number input
- Real-time validation (10 digits required)
- Help/support option

### 4. OTP Verification
- 6 individual input fields for OTP digits
- 30-second resend timer with visual feedback
- Auto-focus navigation between fields
- Call support alternative

### 5. Trial Setup
- Trial activation confirmation banner
- Profile form (Name, Email, Insurance preferences)
- Form validation before enabling START TRIAL button

### 6. Trial Expiration
- Trial expiry notification
- Feature restriction indicators
- Subscription plan comparison (Policyholder vs Agent)
- Contact sales option

## Design System

- **Primary Color**: `#1a237e` (Deep Blue)
- **Typography**: Inter font family
- **Touch Targets**: Minimum 48pt for accessibility
- **Border Radius**: 8-12px for modern look
- **Material Design 3**: Following latest design guidelines

## Dependencies Used

- `flutter_screenutil`: Responsive design
- `google_fonts`: Custom typography
- `flutter_svg`: Vector graphics support (future use)

## Architecture

```
lib/
├── main.dart                 # App entry point with routing
└── screens/                  # UI screens
    ├── splash_screen.dart
    ├── welcome_screen.dart
    ├── phone_verification_screen.dart
    ├── otp_verification_screen.dart
    ├── trial_setup_screen.dart
    └── trial_expiration_screen.dart
```

## Wireframe Compliance

All screens follow the specifications from `discovery/content/wireframes.md`:
- Layout structure and content hierarchy
- Feature flag integration placeholders
- Color scheme and typography
- Button styles and interactions
- Form validation and user feedback

## Future Enhancements

When ready for full app development:
- Add authentication API integration
- Implement feature flag service
- Add data persistence (SQLite/SharedPreferences)
- Integrate with backend services
- Add comprehensive testing
- Implement accessibility features
- Add multi-language support

## Contributing

1. Follow the existing code structure
2. Maintain consistency with wireframe designs
3. Add proper documentation
4. Test on multiple devices/screen sizes