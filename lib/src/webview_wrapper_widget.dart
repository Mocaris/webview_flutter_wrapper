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

import 'navigation_delegate_wrapper.dart';
import 'webview_inject_object.dart';

part 'mixin/webview_controller_handle_mixin.dart';
part 'webview_wrapper_controller.dart';

/// WebviewWrapper
/// @Author mocaris
/// @Date 2026-02-04
/// @Since

class WebviewWrapperWidget extends StatefulWidget {
  final WebviewWrapperController controller;
  final TextDirection layoutDirection;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final bool debuggingEnabled;

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
