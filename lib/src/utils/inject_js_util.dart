import 'package:webview_flutter_wrapper/webview_flutter_wrapper.dart';

///
/// @Author mocaris
/// @Date 2026-04-01
/// @Since
class InjectJsUtil {
  /// 生成js的promise
  static String generateRunJsPromise({
    required String funcId,
    required String javaScript,
  }) {
// """
//     (function () {
//   function serializeError(err) {
//     if (err === null || err === undefined) return null;
//     var errorObj = {
//       message: err.message || String(err),
//       name: err.name || 'Error',
//       stack: err.stack
//     };
//     return errorObj;
//   }
//   function sendResult(result) {
//     $kPromiseHandleJsObject.postMessage(JSON.stringify({
//       "funcId": "$funcId",
//       "result": result
//     }));
//   }
//   function sendError(error) {
//     $kPromiseHandleJsObject.postMessage(JSON.stringify({
//       "funcId": "$funcId",
//       "error": JSON.stringify(serializeError(error))
//     }));
//   }
//   try {
//     var result = (function () { return $javaScript; })();
//     if (result !== null && result !== undefined && typeof result.then === 'function') {
//       result.then(sendResult, sendError);
//     } else {
//       sendResult(result);
//     }
//   } catch (e) {
//     sendError(e);
//   }
// })();
//   """
//
    return """(function(){function serializeError(err){if(err===null||err===undefined)return null;var errorObj={message:err.message||String(err),name:err.name||'Error',stack:err.stack};return errorObj}function sendResult(result){$kPromiseHandleJsObject.postMessage(JSON.stringify({"funcId":"$funcId","result":result}))}function sendError(error){$kPromiseHandleJsObject.postMessage(JSON.stringify({"funcId":"$funcId","error":JSON.stringify(serializeError(error))}))}try{var result=(function(){return $javaScript})();if(result!==null&&result!==undefined&&typeof result.then==='function'){result.then(sendResult,sendError)}else{sendResult(result)}}catch(e){sendError(e)}})();""";
  }

  /// 生成注入的js
  /// 注入完成后触发on${InjectJsObject.name}Ready事件
  static String generateInjectJs(InjectJsObject e) {
    final methods = e.functions.entries
        .map((t) =>
            "${t.key}: function (params) {return _callNativeFunc('${e.name}','${t.key}',params);}")
        .join(",");
    return """if (window.${e.name} == undefined) {
  window.${e.name} = { $methods };
  ${e.injectJsScript != null ? "(function (){${e.injectJsScript}})();" : ''}
  _dispatchEvent('on${e.name}Ready');
}""";
  }

  /// 生成页面开始注入的js
  /// page 只会注入一次
  /// 注入完成后触发onPageStartScriptReady事件
  static String generatePageStartInjectJs(String source) {
    return """(function _runStartScript() {
  if (!window || !document) {return setTimeout(_runStartScript, 10);}
  if (window.__WRAPPER_INJECT_START__) return;
  window.__WRAPPER_INJECT_START__ = true;
  ${_generateCommCallbackJs()}
  try { $source; } catch (e) { console.error(e); }
  _dispatchEvent('$kOnPageStartScriptReadyEvent');
})();""";
  }

  /// 生成页面结束注入的js
  /// page 只会注入一次
  /// 注入完成后触发onPageEndScriptReady事件
  static String generatePageEndInjectJs(String source) {
    return """(function () {
  if (window.__WRAPPER_INJECT_END__) return;
  window.__WRAPPER_INJECT_END__ = true;
  ${_generateCommCallbackJs()}
  try { $source; } catch (e) { console.error(e); }
  _dispatchEvent('$kOnPageEndScriptReadyEvent');
})();""";
  }

  static String _generateCommCallbackJs() {
    return """function _callNativeFunc(name,method,params){return $kInjectFuncHandleJsObject.postMessage(JSON.stringify({ 'object': name, 'method': method, 'params': params }));}
  function _dispatchEvent(event) {
    function __dispatch() {window.dispatchEvent(new CustomEvent(event));window.removeEventListener("load", __dispatch);}
    if (document.readyState !== 'complete') {return window.addEventListener("load", __dispatch);}
    __dispatch();
}""";
  }
}
