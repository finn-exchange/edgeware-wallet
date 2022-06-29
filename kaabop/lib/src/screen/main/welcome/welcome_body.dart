import 'package:wallet_apps/index.dart';

class WelcomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        Container(
          padding: const EdgeInsets.only(
            left: 42,
            right: 16,
            bottom: 16,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: MyText(
                  text: AppText.welcome,
                  fontSize: 22,
                  color: AppColors.textColor,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                    text: AppText.appName,
                    fontSize: 38,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
        ),
        SvgPicture.asset(
          'assets/undraw_bear_market_ania.svg',
          height: MediaQuery.of(context).size.height * 0.18,
          width: MediaQuery.of(context).size.width * 0.2,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
        ),
        Column(
          children: [
            MyFlatButton(
              hasShadow: true,
              edgeMargin:
                  const EdgeInsets.only(left: 42, right: 42, bottom: 16),
              textButton: AppText.createAccTitle,
              action: () {
                print("Why");
                // Navigator.pushNamed(context, AppText.contentBackup);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ContentsBackup()));
              },
            ),
            MyFlatButton(
              hasShadow: true,
              edgeMargin:
                  const EdgeInsets.only(left: 42, right: 42, bottom: 16),
              textButton: AppText.importAccTitle,
              action: () {
                Navigator.pushNamed(context, AppText.importAccView);
              },
            ),
          ],
        ),
      ],
    );
  }
}
