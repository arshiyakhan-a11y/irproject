import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ColorHuntWebView extends StatefulWidget {
  const ColorHuntWebView({Key? key}) : super(key: key);

  @override
  State<ColorHuntWebView> createState() => _ColorHuntWebViewState();
}

class _ColorHuntWebViewState extends State<ColorHuntWebView> {
  double _progress = 0;
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Color Hunt', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _webViewController.canGoBack()) {
                _webViewController.goBack();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(Uri.parse("https://colorhunt.co/")),
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useOnDownloadStart: true,
                  cacheEnabled: true,
                  supportZoom: true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
                android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                ),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onLoadError: (controller, url, code, message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load page: $message')),
                );
              },
              onLoadHttpError: (controller, url, statusCode, description) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('HTTP Error $statusCode: $description')),
                );
              },
            ),
            if (_progress < 1)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.teal.shade100,
                color: Colors.teal,
              ),
          ],
        ),
      ),
    );
  }
}
