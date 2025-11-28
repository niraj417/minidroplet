import 'package:tinydroplets/services/in_app_purchases.dart';

/// Get product ID based on item type
///
class IAPUtils {
  static String? getIAPProductId(String itemType) {
    switch (itemType) {
      case 'ebook':
        return IAPurchaseService.ebookProductId;
      case 'video':
        return IAPurchaseService.videoProductId;
      case 'playlist':
        return IAPurchaseService.playlistProductId;
      case 'subscription':
        return IAPurchaseService.subscriptionProductId;
      default:
        return null;
    }
  }
}
