/* This file hold app configurations. */
class AppConfig {
  bool isDark;
  /* Background Color */
  static const String darkBlue50 = "#344051",
      bgdColor = "#090D28"; // App Theme using darkBlue75

  static const String lightBgdColor = '#F5F5F5';
  /* ------------------- Logo -----------------  */

  // Welcome Screen, Login Screen, Sign Up Screen
  static String logoName = "assets/sld_logo.svg";

  // Dashbaord Menu
  static String logoAppBar = "assets/images/zeetomic-logo-header.png";

  // Bottom App Bar
  static String logoBottomAppBar = "assets/images/sld_qr.png";

  // QR Embedded
  static String logoQrEmbedded =
      "assets/SelendraQr-1.png"; //"assets/sld_stroke.png";

  // Portfolio
  static String logoPortfolio = 'assets/images/sld_logo.png';

  // Transaction History
  static String logoTrxHistory = 'assets/images/sld_logo.png';

  /* Splash Screen */
  static String splashLogo = "assets/images/zeetomic-logo-header.png";

  /* Transaction Acivtiy */
  static String logoTrxActivity = 'assets/images/sld_logo.png';

  /* Zeetomic api user data*/
  // Main Net API
  static const url = "https://testnet-api.selendra.com/pub/v1";

  static const bscTestNet = 'https://data-seed-prebsc-1-s1.binance.org:8545';

  static const bscMainNet = 'https://bsc-dataseed.binance.org/';

  //static const bscAddr = '0xd84d89d5c9df06755b5d591794241d3fd20669ce';

  static const bscMainnetAddr = '0x288d3A87a87C284Ed685E0490E5C4cC0883a060a';

  static const kmpiAddr = '5GZ9uD6RgN84bpBuic1HWq9AP7k2SSFtK9jCVkrncZsuARQU';

  //test 0x78F51cc2e297dfaC4c0D5fb3552d413DC3F71314

  static const nodeName = 'Indranet hosted By Selendra';

  static const nodeEndpoint = 'wss://rpc-testnet.selendra.org';

  static const dotTestnet = 'wss://westend-rpc.polkadot.io';

  static const dotMainnet = 'wss://rpc.polkadot.io';

  static int ss58 = 42;

  static const spreedSheetId = '1hFKqaUe1q_6A-b-_ZnEAC574d51fCi1bTWQKCluHF2E';


  static const credentials = ' ';

  

  // 
  // sld_market net API
  // https://sld_marketnet-api.selendra.com/pub/v1
}
