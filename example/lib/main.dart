import 'package:flutter/material.dart';
import 'package:webview_flutter_wrapper/webview_flutter_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final WebviewWrapperController controller = WebviewWrapperController();

  @override
  void initState() {
    super.initState();
    controller.assignAllInjectJsObject({
      "InjectStart": InjectJsObject(
          injectionTime: InjectionTime.pageStart,
          onInjectedReady: () {
            print("----------->>>InjectStart ready");
          },
          functions: {
            "test": (data) {
              debugPrint(
                  "----------->>>injectStart.test: $data, ${data.runtimeType}");
            },
            "test1": (data) {
              debugPrint("----------->>>injectStart.test: $data");
            }
          }),
      "InjectEnd": InjectJsObject(
          injectionTime: InjectionTime.pageEnd,
          onInjectedReady: () {
            print("----------->>>InjectEnd ready");
          },
          functions: {
            "test": (data) {
              debugPrint("----------->>>injectEnd.test: $data");
            }
          }),
    });
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
                      } catch (e, s) {
                        debugPrint(
                            "testPromiseError----->>>error $e, stack: $s");
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
                      } catch (e, s) {
                        debugPrint("testError----->>>error $e, stack: $s");
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
