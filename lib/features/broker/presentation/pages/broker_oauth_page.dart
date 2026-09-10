import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Hosts the broker's authorization page in an in-app WebView.
///
/// The provider redirects to the backend callback (`/api/broker/{slug}/callback`)
/// which in turn 302-redirects to the app deep-link scheme
/// (`bankertrader://broker/connected?...`). We intercept that final navigation
/// (the scheme is not loadable in the WebView), parse the outcome and pop with
/// [OAuthOutcome].
class BrokerOAuthPage extends StatefulWidget {
  const BrokerOAuthPage({super.key, required this.authorizationUrl});

  final String authorizationUrl;

  @override
  State<BrokerOAuthPage> createState() => _BrokerOAuthPageState();
}

class _BrokerOAuthPageState extends State<BrokerOAuthPage> {
  late final WebViewController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: _onNavigationRequest,
        onWebResourceError: (error) {
          if (!mounted || _finished) {
            return;
          }
          final out = _classify(error.description);
          if (out != null) {
            _complete(out);
          }
        },
      ))
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final out = _classify(request.url);
    if (out != null && mounted && !_finished) {
      _complete(out);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  OAuthOutcome? _classify(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }
    final isCallback =
        uri.scheme == 'bankertrader' || url.contains('/api/broker/');
    if (!isCallback) {
      return null;
    }

    final params = uri.queryParameters;
    final success = params['success']?.toLowerCase() == 'true';
    final message = params['message'] ??
        (success ? 'Broker connected successfully.' : 'Broker connection failed.');
    final accountId = params['trading_account_id'];

    return OAuthOutcome(
      success: success,
      message: Uri.decodeComponent(message),
      tradingAccountId: accountId,
    );
  }

  void _complete(OAuthOutcome outcome) {
    _finished = true;
    Navigator.of(context).pop(outcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authorize broker')),
      body: WebViewWidget(controller: _controller),
    );
  }
}

class OAuthOutcome {
  const OAuthOutcome({
    required this.success,
    required this.message,
    this.tradingAccountId,
  });

  final bool success;
  final String message;
  final String? tradingAccountId;
}