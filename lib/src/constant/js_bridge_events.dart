/// JavaScript Bridge event constants.
///
/// Defines all event names used for communication between JavaScript and Native code
/// during the WebView injection process. These events are dispatched to notify when
/// specific injection phases are completed.
interface class JsBridgeEvents {
  /// Event triggered after JavaScript scripts are injected at page start.
  ///
  /// This event is dispatched when all scripts configured for page start injection
  /// have been successfully injected and executed. Listeners can use this event
  /// to perform actions that require the start injection scripts to be ready.
  static const String onPageStartScriptReadyEvent = "onPageStartScriptReady";

  /// Event triggered after JavaScript scripts are injected at page end.
  ///
  /// This event is dispatched when all scripts configured for page end injection
  /// have been successfully injected and executed. Listeners can use this event
  /// to perform actions that require the end injection scripts to be ready.
  static const String onPageEndScriptReadyEvent = "onPageEndScriptReady";

  /// Event triggered when an injected JavaScript object is ready.
  ///
  /// This event is dispatched after a specific JavaScript object has been
  /// successfully injected into the WebView and is available for use.
  /// The event name follows the pattern: 'on{ObjectName}Ready'
  static const String onInjectObjectReady = 'onInjectedReady';
}
