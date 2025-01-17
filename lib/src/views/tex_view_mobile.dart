import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_tex/src/utils/core_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// #enddocregion platform_imports
class TeXViewState extends State<TeXView> with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;

  double _height = minHeight;
  String? _lastData;
  bool _pageLoaded = false;

  late final PlatformWebViewControllerCreationParams params;
  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..currentUrl()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (message) {
            _pageLoaded = true;
            _initTeXView();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel('TeXViewRenderedCallback',
          onMessageReceived: (jm) async {
        double height = double.parse(jm.message);
        if (_height != height) {
          setState(() {
            _height = height;
          });
        }
        widget.onRenderFinished?.call(height);
      })
      ..addJavaScriptChannel('OnTapCallback', onMessageReceived: (jm) {
        widget.child.onTapCallback(jm.message);
      });

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features
    controller.loadFlutterAsset(
        "packages/flutter_tex/js/${widget.renderingEngine?.name ?? 'katex'}/index.html");
    _controller = controller;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    updateKeepAlive();
    _initTeXView();
    return IndexedStack(
      index: widget.loadingWidgetBuilder?.call(context) != null
          ? _height == minHeight
              ? 1
              : 0
          : 0,
      children: <Widget>[
        SizedBox(
            height: _height, child: WebViewWidget(controller: _controller)),
        widget.loadingWidgetBuilder?.call(context) ?? const SizedBox.shrink()
      ],
    );
  }

  void _initTeXView() {
    if (_pageLoaded && getRawData(widget) != _lastData) {
      if (widget.loadingWidgetBuilder != null) _height = minHeight;
      _controller.runJavaScript("initView(${getRawData(widget)})");
      _lastData = getRawData(widget);
    }
  }
}
