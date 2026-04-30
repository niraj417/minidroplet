import 'package:flutter/material.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/services/payment_service.dart';

class PaypalWebViewPage extends StatefulWidget {
  final int id;
  final String type;
  final String amount;

  const PaypalWebViewPage({
    super.key,
    required this.id,
    required this.type,
    required this.amount,
  });

  @override
  State<PaypalWebViewPage> createState() => _PaypalWebViewPageState();
}

class _PaypalWebViewPageState extends State<PaypalWebViewPage> {
  String? paymentUrl;
  bool isLoading = true;
  WebViewController? controller;
  final DioClient _dioClient = DioClient();

  @override
  void initState() {
    super.initState();
    _fetchPaypal();
  }

  Future<void> _fetchPaypal() async {
    try {
      final response = await _dioClient.sendPostRequest(ApiEndpoints.paypal, {
        "id": widget.id,
        "type": widget.type,
        "amount": widget.amount,
      });

      debugPrint("API Response: ${response.data}");

      if (response.data['status'] == 1 &&
          response.data['data'] != null &&
          response.data['data'].toString().isNotEmpty) {

        String rawUrl = response.data['data'].toString();

        if (!rawUrl.startsWith("http")) {
          rawUrl = "https://$rawUrl";
        }

        paymentUrl = rawUrl;

        controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(paymentUrl!));
      } else {
        debugPrint("❌ Paypal URL empty from API");
      }
    } catch (e) {
      debugPrint("❌ Paypal Error: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paypal')),
      body: isLoading
          ? const Center(child: Loader())
          : paymentUrl != null && controller != null
          ? WebViewWidget(controller: controller!)
          : const Center(
        child: Text(
          "Failed to load PayPal payment link",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
