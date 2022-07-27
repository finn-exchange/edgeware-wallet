import 'package:provider/provider.dart';
import 'package:wallet_apps/index.dart';

class FingerPrint extends StatefulWidget {
  @override
  _FingerPrintState createState() => _FingerPrintState();
}

class _FingerPrintState extends State<FingerPrint> {
  final localAuth = LocalAuthentication();

  bool enableText = false;

  String authorNot = 'Not Authenticate';

  GlobalKey<ScaffoldState> globalkey;

  @override
  void initState() {
    globalkey = GlobalKey<ScaffoldState>();
    authenticate();
    super.initState();
  }

  Future<void> authenticate() async {
    bool authenticate = false;

    try {
      authenticate = await localAuth.authenticate(
          localizedReason: 'Please complete the biometrics to proceed.',
          stickyAuth: true);
      if (authenticate) {
        Navigator.pushReplacementNamed(context, Home.route);
      }
    } on SocketException catch (e) {
      await Future.delayed(const Duration(milliseconds: 300), () {});
      AppServices.openSnackBar(globalkey, e.message);
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: const Align(
              child: Text('Message'),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: MyText(text: e.message.toString()),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      //await dialog(e.message.toString(), "Message");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<ThemeProvider>(context).isDark;
    return Scaffold(
      key: globalkey,
      body: GestureDetector(
        onTap: () {
          setState(() {
            enableText = false;
          });
          authenticate();
        },
        child: BodyScaffold(
          isSafeArea: true,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MyText(
                text: 'Dfinn Locked',
                fontSize: 27.0,
                fontWeight: FontWeight.bold,
                color: isDarkTheme
                    ? AppColors.whiteColorHexa
                    : AppColors.textColor,
              ),
              const SizedBox(
                height: 40.0,
              ),
              SvgPicture.asset("assets/undraw_secure.svg",
                  width: 200, height: 200),
              const SizedBox(
                height: 40.0,
              ),
              MyText(
                top: 19.0,
                text: 'Authentication Required',
                color: isDarkTheme
                    ? AppColors.whiteColorHexa
                    : AppColors.textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
