import 'package:flutter/material.dart';

import 'features/presentation/pages/dashboard/dashboard.dart';
import 'main.dart';

class AppRestartWidget extends StatefulWidget {
  final Widget child;
  const AppRestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    final state =
    context.findAncestorStateOfType<_AppRestartWidgetState>();

    if (state == null) return;

    state.restartApp();

    // 🚨 CLEAR ROUTES AND GO TO DASHBOARD
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Dashboard()),
          (route) => false,
    );
  }


  @override
  State<AppRestartWidget> createState() => _AppRestartWidgetState();
}

class _AppRestartWidgetState extends State<AppRestartWidget> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
