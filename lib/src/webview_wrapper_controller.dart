part of 'webview_wrapper_widget.dart';

/// look at [WebViewController]
/// @Author mocaris
/// @Date 2026-02-04
/// @Since

class WebviewWrapperController
    with WebviewControllerHandleMixin
    implements WebViewController {
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
    _controller.addJavaScriptChannel(
      kPromiseHandleJsObject,
      onMessageReceived: _handlePromiseMessage,
    );
    _controller.addJavaScriptChannel(
      kWebviewHandleJsObject,
      onMessageReceived: _parseInjectCallback,
    );
    _controller.setNavigationDelegate(_createNavigationDelegate());
  }

  @override
  Future<void> loadFile(String absoluteFilePath) {
    return _controller.loadFile(absoluteFilePath);
  }

  @override
  Future<void> loadFlutterAsset(String key) {
    assert(key.isNotEmpty);
    return _controller.loadFlutterAsset(key);
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    assert(html.isNotEmpty);
    return _controller.loadHtmlString(html, baseUrl: baseUrl);
  }

  @override
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

  @override
  Future<String?> currentUrl() {
    return _controller.currentUrl();
  }

  @override
  Future<bool> canGoBack() {
    return _controller.canGoBack();
  }

  @override
  Future<bool> canGoForward() {
    return _controller.canGoForward();
  }

  @override
  Future<void> goBack() {
    return _controller.goBack();
  }

  @override
  Future<void> goForward() {
    return _controller.goForward();
  }

  @override
  Future<void> reload() {
    return _controller.reload();
  }

  @Deprecated('Use setNavigationDelegateWrapper instead')
  @override
  Future<void> setNavigationDelegate(NavigationDelegate delegate) {
    return _controller.setNavigationDelegate(delegate);
  }

  Future<void> setNavigationDelegateWrapper(
      NavigationDelegateWrapper delegate) {
    return _controller
        .setNavigationDelegate(_createNavigationDelegate(wrapper: delegate));
  }

  @override
  Future<void> clearCache() {
    return _controller.clearCache();
  }

  @override
  Future<void> clearLocalStorage() {
    return _controller.clearLocalStorage();
  }

  @override
  Future<void> runJavaScript(String javaScript) {
    return _controller.runJavaScript(javaScript);
  }

  /// This method is compatible with calling the js function to return the promise type
  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) {
    return _runJavaScriptReturningResult(javaScript);
  }

  @override
  Future<void> addJavaScriptChannel(
    String name, {
    required void Function(JavaScriptMessage) onMessageReceived,
  }) {
    assert(name != kWebviewHandleJsObject && name != kPromiseHandleJsObject);
    return _controller.addJavaScriptChannel(
      name,
      onMessageReceived: onMessageReceived,
    );
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    assert(javaScriptChannelName != kWebviewHandleJsObject &&
        javaScriptChannelName != kPromiseHandleJsObject);
    return _controller.removeJavaScriptChannel(javaScriptChannelName);
  }

  @override
  Future<String?> getTitle() {
    return _controller.getTitle();
  }

  @override
  Future<void> scrollTo(int x, int y) {
    return _controller.scrollTo(x, y);
  }

  @override
  Future<void> scrollBy(int x, int y) {
    return _controller.scrollBy(x, y);
  }

  @override
  Future<Offset> getScrollPosition() {
    return _controller.getScrollPosition();
  }

  @override
  Future<void> enableZoom(bool enabled) {
    return _controller.enableZoom(enabled);
  }

  @override
  Future<void> setBackgroundColor(Color color) {
    return _controller.setBackgroundColor(color);
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) {
    return _controller.setJavaScriptMode(javaScriptMode);
  }

  @override
  Future<void> setUserAgent(String? userAgent) {
    return _controller.setUserAgent(userAgent);
  }

  @override
  Future<void> setOnConsoleMessage(
      void Function(JavaScriptConsoleMessage message) onConsoleMessage) {
    return _controller.setOnConsoleMessage(onConsoleMessage);
  }

  @override
  Future<void> setOnJavaScriptAlertDialog(
    Future<void> Function(JavaScriptAlertDialogRequest request)
        onJavaScriptAlertDialog,
  ) {
    return _controller.setOnJavaScriptAlertDialog(onJavaScriptAlertDialog);
  }

  @override
  Future<void> setOnJavaScriptConfirmDialog(
    Future<bool> Function(JavaScriptConfirmDialogRequest request)
        onJavaScriptConfirmDialog,
  ) {
    return _controller.setOnJavaScriptConfirmDialog(onJavaScriptConfirmDialog);
  }

  @override
  Future<void> setOnJavaScriptTextInputDialog(
    Future<String> Function(JavaScriptTextInputDialogRequest request)
        onJavaScriptTextInputDialog,
  ) {
    return _controller
        .setOnJavaScriptTextInputDialog(onJavaScriptTextInputDialog);
  }

  @override
  Future<String?> getUserAgent() {
    return _controller.getUserAgent();
  }

  @override
  Future<void> setOnScrollPositionChange(
    void Function(ScrollPositionChange change)? onScrollPositionChange,
  ) {
    return _controller.setOnScrollPositionChange(onScrollPositionChange);
  }

  @override
  Future<void> setVerticalScrollBarEnabled(bool enabled) {
    return _controller.setVerticalScrollBarEnabled(enabled);
  }

  @override
  Future<void> setHorizontalScrollBarEnabled(bool enabled) {
    return _controller.setHorizontalScrollBarEnabled(enabled);
  }

  @override
  Future<bool> supportsSetScrollBarsEnabled() async {
    return _controller.supportsSetScrollBarsEnabled();
  }

  @override
  Future<void> setOverScrollMode(WebViewOverScrollMode mode) async {
    return _controller.setOverScrollMode(mode);
  }
}
