import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webviwe_flutter_wrapper/webviwe_flutter_wrapper.dart';

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
