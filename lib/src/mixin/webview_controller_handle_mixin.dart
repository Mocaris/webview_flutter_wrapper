///
/// @Author mocaris
/// @Date 2026-02-05
/// @Since
part of '../webview_wrapper_widget.dart';

///js 脚本页面开始注入后事件
const String kOnPageStartScriptReadyEvent = "onPageStartScriptReady";

///js 脚本页面结束注入后事件
const String kOnPageEndScriptReadyEvent = "onPageEndScriptReady";

///处理 inject object function js 回调
const String kInjectFuncHandleJsObject = "_webview_wrapper_inject_bridge";

///处理 native call js promise 回调
const String kPromiseHandleJsObject = "_webview_wrapper_promise_bridge";

mixin WebviewControllerHandleMixin on WebViewController {
  var _completerFunCount = 0;
  final _promiseCompleterCache = <String, Completer>{};
  final _injectManager = InjectObjectManager();

  NavigationDelegate _createNavigationDelegate(
      {NavigationDelegateWrapper? wrapper}) {
    return NavigationDelegate(
      onNavigationRequest: wrapper?.onNavigationRequest,
      onPageStarted: (url) {
        _clearPreviousPromise();
        _injectStartJs();
        wrapper?.onPageStarted?.call(url);
      },
      onPageFinished: (url) async {
        _injectEndJs();
        wrapper?.onPageFinished?.call(url);
      },
      onProgress: wrapper?.onProgress,
      onWebResourceError: wrapper?.onWebResourceError,
      onUrlChange: wrapper?.onUrlChange,
      onHttpAuthRequest: wrapper?.onHttpAuthRequest,
      onHttpError: wrapper?.onHttpError,
      onSslAuthError: wrapper?.onSslAuthError,
    );
  }

  void _injectStartJs() {
    var injectJsScript = _injectManager.startInjectJsScript;
    if (_injectManager.startInjectJsScript.isNotEmpty) {
      super.runJavaScript(injectJsScript);
    }
  }

  void _injectEndJs() {
    if (_injectManager.endInjectJsScript.isNotEmpty) {
      super.runJavaScript(_injectManager.endInjectJsScript);
    }
  }

  void _clearPreviousPromise() {
    _completerFunCount = 0;
    for (var completer in _promiseCompleterCache.values) {
      if (!completer.isCompleted) {
        completer.completeError("promise timeout");
      }
    }
    _promiseCompleterCache.clear();
  }

  /// 处理 promise 回调
  void _handlePromiseMessage(JavaScriptMessage message) {
    String? funcId;
    try {
      var callData = jsonDecode(message.message) as Map<String, dynamic>;
      funcId = callData["funcId"];
      var completer = _promiseCompleterCache[funcId];
      if (null == completer) {
        return;
      }
      var result = callData["result"];
      if (null != result) {
        try {
          result = jsonDecode(result);
          // ignore: empty_catches
        } catch (e) {}
        completer.complete(result);
        return;
      }
      var error = callData["error"];
      if (null != error) {
        try {
          error = jsonDecode(error);
          // ignore: empty_catches
        } catch (e) {}
        if (error is Map) {
          completer.completeError(
            error["message"] ?? '',
            StackTrace.fromString(error["stack"] ?? ""),
          );
        } else {
          completer.completeError(error);
        }
      }
      if (!completer.isCompleted) {
        // return  void
        completer.complete();
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);
    } finally {
      if (funcId != null) {
        _promiseCompleterCache.remove(funcId);
      }
    }
  }

  /// 执行 js 并返回结果  支持 promise
  Future<Object> _runJavaScriptReturningResult(String javaScript) {
    final funcId =
        "${DateTime.now().millisecondsSinceEpoch}_${++_completerFunCount}";
    final completer = _promiseCompleterCache[funcId] = Completer<Object>();
    final javaScriptSource = InjectJsUtil.generateRunJsPromise(
        funcId: funcId, javaScript: javaScript);
    platform.runJavaScript(javaScriptSource);
    return completer.future;
  }

  void _parseInjectCallback(JavaScriptMessage message) async {
    try {
      final injectList = _injectManager.injectObjects;
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
        if (inject.name != object) {
          continue;
        }
        inject.functions[method]?.call(param);
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);
    }
  }
}
