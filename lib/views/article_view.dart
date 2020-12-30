import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


/// The view for viewing an Articles web page.
///
/// A blank white bar with a WebView underneath that fills the whole page.
class ArticleView extends StatefulWidget {

    final String url;

    ArticleView(this.url);

    @override
    _ArticleViewState createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
    Completer<WebViewController> completer = Completer<WebViewController>();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[Text("")]
                ),
                centerTitle: true,
                elevation: 0.0,
            ),
            body: Container(
                child: WebView(
                    initialUrl: widget.url,
                    onWebViewCreated: (
                        (WebViewController wvc) {
                            completer.complete(wvc);
                        }
                    ),
                )
            ),
        );
    }
}