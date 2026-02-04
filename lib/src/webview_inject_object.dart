///
/// @Author mocaris
/// @Date 2026-02-04
/// @Since

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
  /// inject js object name
  final String object;

  /// inject time
  final InjectionTime injectionTime;

  /// inject js object functions
  final Map<String, OnJsCallback> functions;

  const InjectJsObject({
    required this.object,
    required this.injectionTime,
    required this.functions,
  });
}

