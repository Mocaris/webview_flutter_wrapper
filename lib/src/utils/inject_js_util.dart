import 'package:webviwe_flutter_wrapper/src/webview_wrapper_widget.dart';
import 'package:webviwe_flutter_wrapper/webviwe_flutter_wrapper.dart';

///
/// @Author mocaris
/// @Date 2026-04-01
/// @Since
class InjectJsUtil {
  /// 生成注入的js
  /// 注入完成后触发on${e.object}Ready事件
  static String generateInjectJs(InjectJsObject e) {
    final methods = e.functions.entries.map((t) =>
        "${t.key}: function (params) {return _${e.object}_callNative('${t.key}',params);},");

    return """
    if(window.${e.object} == undefined) {
       function _${e.object}_callNative(method, params) {
         return $kWebviewHandleJsObject.postMessage(JSON.stringify({'object': '${e.object}', 'method': method, 'params': params }));
       };
      ${e.object} =  {$methods}
      window.${e.object} = ${e.object};
      ${e.injectJsScript != null ? "(function (){${e.injectJsScript})();" : ''}
      window.dispatchEvent(new CustomEvent('on${e.object}Ready'));
    }
      """;
  }

  /// 生成页面开始注入的js
  /// 注入完成后触发onPageStartScriptReady事件
  static String generatePageStartInjectJs(String source) {
    return """
        (function () {
            if(window.__WRAPPER_INJECT_START__) return;
            window.__WRAPPER_INJECT_START__ = true;
            $source
            window.dispatchEvent(new CustomEvent('$kOnPageStartScriptReadyEvent'));
        })();
    """;
  }

  /// 生成页面结束注入的js
  /// 注入完成后触发onPageEndScriptReady事件
  static String generatePageEndInjectJs(String source) {
    return """
        (function () {
            if(window.__WRAPPER_INJECT_END__) return;
            window.__WRAPPER_INJECT_END__ = true;
            $source
            window.dispatchEvent(new CustomEvent('$kOnPageEndScriptReadyEvent'));
        })();
    """;
  }
}
