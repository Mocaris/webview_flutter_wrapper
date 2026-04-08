import 'package:webviwe_flutter_wrapper/src/utils/inject_js_util.dart';

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
  final String name;

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
    required this.name,
    required this.injectionTime,
    this.injectJsScript,
    required this.functions,
  });
}

class InjectObjectManager {
  final Set<InjectJsObject> injectObjects = {};

  String _startInjectSource = "";

  String get startInjectJsScript => _startInjectSource;
  String _endInjectSource = "";

  String get endInjectJsScript => _endInjectSource;

  void assignAllInjectJsObject({
    required Iterable<InjectJsObject> list,
  }) {
    injectObjects.clear();
    injectObjects.addAll(list);
    _updateInjectJs();
  }

  void addInjectJsObjectList({
    required Iterable<InjectJsObject> list,
  }) {
    injectObjects.addAll(list);
    _updateInjectJs();
  }

  void removeInjectJsObject({
    required InjectJsObject object,
  }) {
    injectObjects.remove(object);
    _updateInjectJs();
  }

  void removeInjectJsObjectByName({
    required String objectName,
  }) {
    injectObjects.removeWhere((element) => element.name == objectName);
    _updateInjectJs();
  }

  void clearInjectJsObject() {
    injectObjects.clear();
    _updateInjectJs();
  }

  void clearStartInjectJsObject() {
    injectObjects.removeWhere(
        (element) => element.injectionTime == InjectionTime.pageStart);
    _updateInjectJs();
  }

  void clearEndInjectJsObject() {
    injectObjects.removeWhere(
        (element) => element.injectionTime == InjectionTime.pageEnd);
    _updateInjectJs();
  }

  void _updateInjectJs() {
    var startList =
        injectObjects.where((e) => e.injectionTime == InjectionTime.pageStart);
    var startInjectObjectJs = startList.map((e) {
      return InjectJsUtil.generateInjectJs(e);
    }).join("\n");
    _startInjectSource =
        InjectJsUtil.generatePageStartInjectJs(startInjectObjectJs);

    var endList =
        injectObjects.where((e) => e.injectionTime == InjectionTime.pageEnd);
    var endInjectObjectJs = endList.map((e) {
      return InjectJsUtil.generateInjectJs(e);
    }).join("\n");
    _endInjectSource = InjectJsUtil.generatePageEndInjectJs(endInjectObjectJs);
  }
}
