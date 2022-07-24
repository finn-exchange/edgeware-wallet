// ignore: avoid_classes_with_only_static_members
class AppText {
  static String appName = "Dfinn Wallet";

  static String contentConnection = "Something wrong with your connection ";

  static String backupPassphrase = "Backup Passphrase";

  // welcome screen
  static String tocAndPp =
      "By continuing, you agree to our \nTerms and Conditions and Privacy Policy";

  //create account guide description
  static String backup = "Backup prom";
  static String offlineStorage = "Offline storage";
  static String getMnemonic =
      "Getting a passphrase equals ownership of the wallet asset.";
  static String keepMnemonic =
      "Use paper and pen to correctly copy passphrase.";
  static String mnemonicAdvise =
      "Keep it safe to a safe place on the isolated network.\n\nDo not share and store passphrase in a networked environment, such as emails, photo albums, social applications.";

  //generate mnenomnic screen note's text
  static String screenshotNote =
      "Note: Do not take screenshot, someone will have fully access to your assets, if they get your passphrase! Please write down your passphrase, then store it at a safe place.";

  //confirm mnenomic screen text
  static String confirmMnemonic = "Confirm the passphrase";
  static String clickMnemonic =
      "Please click on the passphrase in the correct order to confirm";

  static String claimAirdropNote =
      "Share Selendra's love to your friends by posting this airdrop on your social media profile Twitter, Linkedin, Facebook.";
  static String createAccTitle = "Create Account";
  static String importAccTitle = "Import Account ";

  static String reset = "Reset";
  static String welcome = "Welcome to";
  static String next = "Next";

  //for loading balance pattern
  static const String loadingPattern = '--.--';

  //swap screen description
  static const String swapNote = 'Swapping Note';
  static const String swapfirstNote =
      'This swap is only applied for SEL token holders, whom received SEL v1 during the Selendra\'s airdrop first session.';
  static const String swapSecondNote =
      '🚀 Swap rewards: this is part of the airdrop 2. For example, if you have 100 SEL v1, after swapped you will have 200 SEL v2 to keep and use in the future.';
  static const String swapThirdNote =
      '🚀 SEL v2 will be the utility token for Selendra with cross-chains capability. This meant that SEL v2 will be able to perform on both Selendra network as well as other network such as Polygon, Ethereum, BSC.';

  //route_name
  static const String splashScreenView = '/';
  static const String txActivityView = '/txactivity';
  static const String checkinView = '/checkin';
  static const String accountView = '/account';
  static const String contactBookView = '/contactbook';
  static const String passcodeView = '/passcode';
  static const String importAccView = '/import';
  static const String contentBackup = '/contentsbackup';
  static const String recieveWalletView = '/recieveWallet';
  static const String claimAirdropView = '/claimairdrop';
  static const String navigationDrawerView = '/navigationdrawer';
  static const String inviteFriendView = '/invitefriend';
  static const String setupAccView = '/importUserInfo';
}
