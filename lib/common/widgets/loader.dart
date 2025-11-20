import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constant/app_export.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    //return const Center(child: CircularProgressIndicator.adaptive());
    return Center(
      child: SizedBox(
        height: 35,
        width: 35,
        child: FittedBox(
          fit: BoxFit.contain,
          child:  SpinKitThreeInOut(
            color: Color(AppColor.primaryColor),
          ),
        ),
      ),
    );
  }
}
