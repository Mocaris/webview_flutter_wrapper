import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'webview_js_bridge.dart';

part 'inject_js_generate.dart';
part 'webview_wrapper_controller.dart';

const String _kJsObject = "_webview_wrapper_bridge";

/// WebviewWrapper
/// 提供
/// @Author mocaris
/// @Date 2026-02-04
/// @Since

class WebviewWrapper extends StatefulWidget {
  final WebviewWrapperController controller;
  final TextDirection layoutDirection;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  final List<InjectJsObject> injectObjects;

  ///
  final FutureOr<NavigationDecision> Function(NavigationRequest request)?
      onNavigationRequest;
  final Function(String url)? onPageStarted;
  final Function(String url)? onPageFinished;
  final Function(int progress)? onProgress;
  final Function(WebResourceError error)? onWebResourceError;
  final Function(UrlChange change)? onUrlChange;

  final bool debuggingEnabled;

  const WebviewWrapper({
    super.key,
    required this.controller,
    this.layoutDirection = TextDirection.ltr,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.injectObjects = const [],
    this.debuggingEnabled = false,
    this.onNavigationRequest,
    this.onPageStarted,
    this.onPageFinished,
    this.onProgress,
    this.onWebResourceError,
    this.onUrlChange,
  });

  @override
  State<StatefulWidget> createState() => WebviewWrapperState();
}

class WebviewWrapperState extends State<WebviewWrapper> {
  String _startInjectSource = "";
  String _endInjectSource = "";

  late final _delegate = NavigationDelegate(
    onNavigationRequest: widget.onNavigationRequest,
    onPageStarted: (url) async {
      widget.controller._clearPreviousPromise();
      if (_startInjectSource.isNotEmpty) {
        await widget.controller.runJavaScript(_startInjectSource);
      }
      widget.onPageStarted?.call(url);
    },
    onPageFinished: (url) async {
      if (_endInjectSource.isNotEmpty) {
        await widget.controller.runJavaScript(_endInjectSource);
      }
      widget.onPageFinished?.call(url);
    },
    onProgress: widget.onProgress,
    onWebResourceError: widget.onWebResourceError,
    onUrlChange: widget.onUrlChange,
  );

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
    widget.controller.removeJavaScriptChannel(_kJsObject);
    super.dispose();
  }

  void _initHandleJs() async {
    var startList = widget.injectObjects
        .where((e) => e.injectionTime == InjectionTime.pageStart);
    var startInjectObjectJs = startList.map((e) {
      return InjectJsGenerate.generateInjectJs(e);
    }).join("\n");
    _startInjectSource =
        InjectJsGenerate.generateAnonymousFunction(startInjectObjectJs);

    var endList = widget.injectObjects
        .where((e) => e.injectionTime == InjectionTime.pageEnd);
    var endInjectObjectJs = endList.map((e) {
      return InjectJsGenerate.generateInjectJs(e);
    }).join("\n");
    _endInjectSource =
        InjectJsGenerate.generateAnonymousFunction(endInjectObjectJs);
  }

  void _initController({WebviewWrapper? oldWidget}) {
    if (oldWidget?.injectObjects != widget.injectObjects) {
      _initHandleJs();
    }

    var controller = widget.controller;
    if (oldWidget?.debuggingEnabled != widget.debuggingEnabled) {
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        final WebKitWebViewController webKitController =
            controller._controller.platform as WebKitWebViewController;
        webKitController.setInspectable(widget.debuggingEnabled);
      } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
        AndroidWebViewController.enableDebugging(widget.debuggingEnabled);
      }
    }
    if (oldWidget?.controller != widget.controller) {
      oldWidget?.controller.removeJavaScriptChannel(_kJsObject);
      widget.controller._controller.setNavigationDelegate(_delegate);
      widget.controller.addJavaScriptChannel(
        _kJsObject,
        onMessageReceived: _parseInjectCallback,
      );
    }
  }

  void _parseInjectCallback(JavaScriptMessage message) async {
    try {
      final injectList = widget.injectObjects;
      var callData = jsonDecode(message.message) as Map<String, dynamic>;
      final object = callData['object'];
      if (null == object) {
        return;
      }
      final method = callData['method'];
      if (null == method) {
        return;
      }
      var param = callData['params'];
      for (var inject in injectList) {
        if (inject.object != object) {
          continue;
        }
        final callback = inject.functions[method];
        if (null == callback) {
          continue;
        }
        callback?.call(param);
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);
    }
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
