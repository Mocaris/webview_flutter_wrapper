import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

///
/// @Author mocaris
/// @Date 2026-02-05
/// @Since
class NavigationDelegateWrapper extends NavigationDelegate {
  NavigationDelegateWrapper({
    FutureOr<NavigationDecision> Function(NavigationRequest request)?
        onNavigationRequest,
    void Function(String url)? onPageStarted,
    void Function(String url)? onPageFinished,
    void Function(int progress)? onProgress,
    void Function(WebResourceError error)? onWebResourceError,
    void Function(UrlChange change)? onUrlChange,
    void Function(HttpAuthRequest request)? onHttpAuthRequest,
    void Function(HttpResponseError error)? onHttpError,
    // since 4.13.0
    void Function(SslAuthError request)? onSslAuthError,
  }) : this.fromPlatformCreationParams(
          const PlatformNavigationDelegateCreationParams(),
          onNavigationRequest: onNavigationRequest,
          onPageStarted: onPageStarted,
          onPageFinished: onPageFinished,
          onProgress: onProgress,
          onWebResourceError: onWebResourceError,
          onUrlChange: onUrlChange,
          onHttpAuthRequest: onHttpAuthRequest,
          onHttpError: onHttpError,
          onSslAuthError: onSslAuthError,
        );

  NavigationDelegateWrapper.fromPlatformCreationParams(
    PlatformNavigationDelegateCreationParams params, {
    FutureOr<NavigationDecision> Function(NavigationRequest request)?
        onNavigationRequest,
    void Function(String url)? onPageStarted,
    void Function(String url)? onPageFinished,
    void Function(int progress)? onProgress,
    void Function(WebResourceError error)? onWebResourceError,
    void Function(UrlChange change)? onUrlChange,
    void Function(HttpAuthRequest request)? onHttpAuthRequest,
    void Function(HttpResponseError error)? onHttpError,
    void Function(SslAuthError request)? onSslAuthError,
  }) : this.fromPlatform(
          PlatformNavigationDelegate(params),
          onNavigationRequest: onNavigationRequest,
          onPageStarted: onPageStarted,
          onPageFinished: onPageFinished,
          onProgress: onProgress,
          onWebResourceError: onWebResourceError,
          onUrlChange: onUrlChange,
          onHttpAuthRequest: onHttpAuthRequest,
          onHttpError: onHttpError,
          onSslAuthError: onSslAuthError,
        );
  final void Function(UrlChange change)? onUrlChange;
  final HttpAuthRequestCallback? onHttpAuthRequest;
  final void Function(HttpResponseError error)? onHttpError;
  final void Function(SslAuthError request)? onSslAuthError;

  NavigationDelegateWrapper.fromPlatform(
    super.platform, {
    super.onNavigationRequest,
    super.onPageStarted,
    super.onPageFinished,
    super.onProgress,
    super.onWebResourceError,
    this.onUrlChange,
    this.onHttpAuthRequest,
    this.onHttpError,
    this.onSslAuthError,
  }) : super.fromPlatform(
          onUrlChange: onUrlChange,
          onHttpAuthRequest: onHttpAuthRequest,
          onHttpError: onHttpError,
          onSslAuthError: onSslAuthError,
        );
}
