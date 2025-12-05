# iOS Simulator Debugging Guide

## Viewing Console Logs in iOS Simulator

Unlike web browsers where you can open DevTools, iOS Simulator requires different methods to view console logs.

### Method 1: Xcode Console (Recommended)

1. **Open Xcode**
2. **Run your Flutter app** from Xcode or via command line:
   ```bash
   flutter run
   ```
3. **View logs in Xcode**:
   - Open Xcode → Window → Devices and Simulators
   - Select your simulator
   - Click "Open Console" button
   - All `print()`, `debugPrint()`, and `log()` statements will appear here

### Method 2: Terminal Console Output

When running Flutter from terminal, logs appear directly in the terminal:

```bash
flutter run
```

All `print()` and `debugPrint()` statements will appear in the terminal output.

### Method 3: Flutter DevTools (Best for Development)

1. **Start your app**:
   ```bash
   flutter run
   ```

2. **Open DevTools** (URL will be shown in terminal):
   ```
   The Flutter DevTools debugger and profiler is available at: http://127.0.0.1:9100/?uri=...
   ```

3. **View logs**:
   - Click on "Logging" tab in DevTools
   - All console logs will appear here with filtering options

### Method 4: iOS Simulator System Logs

View system-level logs:

```bash
# View all simulator logs
xcrun simctl spawn booted log stream

# Filter for your app
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "Runner"'
```

### Method 5: Using `flutter logs` Command

```bash
# View logs from connected device/simulator
flutter logs

# Follow logs in real-time
flutter logs --follow
```

## Debugging Tips

### Use `debugPrint()` Instead of `print()`

`debugPrint()` is throttled in Flutter and won't flood the console:

```dart
debugPrint('User loaded: ${user.name}');
```

### Enable Verbose Logging

Run with verbose flag:

```bash
flutter run --verbose
```

### Filter Logs

In Xcode console or terminal, you can filter logs:
- Search for specific strings
- Filter by log level (Error, Warning, Info)

### Network Request Debugging

To see API requests/responses:

1. **Enable HTTP logging** in your API service
2. **Use Charles Proxy** or **Proxyman** for network inspection
3. **Add logging middleware** in your API service

Example:
```dart
static Future<dynamic> get(String endpoint, ...) async {
  debugPrint('🌐 GET: $apiUrl$endpoint');
  try {
    final response = await http.get(...);
    debugPrint('✅ Response: ${response.statusCode}');
    return handleResponse(response);
  } catch (e) {
    debugPrint('❌ Error: $e');
    rethrow;
  }
}
```

## Common Issues

### Logs Not Appearing

1. **Check if running in release mode** - logs are disabled in release builds
2. **Verify `debugPrint()` is used** - `print()` may be throttled
3. **Check Xcode console** - sometimes logs only appear there

### Too Many Logs

1. **Use log levels** - filter by severity
2. **Disable verbose logging** in production
3. **Use conditional logging**:
   ```dart
   if (kDebugMode) {
     debugPrint('Debug info');
   }
   ```

## Recommended Setup

For best debugging experience:

1. **Run app from terminal**: `flutter run`
2. **Open Flutter DevTools** in browser
3. **Use `debugPrint()` for all logging**
4. **Keep Xcode open** for system-level logs

## Quick Reference

| Method | Best For | Command |
|--------|----------|---------|
| Terminal | Quick debugging | `flutter run` |
| Xcode Console | System logs | Window → Devices → Console |
| Flutter DevTools | Detailed debugging | Auto-opens with `flutter run` |
| `flutter logs` | Log streaming | `flutter logs --follow` |
| System Logs | Low-level debugging | `xcrun simctl spawn booted log stream` |

