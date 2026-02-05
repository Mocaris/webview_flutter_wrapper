# webviwe_flutter_wrapper

webview wrapper

### Init WebviewWrapper
```dart

final WebviewWrapperController controller = WebviewWrapperController();

    controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      controller.addInjectJsObject([
          InjectJsObject(
            object: "injectStart",
            injectionTime: InjectionTime.pageStart,
            functions: {
              "test": (data) {
                debugPrint("----------->>>injectStart.test: $data");
              }
          }),
          InjectJsObject(
            object: "injectEnd",
            injectionTime: InjectionTime.pageEnd,
            functions: {
            "test": (data) {
              debugPrint("----------->>>injectEnd.test: $data");
            }
          }),
      ]);
/// add webviewwrapper to page
/// you can add a list of InjectJsObject to inject js object to webview
    WebviewWrapper(
        controller: controller,
        debuggingEnabled: true,
    )
```
#### add js window event listener 
```javascript
// when page start script loaded complete
 window.addEventListener('onPageStartScriptReady', function () {
     alert('onPageStartScriptReady')
 });

// when page end script loaded complete
 window.addEventListener('onPageEndScriptReady', function () {
     alert('onPageEndScriptReady')
 });
```

#### js call native
````javascript
function testJsCall(){
    injectClass.test("test");
}
function testPromiseOk(){
    return new Promise(function(resolve, reject) {
        resolve("ok");
    })
}

````
#### navtive call js 
```dart
/// call testPromiseOk function 
/// js function return a promise, so you can use await to wait for the result 
 final result = await controller.runJavaScriptReturningResult("testPromiseOk()");

```

#### example:
````dart
class _MyAppState extends State<MyApp> {
  final WebviewWrapperController controller = WebviewWrapperController();

  @override
  void initState() {
    super.initState();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadFlutterAsset("assets/test.html");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: WebviewWrapper(
                controller: controller,
                debuggingEnabled: true,
                injectObjects: [
                  InjectJsObject(
                      object: "injectClass",
                      injectionTime: InjectionTime.pageStart,
                      functions: {
                        "test": (data) {
                          debugPrint("----------->>> $data");
                        }
                      }),
                ],
              )),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await controller
                          .runJavaScriptReturningResult("testNormal()");
                      debugPrint("testNormal----->>>$result");
                    },
                    child: const Text("testNormal"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await controller
                          .runJavaScriptReturningResult("testPromiseOk()");
                      debugPrint("testPromiseOk----->>>$result");
                    },
                    child: const Text("testPromiseOk"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final result = await controller
                            .runJavaScriptReturningResult("testPromiseError()");
                        debugPrint("testPromiseError----->>>$result");
                      } catch (e) {
                        debugPrint("testPromiseError----->>>error $e");
                      }
                    },
                    child: const Text("testPromiseError"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final result = await controller
                            .runJavaScriptReturningResult("testError()");
                        debugPrint("testError----->>>$result");
                      } catch (e) {
                        debugPrint("testError----->>>error $e");
                      }
                    },
                    child: const Text("testError"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}



````