import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/splash_page.dart';
import 'stores/login_store.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controller/requirement_state_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // new for Firebase Auth
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Get.put(RequirementStateController());

    final themeData = Theme.of(context);
    final primary = Colors.blue;
    final textTheme = Theme.of(context).textTheme;

    return MultiProvider(
        providers: [
          Provider<LoginStore>(
            create: (_) => LoginStore(),
          )
        ],
        child: GetMaterialApp(
          theme: ThemeData(
            textTheme: GoogleFonts.robotoTextTheme(textTheme).copyWith(
            ),
            primarySwatch: primary,
            appBarTheme: themeData.appBarTheme.copyWith(
              elevation: 0.0,
              color: Colors.white,
              actionsIconTheme: themeData.primaryIconTheme.copyWith(
                color: primary,
              ),
              iconTheme: themeData.primaryIconTheme.copyWith(
                color: primary,
              ),
              // textTheme: themeData.primaryTextTheme.copyWith(
              //   headline6: themeData.textTheme.headline6.copyWith(
              //     color: primary,
              //   ),
              // ),
            ),
          ),
          home: SplashPage(),
        ),
    );
  }
}