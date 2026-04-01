///
/// @Author mocaris
/// @Date 2026-02-04
/// @Since 0.0.1

/// 注入时机
enum InjectionTime {
  ///  inject at the start of page load
  pageStart,

  ///  inject at the end of page load
  pageEnd,
}

/// js callback with params
/// [data] will be null or any type
typedef OnJsCallback = void Function(dynamic data);

class InjectJsObject {
  /// js 对象名称
  /// inject js object name
  final String object;

  /// 注入时机
  /// js object inject time
  final InjectionTime injectionTime;

  /// 当前 js 对象开始加载时执行的 js 脚本
  /// js object inject js script
  final String? injectJsScript;

  /// 注入 js 回调函数
  /// 从 js 回调到 native
  /// register js callback to native
  final Map<String, OnJsCallback> functions;

  const InjectJsObject({
    required this.object,
    required this.injectionTime,
    this.injectJsScript,
    required this.functions,
  });
}
