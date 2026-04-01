///
/// @Author mocaris
/// @Date 2026-02-05
/// @Since
part of '../webview_wrapper_widget.dart';

///js 脚本页面开始注入后事件
const String kOnPageStartScriptReadyEvent = "onPageStartScriptReady";

///js 脚本页面结束注入后事件
const String kOnPageEndScriptReadyEvent = "onPageEndScriptReady";

///处理 js 回调
const String kWebviewHandleJsObject = "_webview_wrapper_bridge";

///处理 promise 回调
const String kPromiseHandleJsObject = "_webview_wrapper_promise_bridge";

mixin class WebviewControllerHandleMixin {
  late final WebViewController _controller;
  final _promiseCompleter = <String, Completer>{};
  List<InjectJsObject> _injectObjects = [];
  String _startInjectSource = "";
  String _endInjectSource = "";

  PlatformWebViewController get platform => _controller.platform;

  NavigationDelegate _createNavigationDelegate(
      {NavigationDelegateWrapper? wrapper}) {
    return NavigationDelegate(
      onNavigationRequest: wrapper?.onNavigationRequest,
      onPageStarted: (url) {
        _clearPreviousPromise();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _injectStartJs();
        });
        wrapper?.onPageStarted?.call(url);
      },
      onPageFinished: (url) async {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _injectEndJs();
        });
        wrapper?.onPageFinished?.call(url);
      },
      onProgress: wrapper?.onProgress,
      onWebResourceError: wrapper?.onWebResourceError,
      onUrlChange: wrapper?.onUrlChange,
      onHttpAuthRequest: wrapper?.onHttpAuthRequest,
      onHttpError: wrapper?.onHttpError,
      // onSslAuthError: wrapper?.onSslAuthError,
    );
  }

  void addInjectJsObject(List<InjectJsObject> list) {
    _injectObjects = list;
    var startList =
        _injectObjects.where((e) => e.injectionTime == InjectionTime.pageStart);
    var startInjectObjectJs = startList.map((e) {
      return InjectJsUtil.generateInjectJs(e);
    }).join("\n");
    _startInjectSource =
        InjectJsUtil.generatePageStartInjectJs(startInjectObjectJs);

    var endList =
        _injectObjects.where((e) => e.injectionTime == InjectionTime.pageEnd);
    var endInjectObjectJs = endList.map((e) {
      return InjectJsUtil.generateInjectJs(e);
    }).join("\n");
    _endInjectSource = InjectJsUtil.generatePageEndInjectJs(endInjectObjectJs);
  }

  void _injectStartJs() {
    if (_startInjectSource.isNotEmpty) {
      _controller.runJavaScript(_startInjectSource);
    }
  }

  void _injectEndJs() {
    if (_endInjectSource.isNotEmpty) {
      _controller.runJavaScript(_endInjectSource);
    }
  }

  void _clearPreviousPromise() {
    for (var completer in _promiseCompleter.values) {
      if (!completer.isCompleted) {
        completer.completeError("promise timeout");
      }
    }
    _promiseCompleter.clear();
  }

  /// 处理 promise 回调
  void _handlePromiseMessage(JavaScriptMessage message) {
    String? funcId;
    try {
      var callData = jsonDecode(message.message) as Map<String, dynamic>;
      funcId = callData["funcId"];
      var completer = _promiseCompleter[funcId];
      if (null == completer) {
        return;
      }
      var error = callData["error"];
      try {
        error = jsonDecode(error);
      } catch (e) {}
      if (null != error) {
        completer.completeError(error);
        return;
      }
      var result = callData["result"];
      try {
        result = jsonDecode(result);
      } catch (e) {}
      if (null != result) {
        completer.complete(result);
      } else {
        // return  void
        completer.complete();
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);
    } finally {
      if (funcId != null) {
        _promiseCompleter.remove(funcId);
      }
    }
  }

  /// 执行 js 并返回结果  支持 promise
  Future<Object> _runJavaScriptReturningResult(String javaScript) {
    final funcId = "native_completer_${DateTime.now().millisecondsSinceEpoch}";
    final completer = _promiseCompleter[funcId] = Completer<Object>();
    final javaScriptSource = """
 try{
    var result = (function(){return $javaScript;})();
    // check result is promise
    if(result instanceof Promise){
      result.then(function(result){
        $kPromiseHandleJsObject.postMessage(JSON.stringify({
          "funcId": "$funcId",
          "result": result
        }));
      }, function(error){
       $kPromiseHandleJsObject.postMessage(JSON.stringify({
          "funcId": "$funcId",
          "error": JSON.stringify(error)
        }));
      });
    }else{
       $kPromiseHandleJsObject.postMessage(JSON.stringify({
          "funcId": "$funcId",
          "result": result
        }));
    }
 }catch(e){
    $kPromiseHandleJsObject.postMessage(JSON.stringify({
      "funcId": "$funcId",
      "error":  e.message,
    }));
 }
    """;
    _controller.runJavaScript(javaScriptSource);
    return completer.future;
  }

  void _parseInjectCallback(JavaScriptMessage message) async {
    try {
      final injectList = _injectObjects;
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
        callback.call(param);
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);
    }
  }
}
