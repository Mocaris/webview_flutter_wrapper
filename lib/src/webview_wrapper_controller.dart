part of 'webview_wrapper_widget.dart';

/// extension for [WebViewController]
/// @Author mocaris
/// @Date 2026-02-04
/// @Since

class WebviewWrapperController extends WebViewController
    with WebviewControllerHandleMixin {
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
  }) {
    super.addJavaScriptChannel(
      kPromiseHandleJsObject,
      onMessageReceived: _handlePromiseMessage,
    );
    super.addJavaScriptChannel(
      kWebviewHandleJsObject,
      onMessageReceived: _parseInjectCallback,
    );
    super.setNavigationDelegate(_createNavigationDelegate());
  }

  @Deprecated('Use setNavigationDelegateWrapper instead')
  @override
  Future<void> setNavigationDelegate(NavigationDelegate delegate) {
    return super.setNavigationDelegate(delegate);
  }

  Future<void> setNavigationDelegateWrapper(
      NavigationDelegateWrapper delegate) {
    return super
        .setNavigationDelegate(_createNavigationDelegate(wrapper: delegate));
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
    return super.addJavaScriptChannel(
      name,
      onMessageReceived: onMessageReceived,
    );
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    assert(javaScriptChannelName != kWebviewHandleJsObject &&
        javaScriptChannelName != kPromiseHandleJsObject);
    return super.removeJavaScriptChannel(javaScriptChannelName);
  }
}
