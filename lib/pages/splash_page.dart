import 'package:contact_tracing/stores/login_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'home.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    // Provider.of<LoginStore>(context, listen: false).isAlreadyAuthenticated().then((result) {
    //   if (result) {
    //     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomePage()), (Route<dynamic> route) => false);
    //   } else {
    //     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (Route<dynamic> route) => false);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    // return const Scaffold(
    //   backgroundColor: MyColors.primaryColor,
    // );
    final user = Provider.of<LoginStore>(context);

    // return either the Home or Authenticate widget
    if (user.getUser() == null){
      return LoginPage();
    } else {
      return Home();
    }
  }
}
