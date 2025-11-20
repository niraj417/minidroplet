import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constant/app_export.dart';
import '../internet_cubit.dart';
import '../internet_state.dart';
import 'no_internet_dialog.dart';
class InternetChecker {
  // Singleton instance
  static final InternetChecker _instance = InternetChecker._internal();
  factory InternetChecker() => _instance;
  InternetChecker._internal();

  bool _isShowingDialog = false;
  late GlobalKey<NavigatorState> _navigatorKey;

  // Initialize with your existing navigator key
  void initialize(GlobalKey<NavigatorState> navigatorKey, BuildContext context) {
    _navigatorKey = navigatorKey;

    // Listen to connectivity changes
    BlocProvider.of<InternetCubit>(context).stream.listen((state) {
      if (state is InternetDisconnected) {
        showNoInternetDialog(context);
      } else if (state is InternetConnected) {
        removeDialog();
      }
    });
  }

  void showNoInternetDialog(BuildContext context) {
    if (_isShowingDialog) return;

    // Get the current context from the navigator key
    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext == null) return;

    _isShowingDialog = true;

    showDialog(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return NoInternetDialog(
          onRetry: () {
            context.read<InternetCubit>().checkConnectivity();
          },
        );
      },
    ).then((_) {
      _isShowingDialog = false;
    });
  }

  void removeDialog() {
    if (_isShowingDialog && _navigatorKey.currentContext != null) {
      Navigator.of(_navigatorKey.currentContext!, rootNavigator: true).pop();
      _isShowingDialog = false;
    }
  }
}