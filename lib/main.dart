import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/pages/HomePage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/pages/RecordingPage.dart';
import 'package:myapp/src/pages/SettingsPage.dart';
import 'package:myapp/src/providers/SettingsProvider.dart';
import 'package:myapp/src/utilities/ScaleTypes.dart';

void main() {
  initScalePatternGroups();
  print("${kScaleGroups[0].length} ${kScaleGroups[0][0]}");
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure that the system UI is set to light mode by default
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  // Set the preferred orientations to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(path: '/recording_page', builder: (context, state) => const RecordingPage()),
      // GoRoute(
      //   path: '/scale_selection',
      //   builder: (context, state) => const HomePage(),
      // ),
    ],
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(settingsProvider);
        final Brightness platformBrightness =
            MediaQuery.of(context).platformBrightness;
        final bool isDarkMode;
        if (settings.themeMode == (ThemeModeSetting.system)) {
          isDarkMode = platformBrightness == Brightness.dark;
        } else if (settings.themeMode == (ThemeModeSetting.dark)) {
          isDarkMode = true;
        } else {
          isDarkMode = false;
        }
        if (kDebugMode) {
          print("Dark Mode?: $isDarkMode");
        }

        return CupertinoApp.router(
          routerConfig: _router,
          theme: CupertinoThemeData(
            primaryColor:
                isDarkMode
                    ? CupertinoColors.systemBlue.darkColor
                    : CupertinoColors.systemBlue,
            primaryContrastingColor:
                isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            scaffoldBackgroundColor:
                isDarkMode
                    ? CupertinoColors.darkBackgroundGray
                    : CupertinoColors.systemGrey6,
            barBackgroundColor:
                isDarkMode
                    ? CupertinoColors.black
                    : CupertinoColors.systemGrey6.withOpacity(0.9),
            textTheme: CupertinoTextThemeData(
              primaryColor:
                  isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              navActionTextStyle: TextStyle(
                color:
                    isDarkMode
                        ? CupertinoColors.systemBlue.darkColor
                        : CupertinoColors.systemBlue,
              ),
              navLargeTitleTextStyle: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
          ),
        );
      },
    );
  }
}
