import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:html/dom.dart' as dom;
import 'package:flutter_html/style.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/navigation_delegate.dart' as html_navigation;
import 'package:flutter_html/src/replaced_element.dart';

class IframeContentElement extends ReplacedElement {
  final String? src;
  final double? width;
  final double? height;
  final html_navigation.NavigationDelegate? navigationDelegate;
  final UniqueKey key = UniqueKey();

  IframeContentElement({
    required String name,
    required this.src,
    required this.width,
    required this.height,
    required dom.Element node,
    required this.navigationDelegate,
  }) : super(name: name, style: Style(), node: node, elementId: node.id);

  @override
  Widget toWidget(RenderContext context) {
    final sandboxMode = attributes["sandbox"];
    return Container(
      width: width ?? (height ?? 150) * 2,
      height: height ?? (width ?? 300) / 2,
      child: webview.WebView(
        initialUrl: src,
        javascriptMode: sandboxMode == null || sandboxMode == "allow-scripts"
            ? webview.JavascriptMode.unrestricted
            : webview.JavascriptMode.disabled,
        navigationDelegate: (webview.NavigationRequest request) async {
          if (navigationDelegate != null) {
            final result = await navigationDelegate!(html_navigation.NavigationRequest(
              url: request.url,
              isForMainFrame: request.isForMainFrame,
            ));
            if (result == html_navigation.NavigationDecision.prevent) {
              return webview.NavigationDecision.prevent;
            } else {
              return webview.NavigationDecision.navigate;
            }
          }
          return webview.NavigationDecision.navigate;
        },
      ),
    );
  }
}
