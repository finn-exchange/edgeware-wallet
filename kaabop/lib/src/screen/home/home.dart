import 'package:provider/provider.dart';
import 'package:wallet_apps/index.dart';
import 'package:wallet_apps/src/service/portfolio_s.dart';

class Home extends StatefulWidget {
  final bool apiConnected;
  // ignore: avoid_positional_boolean_parameters
  const Home({this.apiConnected});

  static const route = '/home';

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  MenuModel menuModel = MenuModel();
  final HomeModel _homeM = HomeModel();

  String status = '';

  @override
  void initState() {
    // processingDialog(context, true, false, false);
    Timer(const Duration(seconds: 2), () {
      PortfolioServices().setPortfolio(context);
    });

    AppServices.noInternetConnection(_homeM.globalKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContractProvider>(context, listen: false)
          .subscribeBscbalance();
      Provider.of<ContractProvider>(context, listen: false)
          .subscribeEthbalance();
    });

    super.initState();
  }

  Future<void> toReceiveToken() async {
    await Navigator.pushNamed(context, AppText.recieveWalletView);
  }

  void openMyDrawer() {
    _homeM.globalKey.currentState.openDrawer();
  }

  Future<void> onClosed() async {
    await StorageServices.setUserID('claim', 'claim');
    Navigator.pop(context);
  }

  Future<void> onClaim() async {
    Navigator.pop(context);
    await StorageServices.setUserID('claim', 'claim');
    Navigator.push(context, RouteAnimation(enterPage: ClaimAirDrop()));
  }

  Future<void> handle() async {
    Navigator.of(context).pop();
    Timer(const Duration(seconds: 1), () async {
      PortfolioServices().setPortfolio(context);
      showAirdrop();
    });
  }

  Future<void> showAirdrop() async {
    Timer(const Duration(seconds: 1), () async {
      final res = await StorageServices.fetchData('claim');
      if (res == null) {
        await dialogEvent(context, 'assets/bep20.png', onClosed, onClaim);
      }
    });
  }

  Future<void> scrollRefresh() async {
    final contract = Provider.of<ContractProvider>(context, listen: false);
    final api = Provider.of<ApiProvider>(context, listen: false);
    final market = Provider.of<MarketProvider>(context, listen: false);

    await Future.delayed(const Duration(milliseconds: 300)).then((value) async {
      PortfolioServices().setPortfolio(context);
      market.fetchTokenMarketPrice(context);
      if (contract.bnbNative.isContain) {
        contract.getBnbBalance();
      }
      if (contract.token.isNotEmpty) {
        contract.fetchNonBalance();
        contract.fetchEtherNonBalance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      key: _homeM.globalKey,
      drawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: Menu(_homeM.userData),
      ),

      // AnnotatedRegion Use For System Icon Above SafeArea
      body: Column(children: [
        SafeArea(child: homeAppBar(context)),
        Divider(
          height: 2,
          color: isDarkTheme ? Colors.black : Colors.grey.shade400,
        ),
        Flexible(
          child: RefreshIndicator(
            onRefresh: () async {
              await scrollRefresh();
            },
            child: BodyScaffold(
              bottom: 0,
              isSafeArea: false,
              child: HomeBody(),
            ),
          ),
        ),
      ]),

      floatingActionButton: Container(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor:
              hexaCodeToColor(AppColors.secondary).withOpacity(1.0),
          onPressed:
              () async {
            await MyBottomSheet().trxOptions(
              context: context,
              portfolioList: _homeM.portfolioList,
            );
          },
          child: SvgPicture.asset(
            'assets/icons/telegram.svg',
            width: 30,
            height: 30,
            color: Colors.white,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: MyBottomAppBar(
        apiStatus: true,
        homeM: _homeM,
        toReceiveToken: toReceiveToken,
        openDrawer: openMyDrawer,
      ),
    );
  }
}
