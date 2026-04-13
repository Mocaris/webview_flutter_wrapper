import 'package:webview_flutter_wrapper/webview_flutter_wrapper.dart';

import '../constant/js_bridge_events.dart';

/// JavaScript injection utility class.
///
/// Provides utility methods for generating JavaScript code used in WebView
/// injection, including promise handling, object injection, and communication
/// callbacks between JavaScript and Native code.
///
/// @Author mocaris
/// @Date 2026-04-01
/// @Since 0.0.1
class InjectJsUtil {
  /// Generates JavaScript code that handles both synchronous results and Promises.
  ///
  /// Wraps the provided [javaScript] code in an IIFE (Immediately Invoked Function Expression)
  /// that can handle both synchronous return values and asynchronous Promises.
  /// The result or error is sent back to Native code via postMessage with the [funcId].
  ///
  /// Parameters:
  /// - [funcId]: Unique identifier for tracking the function call.
  /// - [javaScript]: The JavaScript code to execute.
  ///
  /// Returns a JavaScript string that will:
  /// - Execute the provided code
  /// - Handle both sync and async (Promise) results
  /// - Serialize errors properly
  /// - Send results back to Native via postMessage
  static String generateJsWithResultOrPromise({
    required String funcId,
    required String javaScript,
  }) {
    return """(function () {
  function serializeError(err) {
    if (err === null || err === undefined) return null;
    var errorObj = {message: err.message || String(err),name: err.name || 'Error',stack: err.stack};
    return errorObj;
  }
  function sendResult(result) {$kPromiseHandleJsObject.postMessage(JSON.stringify({"funcId": "$funcId","result": result}));}
  function sendError(error) {$kPromiseHandleJsObject.postMessage(JSON.stringify({"funcId": "$funcId","error": JSON.stringify(serializeError(error))}));}
  try {
    var result = (function () { return $javaScript; })();
    if (result !== null && result !== undefined && typeof result.then === 'function') {result.then(sendResult, sendError);} else {sendResult(result);}
  } catch (e) {sendError(e);}
})();
  """;
  }

  /// Generates JavaScript code for injecting a JavaScript object into WebView.
  ///
  /// Creates a JavaScript object on the window with the specified [name] and
  /// methods defined in [e].functions. After injection, it triggers a ready event
  /// by calling _callNativeEvent and adds the event name to the events array.
  ///
  /// Parameters:
  /// - [name]: The name of the JavaScript object to create on window.
  /// - [e]: The InjectJsObject configuration containing functions to expose.
  ///
  /// Returns JavaScript code that:
  /// - Checks if the object already exists (prevents duplicate injection)
  /// - Creates the object with callable methods
  /// - Notifies Native code when ready via _callNativeEvent
  /// - Registers the onReady event for later dispatch
  static String generateInjectJs(String name, InjectJsObject e) {
    final methods = e.functions.entries
        .map((t) =>
            "${t.key}: function (params) {return _callNativeFunc('$name','${t.key}',params);}")
        .join(",");
    return """if (window.$name == undefined) {
  window.$name = { $methods };
  _callNativeEvent('$name', '${JsBridgeEvents.onInjectObjectReady}');
  events.push('on${name}Ready');
}""";
  }

  /// Generates JavaScript code for page start injection.
  ///
  /// This script is injected only once per page load at the beginning of page loading.
  /// It sets up communication callbacks and dispatches the [JsBridgeEvents.onPageStartScriptReady] event
  /// after all initialization is complete.
  ///
  /// Parameters:
  /// - [source]: The JavaScript source code to inject at page start.
  ///
  /// Returns JavaScript code that:
  /// - Waits for window and document to be available
  /// - Ensures single injection via flag check (__WRAPPER_INJECT_START__)
  /// - Sets up communication infrastructure
  /// - Executes the provided source code
  /// - Dispatches ready event when complete
  static String generatePageStartInjectJs(String source) {
    return """(function _runStartScript() {
  if (!window || !document) {return setTimeout(_runStartScript, 10);}
  if (window.__WRAPPER_INJECT_START__) return;
  window.__WRAPPER_INJECT_START__ = true;
  ${_generateCommCallbackJs()}
  try { $source; } catch (e) { console.error(e); }
  events.push('${JsBridgeEvents.onPageStartScriptReadyEvent}');
  _dispatchEvent();
})();""";
  }

  /// Generates JavaScript code for page end injection.
  ///
  /// This script is injected only once per page load after the page has finished loading.
  /// It sets up communication callbacks and dispatches the [JsBridgeEvents.onPageEndScriptReady] event
  /// after all initialization is complete.
  ///
  /// Parameters:
  /// - [source]: The JavaScript source code to inject at page end.
  ///
  /// Returns JavaScript code that:
  /// - Ensures single injection via flag check (__WRAPPER_INJECT_END__)
  /// - Sets up communication infrastructure
  /// - Executes the provided source code
  /// - Dispatches ready event when complete
  static String generatePageEndInjectJs(String source) {
    return """(function () {
  if (window.__WRAPPER_INJECT_END__) return;
  window.__WRAPPER_INJECT_END__ = true;
  ${_generateCommCallbackJs()}
  try { $source; } catch (e) { console.error(e); }
  events.push('${JsBridgeEvents.onPageEndScriptReadyEvent}');
  _dispatchEvent();
})();""";
  }

  /// Generates common communication callback JavaScript code.
  ///
  /// Creates the foundational JavaScript infrastructure for JavaScript-Native communication,
  /// including:
  /// - events array for tracking pending events
  /// - _callNativeFunc for method calls from JS to Native
  /// - _callNativeEvent for event notifications from JS to Native
  /// - _dispatchEvent for dispatching custom events when page is ready
  ///
  /// This code is shared between page start and page end injections.
  ///
  /// Returns JavaScript code that provides:
  /// - Event queue management
  /// - Bidirectional communication channels
  /// - Deferred event dispatching until page load completes
  static String _generateCommCallbackJs() {
    return """let events = [];
  function _callNativeFunc(name,method,params){return $kInjectFuncHandleJsObject.postMessage(JSON.stringify({ 'object': name, 'method': method, 'params': params }));}
  function _callNativeEvent(name,event,params){return $kInjectEventHandleJsObject.postMessage(JSON.stringify({ 'object': name, 'event': event, 'params': params }));}
  function _dispatchEvent() {
    function __dispatch() {for(let event of events){window.dispatchEvent(new CustomEvent(event));} window.removeEventListener("load", __dispatch);}
    if (document.readyState !== 'complete') {return window.addEventListener("load", __dispatch);}
    __dispatch();
}""";
  }
}
