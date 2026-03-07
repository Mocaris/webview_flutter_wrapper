///
/// @Author mocaris
/// @Date 2026-02-05
/// @Since
part of '../webview_wrapper.dart';

///js 脚本页面开始注入后事件
const String _onPageStartScriptReadyEvent = "onPageStartScriptReady";

///js 脚本页面结束注入后事件
const String _onPageEndScriptReadyEvent = "onPageEndScriptReady";

///处理 js 回调
const String _kWebviewHandleJsObject = "_webview_wrapper_bridge";

///处理 promise 回调
const String _kPromiseHandleJsObject = "_webview_wrapper_promise_bridge";

mixin class WebviewWrapperMixin {
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
      return _generateInjectJs(e);
    }).join("\n");
    _startInjectSource = _generatePageStartInjectJs(startInjectObjectJs);

    var endList =
        _injectObjects.where((e) => e.injectionTime == InjectionTime.pageEnd);
    var endInjectObjectJs = endList.map((e) {
      return _generateInjectJs(e);
    }).join("\n");
    _endInjectSource = _generatePageEndInjectJs(endInjectObjectJs);
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
        $_kPromiseHandleJsObject.postMessage(JSON.stringify({
          "funcId": "$funcId",
          "result": result
        }));
      }, function(error){
       $_kPromiseHandleJsObject.postMessage(JSON.stringify({
          "funcId": "$funcId",
          "error": JSON.stringify(error)
        }));
      });
    }else{
       $_kPromiseHandleJsObject.postMessage(JSON.stringify({
          "funcId": "$funcId",
          "result": result
        }));
    }
 }catch(e){
    $_kPromiseHandleJsObject.postMessage(JSON.stringify({
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

/// 生成注入的js
/// 注入完成后触发on${e.object}Ready事件
String _generateInjectJs(InjectJsObject e) {
  final methods = e.functions.entries
      .map((t) =>
          "${t.key}: function (params) {return _${e.object}_callNative('${t.key}',params);}")
      .join(",\n");

  return """
    if(window.${e.object} == undefined) {
       function _${e.object}_callNative(method, params) {
         return $_kWebviewHandleJsObject.postMessage(JSON.stringify({'object': '${e.object}', 'method': method, 'params': params }));
       };
      ${e.object} =  {
        $methods
      }
      window.${e.object} = ${e.object};
      window.dispatchEvent(new CustomEvent('on${e.object}Ready'));
    }
      """;
}

/// 生成页面开始注入的js
/// 注入完成后触发onPageStartScriptReady事件
String _generatePageStartInjectJs(String source) {
  return """
        (function () {
            if(window.__WRAPPER_INJECT_START__) return;
            window.__WRAPPER_INJECT_START__ = true;
            $source
            window.dispatchEvent(new CustomEvent('$_onPageStartScriptReadyEvent'));
        })();
    """;
}

/// 生成页面结束注入的js
/// 注入完成后触发onPageEndScriptReady事件
String _generatePageEndInjectJs(String source) {
  return """
        (function () {
            if(window.__WRAPPER_INJECT_END__) return;
            window.__WRAPPER_INJECT_END__ = true;
            $source
            window.dispatchEvent(new CustomEvent('$_onPageEndScriptReadyEvent'));
        })();
    """;
}
