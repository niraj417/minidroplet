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
  late WebViewController controller;
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

      if (response.data['status'] == 1) {
        paymentUrl = response.data['data'];
        controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(paymentUrl!));


        setState(() {
          isLoading = false;
        });
      } else {
        debugPrint('Something went wrong');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paypal'),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Loader(),
                  SizedBox(height: 10),
                  Text(
                    'Loading PayPal...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : paymentUrl != null
              ? WebViewWidget(controller: controller)
              : const Center(child: Text('Failed to load PayPal page')),
    );
  }
}
