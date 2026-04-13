part of 'webview_wrapper_widget.dart';

/// Enhanced WebView controller with advanced JavaScript integration capabilities.
///
/// [WebviewWrapperController] extends the base [WebViewController] to provide:
/// - JavaScript Promise support for async operations
/// - Bidirectional JavaScript-Native communication via injection objects
/// - Custom timeout control for JavaScript execution
/// - Automatic JavaScript injection at different page lifecycle stages
/// - Protected internal channels for framework functionality
///
/// This controller manages JavaScript injection objects that enable seamless
/// communication between Flutter and WebView content. It supports both
/// synchronous and asynchronous JavaScript execution with proper error handling.
///
/// Key features:
/// - **Promise Support**: Execute JavaScript that returns Promises and await results
/// - **Object Injection**: Inject JavaScript objects with callable Native methods
/// - **Lifecycle Management**: Inject scripts at page start or page end
/// - **Timeout Control**: Customize execution timeout for JavaScript operations
/// - **Event System**: Listen to injection ready events and page load states
///
/// @Author mocaris
/// @Date 2026-02-04
/// @Since 0.0.1
class WebviewWrapperController extends WebViewController
    with WebviewControllerHandleMixin {
  WebviewWrapperController({
    void Function(WebViewPermissionRequest request)? onPermissionRequest,
  }) : this.fromPlatformCreationParams(
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
    super.platform, {
    super.onPermissionRequest,
  }) : super.fromPlatform() {
    super.addJavaScriptChannel(
      kPromiseHandleJsObject,
      onMessageReceived: _handlePromiseMessage,
    );
    super.addJavaScriptChannel(
      kInjectFuncHandleJsObject,
      onMessageReceived: _parseInjectFuncCallback,
    );
    super.addJavaScriptChannel(
      kInjectEventHandleJsObject,
      onMessageReceived: _parseInjectEventCallback,
    );
    super.setNavigationDelegate(_createNavigationDelegate());
  }

  @Deprecated('Use setNavigationDelegateWrapper instead')
  @override
  @protected
  Future<void> setNavigationDelegate(NavigationDelegate delegate) {
    var delegate0 = delegate;
    if (delegate is NavigationDelegateWrapper) {
      delegate0 = _createNavigationDelegate(wrapper: delegate);
    }
    return super.setNavigationDelegate(delegate0);
  }

  /// Sets an enhanced navigation delegate with extended lifecycle callbacks.
  ///
  /// This method provides a more powerful alternative to [setNavigationDelegate] by using
  /// [NavigationDelegateWrapper], which offers additional callbacks and better integration
  /// with the JavaScript injection system.
  ///
  /// The wrapper automatically handles:
  /// - JavaScript injection at appropriate page lifecycle stages
  /// - Event dispatching for injection readiness
  /// - Navigation state management
  /// - Page load progress tracking
  ///
  /// Parameters:
  /// - [delegate]: The navigation delegate wrapper containing enhanced callbacks
  ///   for navigation events, page loading states, and JavaScript injection hooks.
  /// See also:
  /// - [NavigationDelegateWrapper] for available callback options
  /// - [setNavigationDelegate] for the basic version (deprecated)
  Future<void> setNavigationDelegateWrapper(
      NavigationDelegateWrapper delegate) {
    return super
        .setNavigationDelegate(_createNavigationDelegate(wrapper: delegate));
  }

  /// use [runJavaScriptReturningResultWithTimeout] with custom timeout
  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) {
    return _runJavaScriptReturningResult(javaScript);
  }

  /// Executes JavaScript code and returns the result with custom timeout support.
  ///
  /// This method extends [runJavaScriptReturningResult] by allowing you to specify
  /// a custom timeout duration for JavaScript execution. It supports both synchronous
  /// return values and asynchronous Promises.
  ///
  /// Parameters:
  /// - [javaScript]: The JavaScript code to execute in the WebView.
  /// - [timeout]: Optional custom timeout duration. If not provided, uses
  ///   [kDefaultPromiseTimeout] (default 30 seconds).
  ///
  /// Returns a [Future] that completes with the JavaScript execution result.
  /// The result can be of various types depending on what the JavaScript returns.
  ///
  /// Throws:
  /// - [TimeoutException] if the JavaScript execution exceeds the specified timeout.
  /// - [PlatformException] if there's an error executing the JavaScript.
  ///
  Future<Object> runJavaScriptReturningResultWithTimeout(
    String javaScript, {
    Duration? timeout,
  }) {
    return _runJavaScriptReturningResult(javaScript, timeout: timeout);
  }

  /// You can use simpler functions [addInjectJsObjects]
  @protected
  @override
  Future<void> addJavaScriptChannel(
    String name, {
    required void Function(JavaScriptMessage) onMessageReceived,
  }) {
    if (name == kInjectFuncHandleJsObject ||
        name == kInjectEventHandleJsObject ||
        name == kPromiseHandleJsObject) {
      throw ArgumentError(
          'The name of the injected object cannot be $kInjectFuncHandleJsObject or $kInjectEventHandleJsObject or $kPromiseHandleJsObject');
    }
    return super.addJavaScriptChannel(
      name,
      onMessageReceived: onMessageReceived,
    );
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    if (javaScriptChannelName == kInjectFuncHandleJsObject ||
        javaScriptChannelName == kInjectEventHandleJsObject ||
        javaScriptChannelName == kPromiseHandleJsObject) {
      throw ArgumentError(
          'The name of the injected object cannot be $kInjectFuncHandleJsObject or $kInjectEventHandleJsObject or $kPromiseHandleJsObject');
    }
    return super.removeJavaScriptChannel(javaScriptChannelName);
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
