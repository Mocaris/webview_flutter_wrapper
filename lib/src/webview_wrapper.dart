import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'navigation_delegate_wrapper.dart';
import 'webview_inject_object.dart';

part 'mixin/webview_wrapper_mixin.dart';
part 'webview_wrapper_controller.dart';

/// WebviewWrapper
/// @Author mocaris
/// @Date 2026-02-04
/// @Since

class WebviewWrapper extends StatefulWidget {
  final WebviewWrapperController controller;
  final TextDirection layoutDirection;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final bool debuggingEnabled;

  const WebviewWrapper({
    super.key,
    required this.controller,
    this.layoutDirection = TextDirection.ltr,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.debuggingEnabled = false,
  });

  @override
  State<StatefulWidget> createState() => WebviewWrapperState();
}

class WebviewWrapperState extends State<WebviewWrapper> {
  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant WebviewWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initController(oldWidget: oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: widget.controller._controller,
      layoutDirection: widget.layoutDirection,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }
}

extension WebviewWrapperStateExt on WebviewWrapperState {
  void _initController({WebviewWrapper? oldWidget}) {
    if (oldWidget?.debuggingEnabled != widget.debuggingEnabled) {
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        final WebKitWebViewController webKitController =
            widget.controller.platform as WebKitWebViewController;
        webKitController.setInspectable(widget.debuggingEnabled);
      } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
        AndroidWebViewController.enableDebugging(widget.debuggingEnabled);
      }
    }
  }
}
