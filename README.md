# webview_flutter_wrapper

A powerful Flutter WebView wrapper plugin that provides convenient JavaScript injection and
bidirectional communication capabilities.

## ✨ Features

- **🚀 Smart JS Injection**: Automatically inject JavaScript objects at two timing points - page load
  start (`pageStart`) and page load end (`pageEnd`)
- **🔄 Bidirectional Communication**: Seamless Native ↔ JavaScript calls with Promise async support
- **⏱️ Lifecycle Events**: Provides `onPageStartScriptReady`, `onPageEndScriptReady`, and custom
  object ready events for precise injection timing control
- **✅ Promise Compatible**: Native JavaScript Promise support, `runJavaScriptReturningResult` can
  directly await async functions
- **🎯 Flexible Management**: Support dynamic add, remove, and clear injected objects to meet
  different scenario requirements
- **⚙️ Configurable Timeout**: Set custom timeout for JavaScript Promise execution

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  webview_flutter_wrapper: ^0.0.3
```

Then run:

```shell
flutter pub get
```

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter_wrapper/webview_flutter_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final WebviewWrapperController controller = WebviewWrapperController();

  @override void initState() {
    super.initState();
// Configure JavaScript injection objects
    controller.assignAllInjectJsObject({
      // you can listen onNativeBridgeReady in js
      "NativeBridge": InjectJsObject(
          injectionTime: InjectionTime.pageEnd,
          onInjectedReady: () {
            print("----------->>>NativeBridge ready");
          },
          functions: {
            "sendMessage": (data) {
              debugPrint("Received from JS: $data");
            },
            "getUserInfo": (data) {
              debugPrint("Get user info request: $data");
            }
          }
      ),
    });

// Enable unrestricted JavaScript mode
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);

// Load HTML content
    controller.loadFlutterAsset("assets/index.html");
  }

  @override Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(
      appBar: AppBar(title: const Text('WebView Wrapper Example'),), body: WebviewWrapperWidget(
      controller: controller, debuggingEnabled: true,),),);
  }
}
```

## 📖 Advanced Usage

### JavaScript Injection Timing

The plugin supports two injection timing options:

- **`InjectionTime.pageStart`**: Inject JavaScript at the beginning of page loading
- **`InjectionTime.pageEnd`**: Inject JavaScript after the page has finished loading

```dart
  controller.addInjectJsObjects({
// Injected at page start
// you can listen onEarlyBirdReady in js
"EarlyBird": InjectJsObject(
  injectionTime: InjectionTime.pageStart,
  onInjectedReady: () {
    print("----------->>>EarlyBird ready");
  },
  functions: {
    "earlyCall": (data) => debugPrint("Early call: $data"),
  }),
// Injected at page end
// you can listen onLateComerReady in js
"LateComer": InjectJsObject(
  injectionTime: InjectionTime.pageEnd,
  onInjectedReady: () {
    print("----------->>>LateComer ready");
  },
  functions: {
    "lateCall": (data) => debugPrint("Late call: $data"),
  }),}
);
```

### Listening to Lifecycle Events

JavaScript can listen to injection lifecycle events:

```javascript
<script> // Listen for page start injection ready 
window.addEventListener('onPageStartScriptReady', function () {
    console.log('Page start scripts are ready');
});
// Listen for page end injection ready 
window.addEventListener('onPageEndScriptReady', function () {
  console.log('Page end scripts are ready'); 
});
// Listen for specific object ready event
window.addEventListener('onNativeBridgeReady', function () {
  console.log('NativeBridge is ready to use');
});
// Listen for specific object ready event
window.addEventListener('onEarlyBirdReady', function () {
  console.log('EarlyBird is ready to use');
});
// Listen for specific object ready event
window.addEventListener('onLateComerReady', function () {
  console.log('LateComer is ready to use');
});
</script>
```
### Calling Native from JavaScript

After injection, JavaScript can directly call native methods:

```javascript
// Assuming you injected an object named "NativeBridge"
function sendToNative() { NativeBridge.sendMessage({ message: "Hello from JS!" }); }
function requestUserInfo() { NativeBridge.getUserInfo({ userId: 123 }); }
```
### Using Navigation Delegate
```dart
controller.setNavigationDelegateWrapper(
NavigationDelegateWrapper(
    onPageStarted: (url) {
      debugPrint("Page started: $url");
    },
  onPageFinished: (url) {
    debugPrint("Page finished: $url");
  },
  onWebResourceError: (error) {
    debugPrint("Error: ${error.description}");
  },
  ),
);
```
## 🏗️ Architecture

### Core Components

- **`WebviewWrapperController`**: Extended controller with enhanced JavaScript injection and Promise support
- **`WebviewWrapperWidget`**: Wrapper widget that integrates with Flutter's WebView
- **`InjectJsObject`**: Configuration class for JavaScript injection objects
- **`InjectObjectManager`**: Manages the lifecycle and generation of injected JavaScript code
- **`NavigationDelegateWrapper`**: Simplified navigation delegate for handling WebView events

### Injection Mechanism

The plugin uses a sophisticated injection system:

1. **Registration**: Register JavaScript objects with their callbacks in Dart
2. **Generation**: Automatically generate JavaScript bridge code
3. **Injection**: Inject at the specified timing (pageStart or pageEnd)
4. **Communication**: Use JavaScript channels for bidirectional messaging
5. **Promise Handling**: Wrap async calls with Promise resolution tracking

## 📝 API Reference

### WebviewWrapperController

| Method | Description |
|--------|-------------|
| `assignAllInjectJsObject(Map<String, InjectJsObject>)` | Replace all injection objects |
| `addInjectJsObjects(Map<String, InjectJsObject>)` | Add multiple injection objects |
| `addInjectJsObject(String, InjectJsObject)` | Add a single injection object |
| `removeInjectJsObject(String)` | Remove a specific injection object |
| `clearInjectJsObject()` | Clear all injection objects |
| `clearStartInjectJsObject()` | Clear pageStart injection objects |
| `clearEndInjectJsObject()` | Clear pageEnd injection objects |
| `setJsPromiseTimeout(Duration)` | Set Promise execution timeout |
| `runJavaScriptReturningResult(String)` | Execute JavaScript and get result (Promise compatible) |
| `setNavigationDelegateWrapper(NavigationDelegateWrapper)` | Set navigation delegate |

### InjectJsObject

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `injectionTime` | `InjectionTime` | Yes | When to inject (pageStart or pageEnd) |
| `functions` | `Map<String, OnJsCallback>` | Yes | JavaScript functions to expose to native |
| `injectJsScript` | `String?` | No | Optional initialization script |

### OnJsCallback

