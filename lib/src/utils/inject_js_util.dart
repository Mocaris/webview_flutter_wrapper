import 'package:webviwe_flutter_wrapper/webviwe_flutter_wrapper.dart';

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
            "${t.key}: function (params) {return _${e.name}_callNative('${t.key}',params);}")
        .join(",");
    return """if (window.${e.name} == undefined) {
  function _${e.name}_callNative(method, params) {
    return $kWebviewHandleJsObject.postMessage(JSON.stringify({ 'object': '${e.name}', 'method': method, 'params': params }));
  };
  window.${e.name} =  { $methods };
    ${e.injectJsScript != null ? "(function (){${e.injectJsScript}})();" : ''}
  function _dispatch${e.name}Event() { window.dispatchEvent(new CustomEvent('on${e.name}Ready')); }
  if (window.document.readyState === 'complete') { _dispatch${e.name}Event(); } else { window.addEventListener("load", _dispatch${e.name}Event); }
}""";
  }

  /// 生成页面开始注入的js
  /// page 只会注入一次
  /// 注入完成后触发onPageStartScriptReady事件
  static String generatePageStartInjectJs(String source) {
    return """(function _runStartScript() {
  if (!window || !window.document.readyState) {
    setTimeout(_runStartScript, 20);
    return;
  }
  if (window.__WRAPPER_INJECT_START__) return;
  window.__WRAPPER_INJECT_START__ = true;
  try { $source; } catch (e) { console.error(e); }
  function _dispatchEvent() { window.dispatchEvent(new CustomEvent('$kOnPageStartScriptReadyEvent')); }
  if (window.document.readyState === 'complete') { _dispatchEvent(); } else { window.addEventListener("load", _dispatchEvent); }
})();""";
  }

  /// 生成页面结束注入的js
  /// page 只会注入一次
  /// 注入完成后触发onPageEndScriptReady事件
  static String generatePageEndInjectJs(String source) {
    return """(function () {
  if (window.__WRAPPER_INJECT_END__) return;
  window.__WRAPPER_INJECT_END__ = true;
  function _runEndScript() {
    try { $source; } catch (e) { console.error(e); }
    window.dispatchEvent(new CustomEvent('$kOnPageEndScriptReadyEvent'));
  }
  if (document.readyState !== 'complete') {
    window.addEventListener("load", _runEndScript);
    return;
  }
  _runEndScript();
})();""";
  }
}
