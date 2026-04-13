import 'package:webview_flutter_wrapper/src/utils/inject_js_util.dart';

/// JavaScript object injection related classes and utilities.
///
/// Provides the ability to inject JavaScript objects into WebView, supporting
/// injection at different page loading stages and enabling bidirectional
/// communication between JavaScript and Native code.
///
/// @Author mocaris
/// @Date 2026-02-04
/// @Since 0.0.1

/// Enumeration of JavaScript object injection timing.
///
/// Defines when JavaScript objects should be injected into the WebView.
enum InjectionTime {
  /// Inject at the start of page load.
  pageStart,

  /// Inject at the end of page load.
  pageEnd,
}

/// JavaScript callback function type definition.
///
/// Used to handle callbacks from JavaScript to Native code.
/// The [data] parameter can be null or any type of data.
typedef OnJsCallback = void Function(dynamic data);

/// Configuration class for JavaScript injection objects.
///
/// Used to configure JavaScript objects to be injected into WebView, including
/// injection timing, custom scripts, and mappings of Native methods that can
/// be called from JavaScript.
///
class InjectJsObject {
  /// The timing when the JavaScript object will be injected.
  ///
  /// Determines whether the object is injected when the page starts loading
  /// or after the page has finished loading.
  final InjectionTime injectionTime;

  /// Map of functions that can be called from JavaScript.
  ///
  /// The key is the function name accessible from JavaScript, and the value
  /// is the callback function that will be executed in Native code when
  /// the JavaScript function is called.
  final Map<String, OnJsCallback> functions;

  /// Callback function executed when the JavaScript object is successfully injected.
  ///
  /// This optional callback is triggered after the JavaScript object has been
  /// successfully injected into the WebView and is ready to be used. It allows
  /// you to perform any initialization or setup tasks that depend on the
  /// injected object being available.
  final Function()? onInjectedReady;

  /// Creates an [InjectJsObject] instance.
  ///
  /// Parameters:
  /// - [injectionTime]: Required. When to inject the JavaScript object.
  /// - [injectJsScript]: Optional. Custom JavaScript code to run after injection.
  /// - [functions]: Required. Map of callable functions from JavaScript.
  const InjectJsObject({
    required this.injectionTime,
    required this.functions,
    this.onInjectedReady,
  });
}

/// Manager class for handling multiple JavaScript injection objects.
///
/// Provides methods to add, remove, and manage JavaScript objects that will
/// be injected into WebView. It automatically generates the necessary
/// JavaScript code for injection at different page loading stages.
///
class InjectObjectManager {
  /// Map of all registered JavaScript injection objects.
  ///
  /// The key is the object name that will be accessible from JavaScript,
  /// and the value is the [InjectJsObject] configuration.
  final Map<String, InjectJsObject> injectObjects = {};

  /// Generated JavaScript code for page start injection.
  String _startInjectSource = "";

  /// Gets the JavaScript code to be injected at page start.
  ///
  /// This script contains all objects configured with
  /// [InjectionTime.pageStart].
  String get startInjectJsScript => _startInjectSource;

  /// Generated JavaScript code for page end injection.
  String _endInjectSource = "";

  /// Gets the JavaScript code to be injected at page end.
  ///
  /// This script contains all objects configured with
  /// [InjectionTime.pageEnd].
  String get endInjectJsScript => _endInjectSource;

  /// Replaces all injection objects with the provided map.
  ///
  /// Clears existing objects and adds all objects from the [objects] map.
  /// Automatically updates the injection scripts.
  ///
  /// Parameters:
  /// - [objects]: Map of injection objects to set.
  void assignAllInjectJsObject({
    required Map<String, InjectJsObject> objects,
  }) {
    injectObjects.clear();
    injectObjects.addAll(objects);
    _updateInjectJs();
  }

  /// Adds multiple injection objects to the manager.
  ///
  /// Merges the provided [objects] map with existing objects.
  /// Automatically updates the injection scripts.
  ///
  /// Parameters:
  /// - [objects]: Map of injection objects to add.
  void addInjectJsObjects(
    Map<String, InjectJsObject> objects,
  ) {
    injectObjects.addAll(objects);
    _updateInjectJs();
  }

  /// Adds a single injection object to the manager.
  ///
  /// If an object with the same [objectName] already exists, it will be replaced.
  /// Automatically updates the injection scripts.
  ///
  /// Parameters:
  /// - [objectName]: Name of the JavaScript object.
  /// - [object]: The injection object configuration.
  void addInjectJsObject({
    required String objectName,
    required InjectJsObject object,
  }) {
    injectObjects[objectName] = object;
    _updateInjectJs();
  }

  /// Removes an injection object by name.
  ///
  /// Automatically updates the injection scripts.
  ///
  /// Parameters:
  /// - [objectName]: Name of the JavaScript object to remove.
  void removeInjectJsObject({
    required String objectName,
  }) {
    injectObjects.remove(objectName);
    _updateInjectJs();
  }

  /// Removes all injection objects.
  ///
  /// Clears both the objects map and the generated injection scripts.
  void clearInjectJsObject() {
    injectObjects.clear();
    _updateInjectJs();
  }

  /// Removes all injection objects scheduled for page start injection.
  ///
  /// Only removes objects with [InjectionTime.pageStart].
  /// Automatically updates the injection scripts.
  void clearStartInjectJsObject() {
    injectObjects.removeWhere(
        (name, element) => element.injectionTime == InjectionTime.pageStart);
    _updateInjectJs();
  }

  /// Removes all injection objects scheduled for page end injection.
  ///
  /// Only removes objects with [InjectionTime.pageEnd].
  /// Automatically updates the injection scripts.
  void clearEndInjectJsObject() {
    injectObjects.removeWhere(
        (name, element) => element.injectionTime == InjectionTime.pageEnd);
    _updateInjectJs();
  }

  /// Regenerates the JavaScript injection code.
  ///
  /// This internal method processes all registered injection objects and
  /// generates the appropriate JavaScript code for both page start and
  /// page end injection phases. It should be called whenever the
  /// [injectObjects] map is modified.
  void _updateInjectJs() {
    var startList = injectObjects.entries
        .where((e) => e.value.injectionTime == InjectionTime.pageStart);
    var startInjectObjectJs = startList.map((e) {
      return InjectJsUtil.generateInjectJs(e.key, e.value);
    }).join("\n");
    _startInjectSource =
        InjectJsUtil.generatePageStartInjectJs(startInjectObjectJs);

    var endList = injectObjects.entries
        .where((e) => e.value.injectionTime == InjectionTime.pageEnd);
    var endInjectObjectJs = endList.map((e) {
      return InjectJsUtil.generateInjectJs(e.key, e.value);
    }).join("\n");
    _endInjectSource = InjectJsUtil.generatePageEndInjectJs(endInjectObjectJs);
  }
}
