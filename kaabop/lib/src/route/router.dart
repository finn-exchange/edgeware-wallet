import 'package:wallet_apps/index.dart';
import 'package:wallet_apps/src/screen/home/contact_book/contact_book.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case AppText.splashScreenView:
      return RouteAnimation(enterPage: MySplashScreen());
      break;
    case AppText.accountView:
      return RouteAnimation(enterPage: Account());
      break;
    case AppText.contactBookView:
      return RouteAnimation(enterPage: ContactBook());
      break;
    case AppText.txActivityView:
      return RouteAnimation(enterPage: TrxActivity());
      break;
    case AppText.importAccView:
      return RouteAnimation(enterPage: const ImportAcc());
      break;
    case AppText.contentBackup:
      return RouteAnimation(enterPage: ContentsBackup());
      break;
    case AppText.passcodeView:
      return RouteAnimation(enterPage: const Passcode());
      break;
    case AppText.checkinView:
      return RouteAnimation(enterPage: const CheckIn());
      break;
    case AppText.recieveWalletView:
      return RouteAnimation(enterPage: ReceiveWallet());
      break;
    case AppText.claimAirdropView:
      return RouteAnimation(enterPage: ClaimAirDrop());
      break;
    case AppText.navigationDrawerView:
      return RouteAnimation(enterPage: NavigationDrawer());
      break;
    case AppText.inviteFriendView:
      return RouteAnimation(enterPage: InviteFriend());
      break;
    default:
      return RouteAnimation(enterPage: MySplashScreen());
  }
}
