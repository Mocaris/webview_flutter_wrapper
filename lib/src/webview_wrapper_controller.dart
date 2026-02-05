part of 'webview_wrapper.dart';

/// look at [WebViewController]
/// @Author mocaris
/// @Date 2026-02-04
/// @Since

class WebviewWrapperController with WebviewWrapperMixin {
  @override
  final WebViewController _controller;

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
    _controller.addJavaScriptChannel(_kPromiseHandleJsObject,
        onMessageReceived: _handlePromiseMessage);
    _controller.addJavaScriptChannel(
      _kWebviewHandleJsObject,
      onMessageReceived: _parseInjectCallback,
    );
    _controller.setNavigationDelegate(_delegate);
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

  void setNavigationDelegate(NavigationDelegateWrapper delegate) {
    _delegateWrapper = delegate;
    // return _controller.setNavigationDelegate(delegate);
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
    assert(name != _kWebviewHandleJsObject && name != _kPromiseHandleJsObject);
    return _controller.addJavaScriptChannel(
      name,
      onMessageReceived: onMessageReceived,
    );
  }

  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    assert(javaScriptChannelName != _kWebviewHandleJsObject &&
        javaScriptChannelName != _kPromiseHandleJsObject);
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

  Future<void> setOnJavaScriptAlertDialog(
    Future<void> Function(JavaScriptAlertDialogRequest request)
        onJavaScriptAlertDialog,
  ) {
    return _controller.setOnJavaScriptAlertDialog(onJavaScriptAlertDialog);
  }

  Future<void> setOnJavaScriptConfirmDialog(
    Future<bool> Function(JavaScriptConfirmDialogRequest request)
        onJavaScriptConfirmDialog,
  ) {
    return _controller.setOnJavaScriptConfirmDialog(onJavaScriptConfirmDialog);
  }

  Future<void> setOnJavaScriptTextInputDialog(
    Future<String> Function(JavaScriptTextInputDialogRequest request)
        onJavaScriptTextInputDialog,
  ) {
    return _controller
        .setOnJavaScriptTextInputDialog(onJavaScriptTextInputDialog);
  }

  Future<String?> getUserAgent() {
    return _controller.getUserAgent();
  }

  Future<void> setOnScrollPositionChange(
    void Function(ScrollPositionChange change)? onScrollPositionChange,
  ) {
    return _controller.setOnScrollPositionChange(onScrollPositionChange);
  }

  Future<void> setVerticalScrollBarEnabled(bool enabled) {
    return _controller.setVerticalScrollBarEnabled(enabled);
  }

  Future<void> setHorizontalScrollBarEnabled(bool enabled) {
    return _controller.setHorizontalScrollBarEnabled(enabled);
  }

  Future<bool> supportsSetScrollBarsEnabled() async {
    return _controller.supportsSetScrollBarsEnabled();
  }

  Future<void> setOverScrollMode(WebViewOverScrollMode mode) async {
    return _controller.setOverScrollMode(mode);
  }
}
