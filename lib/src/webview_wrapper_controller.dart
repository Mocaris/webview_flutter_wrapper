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
      kInjectFuncHandleJsObject,
      onMessageReceived: _parseInjectCallback,
    );
    super.setNavigationDelegate(_createNavigationDelegate());
  }

  @Deprecated('Use setNavigationDelegateWrapper instead')
  @override
  @protected
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

  /// You can use simpler functions [addInjectJsObjects]
  @protected
  @override
  Future<void> addJavaScriptChannel(
    String name, {
    required void Function(JavaScriptMessage) onMessageReceived,
  }) {
    if (name == kInjectFuncHandleJsObject && name == kPromiseHandleJsObject) {
      throw ArgumentError(
          'The name of the injected object cannot be $kInjectFuncHandleJsObject or $kPromiseHandleJsObject');
    }
    return super.addJavaScriptChannel(
      name,
      onMessageReceived: onMessageReceived,
    );
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    if (javaScriptChannelName == kInjectFuncHandleJsObject ||
        javaScriptChannelName == kPromiseHandleJsObject) {
      throw ArgumentError(
          'The name of the injected object cannot be $kInjectFuncHandleJsObject or $kPromiseHandleJsObject');
    }
    return super.removeJavaScriptChannel(javaScriptChannelName);
  }

  /// Consider setting a shorter timeout for simple operations and a longer
  /// timeout for complex asynchronous tasks.
  /// default timeout is 30 seconds
  void setJsPromiseTimeout(Duration timeout) {
    _jsPromiseTimeoutDuration = timeout;
  }

  /// Adds multiple JavaScript objects for injection in a single operation.
  ///
  /// This method adds the provided objects to the existing injection list.
  /// Objects are identified by their keys in the map, allowing easy management
  /// and removal later.
  void addInjectJsObjects(
    Map<String, InjectJsObject> objects,
  ) {
    _injectManager.addInjectJsObjects(objects);
  }

  /// Adds a single JavaScript object for injection.
  ///
  /// The [objectName] serves as a unique identifier for later removal or updates.
  /// The [object] contains the actual injection configuration including timing,
  /// functions, and optional initialization script.
  void addInjectJsObject({
    required String objectName,
    required InjectJsObject object,
  }) {
    _injectManager.addInjectJsObject(objectName: objectName, object: object);
  }

  /// Replaces all existing JavaScript injection objects with the provided ones.
  ///
  /// This is useful when you want to completely reset the injection configuration,
  /// such as when navigating to a completely different section of your app.
  ///
  void assignAllInjectJsObject(Map<String, InjectJsObject> objects) {
    _injectManager.assignAllInjectJsObject(objects: objects);
  }

  /// Removes a specific JavaScript injection object by its name.
  ///
  /// The removed object will no longer be injected on subsequent page loads.
  /// Currently loaded pages are not affected.
  void removeInjectJsObject(String objectName) {
    _injectManager.removeInjectJsObject(objectName: objectName);
  }

  /// Removes all JavaScript injection objects.
  ///
  /// After calling this method, no custom JavaScript objects will be injected
  /// on subsequent page loads. This is equivalent to calling both
  /// [clearStartInjectJsObject] and [clearEndInjectJsObject].
  ///
  void clearInjectJsObject() {
    _injectManager.clearInjectJsObject();
  }

  /// Removes all JavaScript objects scheduled for injection at page start.
  ///
  /// Objects with [InjectionTime.pageStart] will no longer be injected.
  /// Objects with [InjectionTime.pageEnd] remain unaffected.
  void clearStartInjectJsObject() {
    _injectManager.clearStartInjectJsObject();
  }

  /// Removes all JavaScript objects scheduled for injection at page end.
  ///
  /// Objects with [InjectionTime.pageEnd] will no longer be injected.
  /// Objects with [InjectionTime.pageStart] remain unaffected.
  void clearEndInjectJsObject() {
    _injectManager.clearEndInjectJsObject();
  }
}
