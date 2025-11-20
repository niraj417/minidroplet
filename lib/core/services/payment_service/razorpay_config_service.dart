import 'package:get_it/get_it.dart';
import 'package:tinydroplets/core/network/api_controller.dart';
import 'package:tinydroplets/core/network/api_endpoints.dart';

class RazorpayConfigService {
  static final RazorpayConfigService _instance =
      RazorpayConfigService._internal();
  factory RazorpayConfigService() => _instance;
  RazorpayConfigService._internal();

  final DioClient _dioClient = GetIt.instance<DioClient>();

  // Global variables to store the keys
  static String? _razorpayPublicKey;
  static String? _razorpayPrivateKey;
  static bool _isInitialized = false;
  static bool _isLoading = false;

  // Getters for accessing keys globally
  static String? get publicKey => _razorpayPublicKey;
  static String? get privateKey => _razorpayPrivateKey;
  static bool get isInitialized => _isInitialized;
  static bool get isLoading => _isLoading;
  static bool get hasKeys =>
      _razorpayPublicKey != null && _razorpayPublicKey!.isNotEmpty;
  static bool get isLiveMode =>
      _razorpayPublicKey?.startsWith('rzp_live_') ?? false;
  static bool get isTestMode =>
      _razorpayPublicKey?.startsWith('rzp_test_') ?? false;

  /// Initialize keys - fetches only if not already loaded
  Future<void> initialize() async {
    if (_isInitialized && hasKeys) {
      print('✅ Razorpay keys already loaded in memory');
      _logCurrentKeys();
      return;
    }

    if (_isLoading) {
      print('⏳ Keys are already being fetched, waiting...');
      // Wait for the current loading to complete
      while (_isLoading) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      return;
    }

    print('🌐 Fetching Razorpay keys from API...');
    await _fetchRazorpayKeys();
    _logCurrentKeys();
  }

  /// Force refresh - clears memory and fetches fresh keys
  Future<void> forceRefresh() async {
    print('🔄 Force refreshing Razorpay keys...');
    _clearKeys();
    await _fetchRazorpayKeys();
    _logCurrentKeys();
  }

  /// Fetch keys from API
  Future<void> _fetchRazorpayKeys() async {
    _isLoading = true;

    try {
      final response = await _dioClient.sendGetRequest(ApiEndpoints.razorPay);

      if (response.data['status'] == 1) {
        final List<dynamic> data = response.data['data'];
        print('RAZOR API KEYS FETCHED');
        final publicKeyItem = data.firstWhere(
          (item) => item['key'] == 'razorpay_public_key',
          orElse: () => null,
        );

        final privateKeyItem = data.firstWhere(
          (item) => item['key'] == 'razorpay_private_key',
          orElse: () => null,
        );

        if (publicKeyItem != null && privateKeyItem != null) {
          final newPublicKey = publicKeyItem['value']?.toString();
          final newPrivateKey = privateKeyItem['value']?.toString();

          if (newPublicKey != null && newPublicKey.isNotEmpty) {
            _razorpayPublicKey = newPublicKey;
            _razorpayPrivateKey = newPrivateKey;
            _isInitialized = true;
            print('✅ Keys fetched successfully from API');
            print('📊 API Response - Public Key: $newPublicKey');
            print(
              '📊 API Response - Private Key: ${newPrivateKey?.substring(0, 10)}...',
            );
          } else {
            print('⚠️ API returned empty keys');
            throw Exception('API returned empty keys');
          }
        } else {
          print('⚠️ Keys not found in API response');
          print('📊 Full API Response: ${response.data}');
          throw Exception('Keys not found in API response');
        }
      } else {
        print('❌ API error: ${response.data['message']}');
        throw Exception('API error: ${response.data['message']}');
      }
    } catch (e) {
      print('❌ Failed to fetch Razorpay keys: $e');
      _clearKeys(); // Clear any partial data
      rethrow; // Re-throw so calling code can handle the error
    } finally {
      _isLoading = false;
    }
  }

  /// Clear all keys from memory
  void _clearKeys() {
    _razorpayPublicKey = null;
    _razorpayPrivateKey = null;
    _isInitialized = false;
  }

  /// Log current key status
  void _logCurrentKeys() {
    print("=== RAZORPAY CONFIG STATUS ===");
    print("Public Key: $_razorpayPublicKey");
    print("Is Test Key: ${isTestMode}");
    print("Is Live Key: ${isLiveMode}");
    print("Source: API Response");
    print("Is Initialized: $_isInitialized");
    print("==============================");
  }

  /// Validate if keys are ready for payment
  static bool validateKeys() {
    if (!hasKeys) {
      print('❌ Razorpay keys not available. Please initialize first.');
      return false;
    }

    if (!_isInitialized) {
      print(
        '❌ Razorpay config not initialized. Please call initialize() first.',
      );
      return false;
    }

    return true;
  }

  /// Get initialization status with details
  static Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'isLoading': _isLoading,
      'hasKeys': hasKeys,
      'isLiveMode': isLiveMode,
      'isTestMode': isTestMode,
      'publicKey': _razorpayPublicKey,
      'keySource': 'API Response',
    };
  }
}
