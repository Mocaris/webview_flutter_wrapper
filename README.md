# webview_flutter_wrapper


A powerful Flutter WebView wrapper plugin that provides convenient JavaScript injection and bidirectional communication capabilities.

### Key Features

- **Smart JS Injection**: Automatically inject JavaScript objects at two timing points - page load start (pageStart) and page load end (pageEnd)
- **Bidirectional Communication**: Seamless Native ↔ JavaScript calls with Promise async support
- **Lifecycle Events**: Provides `onPageStartScriptReady`, `onPageEndScriptReady` and other events for precise injection timing control
- **Promise Compatible**: Native JavaScript Promise support, `runJavaScriptReturningResult` can directly await async functions
- **Flexible Management**: Support dynamic add, remove, and clear injected objects to meet different scenario requirements

### Use Cases

Ideal for scenarios requiring embedded H5 pages in Flutter apps with complex interactions, such as hybrid development, H5 feature extension, and JS Bridge communication.

---

Concise version (for pub.dev description):

> A powerful Flutter WebView wrapper with intelligent JavaScript injection, bidirectional communication, and Promise support. Enables seamless Native-JS interaction with flexible injection timing control.




## How to use？

### Init WebviewWrapperController
```dart
final WebviewWrapperController controller = WebviewWrapperController();

    controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      controller.addInjectJsObjectList([
        /// call window event oninjectStartReady when inject complete
          InjectJsObject(
            name: "injectStart",
            injectionTime: InjectionTime.pageStart,
            injectJsScript:"console.log('injectStart');"
            functions: {
              "test": (data) {
                debugPrint("----------->>>injectStart.test: $data");
              }
          }),
        /// call window event oninjectEndReady when inject complete
          InjectJsObject(
            name: "injectEnd",
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