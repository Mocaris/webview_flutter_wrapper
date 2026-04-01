# webviwe_flutter_wrapper

webview wrapper

### Init WebviewWrapperController
```dart
final WebviewWrapperController controller = WebviewWrapperController();

    controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      controller.addInjectJsObject([
        /// call window event oninjectStartReady when inject complete
          InjectJsObject(
            object: "injectStart",
            injectionTime: InjectionTime.pageStart,
            injectJsScript:"console.log('injectStart');"
            functions: {
              "test": (data) {
                debugPrint("----------->>>injectStart.test: $data");
              }
          }),
        /// call window event oninjectEndReady when inject complete
          InjectJsObject(
            object: "injectEnd",
            injectionTime: InjectionTime.pageEnd,
            injectJsScript:"console.log('injectEnd');"
            functions: {
            "test": (data) {
              debugPrint("----------->>>injectEnd.test: $data");
            }
          }),
      ]);
/// add webviewwrapper to page
/// you can add a list of InjectJsObject to inject js object to webview
    WebviewWrapperWidget(
        controller: controller,
        debuggingEnabled: true,
    )
```
#### add js window event listener 
```javascript
// when injectStart object script loaded complete
window.addEventListener('oninjectStartReady', function () {
    alert('oninjectStartReady')
});


// when injectEnd object script loaded complete
window.addEventListener('oninjectEndReady', function () {
    alert('oninjectEndReady')
});



// when page load start all script loaded complete
 window.addEventListener('onPageStartScriptReady', function () {
     alert('onPageStartScriptReady')
 });

// when page load end all script loaded complete
 window.addEventListener('onPageEndScriptReady', function () {
     alert('onPageEndScriptReady')
 });
```

#### js call native
````javascript
function testJsCall(){
    injectClass.test("test");
}

/// native call js function
/// example:
/// final result= await controller.runJavaScriptReturningResult('testPromiseOk()');
/// result is 'ok'
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
                  child: WebviewWrapperWidget(
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

js example:
```javascript
  window.addEventListener('onPageStartScriptReady', function () {
            console.log('onPageStartScriptReady')
        });
        window.addEventListener('onPageEndScriptReady', function () {
            console.log('onPageEndScriptReady')
        });
        window.addEventListener('oninjectStartReady', function () {
            console.log('oninjectStartReady')
        });
        window.addEventListener('oninjectEndReady', function () {
            console.log('oninjectEndReady')
        });
        function testPromiseOk() {
            return new Promise((resolve, reject) => {
                setTimeout(() => {
                    resolve('promise 成功')
                }, 1000)
            })
        }
        function testPromiseError() {
            return new Promise((resolve, reject) => {
                setTimeout(() => {
                    reject('promise 失败')
                }, 1000)
            })
        }
        function testNormal() {
            return "这是一个普通函数";
        }

        function testError() {
            throw new Error('这是一个错误')
        }

        function testInjectClassFunction() {
            injectStart.test();
        }

        function testInjectEndClassFunction() {
            injectEnd.test();
        }
```