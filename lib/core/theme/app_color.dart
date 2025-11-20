import 'package:tinydroplets/core/constant/app_export.dart';

class AppColor {
  static int primaryColor = 0xFFffA314;



  static MaterialColor primarySwatch = MaterialColor(
    primaryColor,
    <int, Color>{
      50: Color(0x1AF2704F),  // 10% opacity
      100: Color(0x33F2704F), // 20% opacity
      200: Color(0x4DF2704F), // 30% opacity
      300: Color(0x66F2704F), // 40% opacity
      400: Color(0x99F2704F), // 60% opacity
      500: Color(primaryColor), // 100% opacity (default color)
      600: Color(0xB3F2704F), // 70% opacity
      700: Color(0xCCF2704F), // 80% opacity
      800: Color(0xE6F2704F), // 90% opacity
      900: Color(0xfff2704f),  // Original color
    },
  );

  static const backgroundColor = Color(0xffFFFFFF);
  static const secondaryColor = Color(0xff93ACFF);
  static const textColor = Colors.black;
  static const yellow = Colors.yellow;
  static Color? grey = Colors.grey[850];
  static const greyColor = Colors.grey;

  static const Color transparentColor = Colors.transparent;
  static const Color inactiveSeekColor = Colors.white38;
  static const Color whiteColor = Colors.white;

  // Method to update primary color dynamically
  static void updatePrimaryColor(String hexCode) {
    primaryColor = int.parse(hexCode, radix: 16) | 0xFF000000;
    primarySwatch = MaterialColor(
      primaryColor,
      <int, Color>{
        50: Color(0x1AF2704F),
        100: Color(0x33F2704F),
        200: Color(0x4DF2704F),
        300: Color(0x66F2704F),
        400: Color(0x99F2704F),
        500: Color(primaryColor),
        600: Color(0xB3F2704F),
        700: Color(0xCCF2704F),
        800: Color(0xE6F2704F),
        900: Color(0xfff2704f),
      },
    );
  }


  static Future<void> fetchAndSetPrimaryColor() async {

    try {
      var response = await DioClient().sendGetRequest(ApiEndpoints.color);
      if (response.statusCode == 200) {
        final data = response.data;
        CommonMethods.devLog(logName: "Fetch color", message: data);
        if (data['status'] == 1 && data['data'] != null) {
          String hexCode = data['data']['color_code'];
          primaryColor = int.parse(hexCode.replaceAll('#', '0xFF'));
        }
      }
    } catch (e) {
      debugPrint("Error fetching color: $e");
    }
  }
}
