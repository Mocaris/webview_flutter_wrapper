part of 'webview_wrapper.dart';

///
/// @Author mocaris
/// @Date 2026-02-04
/// @Since
abstract class InjectJsGenerate {
  static String generateInjectJs(InjectJsObject e) {
    final methods = e.functions.entries
        .map((t) =>
    "${t.key}: function (params) {return _${e.object}_callNative('${t.key}',params);}")
        .join(",\n");

    return """
    if(window.${e.object} == undefined) {
       function _${e.object}_callNative(method, params) {
         return $_kJsObject.postMessage(JSON.stringify({'object': '${e.object}', 'method': method, 'params': params }));
       };
      ${e.object} =  {
        $methods
      }
      window.${e.object} = ${e.object};
    }
      """;
  }

  //匿名执行函数
  static String generateAnonymousFunction(String source) {
    return """
(function () {
    $source
})();
    """;
  }
}
