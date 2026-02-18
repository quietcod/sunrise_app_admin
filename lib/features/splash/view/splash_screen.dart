import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/util.dart';
import 'package:flutex_admin/common/controllers/localization_controller.dart';
import 'package:flutex_admin/common/controllers/theme_controller.dart';
import 'package:flutex_admin/features/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    ThemeController themeController =
        ThemeController(sharedPreferences: Get.find());
    MyUtils.splashScreenUtils(themeController.darkTheme);
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    final controller = Get.put(SplashController(
        apiClient: Get.find(), localizationController: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.gotoNextPage();
    });
  }

  @override
  void dispose() {
    ThemeController themeController =
        ThemeController(sharedPreferences: Get.find());
    MyUtils.allScreensUtils(themeController.darkTheme);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<SplashController>(
        builder: (controller) => Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SUNRISE',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Adjust as needed
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ADMIN-STAFF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // Adjust as needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
