import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_wrapper/src/utils/inject_js_util.dart';

import 'constant/js_bridge_events.dart';
import 'navigation_delegate_wrapper.dart';
import 'webview_inject_object.dart';

part 'mixin/webview_controller_handle_mixin.dart';
part 'webview_wrapper_controller.dart';

/// Enhanced WebView widget with advanced JavaScript integration capabilities.
///
/// [WebviewWrapperWidget] is a stateful widget that wraps the base [WebViewWidget]
/// to provide enhanced functionality including:
/// - Automatic JavaScript injection at different page lifecycle stages
/// - Bidirectional JavaScript-Native communication
/// - Promise-based JavaScript execution support
/// - Platform-specific debugging controls
/// - Gesture recognition customization
///
/// This widget manages the lifecycle of [WebviewWrapperController] and ensures
/// proper initialization and cleanup of JavaScript injection infrastructure.
///
/// @Author mocaris
/// @Date 2026-02-04
/// @Since 0.0.1
class WebviewWrapperWidget extends StatefulWidget {
  /// The controller that manages the WebView and JavaScript injection.
  ///
  /// This controller provides methods for:
  /// - Executing JavaScript with Promise support
  /// - Managing JavaScript injection objects
  /// - Handling navigation events
  /// - Controlling WebView behavior
  final WebviewWrapperController controller;

  /// The text direction for laying out child widgets.
  ///
  /// Defaults to [TextDirection.ltr] (left-to-right).
  /// Set to [TextDirection.rtl] for right-to-left languages.
  final TextDirection layoutDirection;

  /// Which gestures should be consumed by the WebView.
  ///
  /// This is useful when you want the WebView to handle specific gestures
  /// while allowing other gestures to be handled by parent widgets.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// Whether to enable debugging features for the WebView.
  ///
  /// When enabled:
  /// - On iOS/macOS: Sets the web view as inspectable in Safari Web Inspector
  /// - On Android: Enables Chrome DevTools remote debugging
  ///
  /// Recommended to enable only in debug mode for security reasons.
  final bool debuggingEnabled;

  /// Creates a [WebviewWrapperWidget] instance.
  ///
  /// Parameters:
  /// - [controller]: Required. The controller for managing the WebView.
  /// - [layoutDirection]: Optional. Text direction for layout (default: ltr).
  /// - [gestureRecognizers]: Optional. Set of gesture recognizers (default: empty set).
  /// - [debuggingEnabled]: Optional. Whether to enable debugging (default: false).
  const WebviewWrapperWidget({
    super.key,
    required this.controller,
    this.layoutDirection = TextDirection.ltr,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.debuggingEnabled = false,
  });

  @override
  State<StatefulWidget> createState() => WebviewWrapperWidgetState();
}

class WebviewWrapperWidgetState extends State<WebviewWrapperWidget> {
  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant WebviewWrapperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initController(oldWidget: oldWidget);
  }

  @override
  void dispose() {
    widget.controller._clearPreviousPromise();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: widget.controller,
      layoutDirection: widget.layoutDirection,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }
}

extension WebviewWrapperStateExt on WebviewWrapperWidgetState {
  void _initController({WebviewWrapperWidget? oldWidget}) {
    if (oldWidget?.debuggingEnabled != widget.debuggingEnabled) {
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        final WebKitWebViewController webKitController =
            widget.controller.platform as WebKitWebViewController;
        webKitController.setInspectable(widget.debuggingEnabled);
      }
      if (WebViewPlatform.instance is AndroidWebViewPlatform) {
        AndroidWebViewController.enableDebugging(widget.debuggingEnabled);
      }
    }
  }
}
