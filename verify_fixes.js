// Verification Script: Agent Mitra Navigation Fixes
// This script verifies all the fixes implemented are present in the codebase

const fs = require('fs');
const path = require('path');

console.log('🔍 AGENT MITRA NAVIGATION FIXES VERIFICATION');
console.log('==========================================');

// Test 1: Verify hamburger menu fix
function verifyHamburgerMenuFix() {
    console.log('\n1. 🏠 Hamburger Menu Fix');

    try {
        const dashboardPage = fs.readFileSync('lib/features/dashboard/presentation/pages/dashboard_page.dart', 'utf8');
        const hasBuilderWidget = dashboardPage.includes('leading: Builder(') && dashboardPage.includes('builder: (context) => IconButton');
        const hasScaffoldOf = dashboardPage.includes('Scaffold.of(context).openDrawer()');

        if (hasBuilderWidget && hasScaffoldOf) {
            console.log('✅ FIXED: Builder widget added to app bar leading');
            return true;
        } else {
            console.log('❌ NOT FIXED: Builder widget missing or incorrect');
            console.log(`   - Has Builder: ${dashboardPage.includes('Builder(')}`);
            console.log(`   - Has leading Builder: ${dashboardPage.includes('leading: Builder(')}`);
            console.log(`   - Has Scaffold.of: ${hasScaffoldOf}`);
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not read dashboard page');
        return false;
    }
}

// Test 2: Verify quick action routes
function verifyQuickActionRoutes() {
    console.log('\n2. 🎯 Quick Action Routes');

    try {
        const mainFile = fs.readFileSync('lib/main.dart', 'utf8');
        const routes = [
            '/policy/create',
            '/claims/new',
            '/payments',
            '/reports',
            '/customers',
            '/settings'
        ];

        const missingRoutes = routes.filter(route => !mainFile.includes(`'${route}':`));

        if (missingRoutes.length === 0) {
            console.log('✅ FIXED: All quick action routes added');
            return true;
        } else {
            console.log('❌ MISSING:', missingRoutes.join(', '));
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not read main.dart');
        return false;
    }
}

// Test 3: Verify settings route
function verifySettingsRoute() {
    console.log('\n3. ⚙️ Settings Route');

    try {
        const mainFile = fs.readFileSync('lib/main.dart', 'utf8');
        const hasSettingsRoute = mainFile.includes(`'/settings':`);

        if (hasSettingsRoute) {
            console.log('✅ FIXED: Settings route added');
            return true;
        } else {
            console.log('❌ NOT FIXED: Settings route missing');
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not read main.dart');
        return false;
    }
}

// Test 4: Verify global search screen
function verifyGlobalSearchScreen() {
    console.log('\n4. 🔍 Global Search Screen');

    try {
        const searchScreenExists = fs.existsSync('lib/screens/global_search_screen.dart');
        const mainFile = fs.readFileSync('lib/main.dart', 'utf8');
        const hasSearchRoute = mainFile.includes(`'/global-search':`);
        const dashboardPage = fs.readFileSync('lib/features/dashboard/presentation/pages/dashboard_page.dart', 'utf8');
        const hasSearchNavigation = dashboardPage.includes(`pushNamed('/global-search')`);

        if (searchScreenExists && hasSearchRoute && hasSearchNavigation) {
            console.log('✅ FIXED: Global search screen implemented');
            return true;
        } else {
            console.log('❌ NOT FIXED: Missing components');
            console.log(`   - Screen exists: ${searchScreenExists}`);
            console.log(`   - Route exists: ${hasSearchRoute}`);
            console.log(`   - Navigation exists: ${hasSearchNavigation}`);
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not verify global search');
        return false;
    }
}

// Test 5: Verify placeholder screens
function verifyPlaceholderScreens() {
    console.log('\n5. 📄 Placeholder Screens');

    try {
        const mainFile = fs.readFileSync('lib/main.dart', 'utf8');
        const hasPlaceholderScreen = mainFile.includes('class PlaceholderScreen');
        const routes = ['/policy/create', '/claims/new', '/payments', '/reports', '/customers', '/settings'];
        const allRoutesHavePlaceholders = routes.every(route =>
            mainFile.includes(`PlaceholderScreen(title:`) &&
            mainFile.includes(`'${route}': (context) => const PlaceholderScreen(`)
        );

        if (hasPlaceholderScreen && allRoutesHavePlaceholders) {
            console.log('✅ FIXED: Placeholder screens implemented');
            return true;
        } else {
            console.log('❌ NOT FIXED: Placeholder screens missing');
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not verify placeholder screens');
        return false;
    }
}

// Test 6: Verify feature flag integration
function verifyFeatureFlagIntegration() {
    console.log('\n6. 🚩 Feature Flag Integration');

    try {
        const sideDrawer = fs.readFileSync('lib/features/dashboard/presentation/widgets/agent_side_drawer.dart', 'utf8');
        const hasFeatureFlags = sideDrawer.includes('_featureFlags') && sideDrawer.includes('_featureFlagService');
        const hasConditionalRendering = sideDrawer.includes('if (_featureFlags[');

        const dailyQuotes = fs.readFileSync('lib/screens/daily_quotes_screen.dart', 'utf8');
        const hasDailyQuotesFlag = dailyQuotes.includes('_featureFlagService') && dailyQuotes.includes('_whatsappEnabled');

        if (hasFeatureFlags && hasConditionalRendering && hasDailyQuotesFlag) {
            console.log('✅ FIXED: Feature flag integration implemented');
            return true;
        } else {
            console.log('❌ NOT FIXED: Feature flag integration missing');
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not verify feature flags');
        return false;
    }
}

// Test 7: Verify presentation alignment
function verifyPresentationAlignment() {
    console.log('\n7. 📊 Presentation Alignment');

    try {
        const dashboardPage = fs.readFileSync('lib/features/dashboard/presentation/pages/dashboard_page.dart', 'utf8');
        const hasCenterAlignment = dashboardPage.includes('mainAxisAlignment: MainAxisAlignment.center');

        if (hasCenterAlignment) {
            console.log('✅ VERIFIED: Presentation placeholder is center aligned');
            return true;
        } else {
            console.log('❌ NOT ALIGNED: Presentation placeholder missing center alignment');
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not verify presentation alignment');
        return false;
    }
}

// Test 8: Verify accessibility service
function verifyAccessibilityService() {
    console.log('\n8. ♿ Accessibility Service');

    try {
        const accessibilityExists = fs.existsSync('lib/core/services/accessibility_service.dart');
        const mainFile = fs.readFileSync('lib/main.dart', 'utf8');
        const hasAccessibilityRoute = mainFile.includes(`'/accessibility-settings':`);

        if (accessibilityExists && hasAccessibilityRoute) {
            console.log('✅ IMPLEMENTED: Accessibility service and settings screen');
            return true;
        } else {
            console.log('❌ MISSING: Accessibility service or route');
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not verify accessibility service');
        return false;
    }
}

// Test 9: Verify language service
function verifyLanguageService() {
    console.log('\n9. 🌍 Language Service');

    try {
        const languageExists = fs.existsSync('lib/core/services/localization_service.dart');
        const mainFile = fs.readFileSync('lib/main.dart', 'utf8');
        const hasLanguageRoute = mainFile.includes(`'/language-selection':`);

        if (languageExists && hasLanguageRoute) {
            console.log('✅ IMPLEMENTED: Language service and selection screen');
            return true;
        } else {
            console.log('❌ MISSING: Language service or route');
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not verify language service');
        return false;
    }
}

// Test 10: Verify WhatsApp service
function verifyWhatsAppService() {
    console.log('\n10. 💬 WhatsApp Service');

    try {
        const whatsappExists = fs.existsSync('lib/core/services/whatsapp_business_service.dart');
        const dailyQuotes = fs.readFileSync('lib/screens/daily_quotes_screen.dart', 'utf8');
        const hasWhatsAppIntegration = dailyQuotes.includes('WhatsAppBusinessService');

        if (whatsappExists && hasWhatsAppIntegration) {
            console.log('✅ IMPLEMENTED: WhatsApp business service integrated');
            return true;
        } else {
            console.log('❌ MISSING: WhatsApp service or integration');
            return false;
        }
    } catch (error) {
        console.log('❌ ERROR: Could not verify WhatsApp service');
        return false;
    }
}

// Run all tests
async function runAllTests() {
    const results = [
        verifyHamburgerMenuFix(),
        verifyQuickActionRoutes(),
        verifySettingsRoute(),
        verifyGlobalSearchScreen(),
        verifyPlaceholderScreens(),
        verifyFeatureFlagIntegration(),
        verifyPresentationAlignment(),
        verifyAccessibilityService(),
        verifyLanguageService(),
        verifyWhatsAppService()
    ];

    const passed = results.filter(r => r === true).length;
    const total = results.length;

    console.log('\n' + '='.repeat(50));
    console.log('📊 VERIFICATION RESULTS');
    console.log('='.repeat(50));
    console.log(`✅ PASSED: ${passed}/${total} tests`);
    console.log(`❌ FAILED: ${total - passed}/${total} tests`);

    if (passed === total) {
        console.log('\n🎉 ALL FIXES VERIFIED SUCCESSFULLY!');
        console.log('🚀 Agent Mitra app is ready for testing with all navigation issues resolved.');
    } else {
        console.log('\n⚠️ SOME FIXES NEED ATTENTION');
        console.log('Please check the failed tests above and implement missing components.');
    }

    console.log('\n🔗 Test the app at: http://localhost:8080/#/customer-dashboard');
    console.log('='.repeat(50));
}

// Execute tests
runAllTests().catch(console.error);
