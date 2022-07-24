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
  static String logoQrEmbedded = "assets/SelendraQr-1.png"; //"assets/sld_stroke.png";

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
  static const url = "https://bangalore.dfinn.live";

  //static const bscTestNet = 'https://bangalore.dfinn.live';

  static const bscMainNet = 'https://bangalore.dfinn.live';

  //static const bscAddr = '0xd84d89d5c9df06755b5d591794241d3fd20669ce';

  static const etherTestnet = 'https://rinkeby.infura.io/v3/93a7248515ca45d0ba4bbbb8c33f1bda';

  static const etherMainet = 'https://mainnet.infura.io/v3/93a7248515ca45d0ba4bbbb8c33f1bda';

  static const etherTestnetWebSocket = 'wss://rinkeby.infura.io/ws/v3/93a7248515ca45d0ba4bbbb8c33f1bda';

  static const coingeckoBaseUrl = 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=';

  static const selV1MainnetAddr = '0x288d3A87a87C284Ed685E0490E5C4cC0883a060a';

  static const selv2MainnetAddr = '0x30bAb6B88dB781129c6a4e9B7926738e3314Cf1C';

  static const swapMainnetAddr = '0xa857d61c5802C4e299a5B972DE1ACCaD085cE765';

  static const kgoAddr = '0x5d3AfBA1924aD748776E4Ca62213BF7acf39d773';

  static const kmpiAddr = '5GZ9uD6RgN84bpBuic1HWq9AP7k2SSFtK9jCVkrncZsuARQU';

  //test 0x78F51cc2e297dfaC4c0D5fb3552d413DC3F71314

  // static const oSEL = '0xa7f2421fa3d3f31dbf34af7580a1e3d56bcd3030';

  //static const swapTestContract = '0xE5DD12570452057fc85B8cE9820aD676390f865B';

  //static const testSEL = '0x46bF747DeAC87b5db70096d9e88debd72D4C7f3C';

  static const nodeName = 'Kabocha Node';

  static const nodeEndpoint = 'wss://kabocha.jelliedowl.com';

  static const dotTestnet = 'wss://bangalore.dfinn.live';

  static const dotMainnet = 'wss://bangalore.dfinn.live';

  static int ss58 = 77;

  static const spreedSheetId = '1hFKqaUe1q_6A-b-_ZnEAC574d51fCi1bTWQKCluHF2E';

  static const nodeListPolkadot = [
    {
      'name': 'Polkadot (Live, hosted by Dfinn.live)',
      'ss58': 77,
      'endpoint': 'wss://bangalore.dfinn.live',
    },
  ];

  static const testInviteLink =
      'https://selendra-airdrop.netlify.app/invitation?ref=';

  static const testInviteLink1 =
      'https://selendra-airdrop.netlify.app/claim-\$sel?ref=';

  static const baseInviteLink = 'https://airdrop.selendra.org/claim-\$sel?ref=';

  static const credentials = '';

}
