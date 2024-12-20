  import 'package:f_expence_manager/page/income_category_page.dart';
  import 'package:f_expence_manager/page/my_home_page.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';

  class SplashPage extends StatefulWidget {
    const SplashPage({super.key});

    @override
    State<SplashPage> createState() => _SplashPageState();
  }

  class _SplashPageState extends State<SplashPage>
      with SingleTickerProviderStateMixin {
    @override
    void initState() {
      super.initState();

      // For removing top and bottom appbars.
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // For automatically navigating to MyHomePage after 3.5 seconds.
      Future.delayed(
        const Duration(milliseconds: 3500),
        () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MyHomePage(),
            ),
          );
        },
      );
    }

    // For applying top and bottom app bars after this screen is finished.
    @override
    void dispose() {
      super.dispose();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }

    @override
    Widget build(BuildContext context) {
      return Image.asset(
        "asset/image/spalsh_expense.png",
        fit: BoxFit.fill,
      );
    }
  }
