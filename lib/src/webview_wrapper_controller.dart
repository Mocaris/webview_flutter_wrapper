part of 'webview_wrapper.dart';

///
/// @Author mocaris
/// @Date 2026-02-04
/// @Since

const String _kPromiseHandleObject = "_webview_promise_handle";

class WebviewWrapperController {
  final WebViewController _controller;

  final _promiseCompleter = <String, Completer>{};

  WebviewWrapperController(
      {void Function(WebViewPermissionRequest request)? onPermissionRequest})
      : this.fromPlatformCreationParams(
          const PlatformWebViewControllerCreationParams(),
          onPermissionRequest: onPermissionRequest,
        );

  WebviewWrapperController.fromPlatformCreationParams(
    PlatformWebViewControllerCreationParams params, {
    void Function(WebViewPermissionRequest request)? onPermissionRequest,
  }) : this.fromPlatform(
          PlatformWebViewController(params),
          onPermissionRequest: onPermissionRequest,
        );

  WebviewWrapperController.fromPlatform(
    PlatformWebViewController platform, {
    void Function(WebViewPermissionRequest request)? onPermissionRequest,
  }) : _controller = WebViewController.fromPlatform(platform,
            onPermissionRequest: onPermissionRequest) {
    _controller.addJavaScriptChannel(_kPromiseHandleObject,
        onMessageReceived: _handlePromiseMessage);
  }

  void _clearPreviousPromise() {
    _promiseCompleter.clear();
  }

  Future<void> loadFile(String absoluteFilePath) {
    return _controller.loadFile(absoluteFilePath);
  }

  Future<void> loadFlutterAsset(String key) {
    assert(key.isNotEmpty);
    return _controller.loadFlutterAsset(key);
  }

  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    assert(html.isNotEmpty);
    return _controller.loadHtmlString(html, baseUrl: baseUrl);
  }

  Future<void> loadRequest(
    Uri uri, {
    LoadRequestMethod method = LoadRequestMethod.get,
    Map<String, String> headers = const <String, String>{},
    Uint8List? body,
  }) {
    return _controller.loadRequest(
      uri,
      method: method,
      headers: headers,
      body: body,
    );
  }

  Future<String?> currentUrl() {
    return _controller.currentUrl();
  }

  Future<bool> canGoBack() {
    return _controller.canGoBack();
  }

  Future<bool> canGoForward() {
    return _controller.canGoForward();
  }

  Future<void> goBack() {
    return _controller.goBack();
  }

  Future<void> goForward() {
    return _controller.goForward();
  }

  Future<void> reload() {
    return _controller.reload();
  }

  Future<void> setNavigationDelegate(NavigationDelegate delegate) {
    return _controller.setNavigationDelegate(delegate);
  }

  Future<void> clearCache() {
    return _controller.clearCache();
  }

  Future<void> clearLocalStorage() {
    return _controller.clearLocalStorage();
  }

  Future<void> runJavaScript(String javaScript) {
    return _controller.runJavaScript(javaScript);
  }

  Future<Object> runJavaScriptReturningResult(String javaScript) {
    return _runJavaScriptReturningResult(javaScript);
  }

  Future<void> addJavaScriptChannel(
    String name, {
    required void Function(JavaScriptMessage) onMessageReceived,
  }) {
    assert(name != _kJsObject && name != _kPromiseHandleObject);
    return _controller.addJavaScriptChannel(
      name,
      onMessageReceived: onMessageReceived,
    );
  }

  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    assert(javaScriptChannelName != _kJsObject &&
        javaScriptChannelName != _kPromiseHandleObject);
    return _controller.removeJavaScriptChannel(javaScriptChannelName);
  }

  Future<String?> getTitle() {
    return _controller.getTitle();
  }

  Future<void> scrollTo(int x, int y) {
    return _controller.scrollTo(x, y);
  }

  Future<void> scrollBy(int x, int y) {
    return _controller.scrollBy(x, y);
  }

  Future<Offset> getScrollPosition() {
    return _controller.getScrollPosition();
  }

  Future<void> enableZoom(bool enabled) {
    return _controller.enableZoom(enabled);
  }

  Future<void> setBackgroundColor(Color color) {
    return _controller.setBackgroundColor(color);
  }

  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) {
    return _controller.setJavaScriptMode(javaScriptMode);
  }

  Future<void> setUserAgent(String? userAgent) {
    return _controller.setUserAgent(userAgent);
  }

  Future<void> setOnConsoleMessage(
      void Function(JavaScriptConsoleMessage message) onConsoleMessage) {
    return _controller.setOnConsoleMessage(onConsoleMessage);
  }

  Future<String?> getUserAgent() {
    return _controller.getUserAgent();
  }
}

extension WebviewWrapperControllerExt on WebviewWrapperController {
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

  Future<Object> _runJavaScriptReturningResult(String javaScript) {
    final funcId = "native_completer_${DateTime.now().millisecondsSinceEpoch}";
    final completer = _promiseCompleter[funcId] = Completer<Object>();
    final javaScriptSource = """
 try{
    var result = (function(){return $javaScript;})();
    // check result is promise
    if(result instanceof Promise){
      result.then(function(result){
        ${_kPromiseHandleObject}.postMessage(JSON.stringify({
          "funcId": "$funcId",
          "result": result
        }));
      }, function(error){
       ${_kPromiseHandleObject}.postMessage(JSON.stringify({
          "funcId": "$funcId",
          "error": JSON.stringify(error)
        }));
      });
    }else{
       ${_kPromiseHandleObject}.postMessage(JSON.stringify({
          "funcId": "$funcId",
          "result": result
        }));
    }
 }catch(e){
    ${_kPromiseHandleObject}.postMessage(JSON.stringify({
      "funcId": "$funcId",
      "error":  e.message,
    }));
 }
    """;
    _controller.runJavaScript(javaScriptSource);
    return completer.future;
  }
}
