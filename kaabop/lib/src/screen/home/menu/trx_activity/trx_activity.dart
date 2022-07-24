// import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wallet_apps/index.dart';
import 'package:wallet_apps/src/components/dimissible_background.dart';
import 'package:wallet_apps/src/models/tx_history.dart';

import '../../../../config/asset_names.dart';

class TrxActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TrxActivityState();
  }
}

class TrxActivityState extends State<TrxActivity> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  bool isProgress = true;
  bool isLogout = false;

  final TxHistory _txHistoryModel = TxHistory();

  @override
  void initState() {
    AppServices.noInternetConnection(_globalKey);
    readTxHistory();

    super.initState();
  }

  Future<List<TxHistory>> readTxHistory() async {
    await StorageServices.fetchData('txhistory').then((value) {
    });
    setState(() {});
    return _txHistoryModel.tx;
  }

  Future<void> _deleteHistory(int index, String symbol) async {
    final SharedPreferences _preferences =
        await SharedPreferences.getInstance();

    final newTxList = List.from(_txHistoryModel.tx)
      ..addAll(_txHistoryModel.txKpi);

    await clearOldHistory().then((value) async {
      await _preferences.setString('txhistory', jsonEncode(newTxList));
    });
  }

  Future<void> clearOldHistory() async {
    await StorageServices.removeKey('txhistory');
  }

  Future<void> showDetailDialog(TxHistory txHistory) async {
    await txDetailDialog(context, txHistory);
  }

  /* Log Out Method */
  void logOut() {
    /* Loading */
    dialogLoading(context);
    AppServices.clearStorage();
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  /* Scroll Refresh */
  void reFresh() {
    setState(() {
      isProgress = true;
    });
  }

  void popScreen() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 0,
      child: Scaffold(
        key: _globalKey,
        appBar: AppBar(
          title: const MyText(
            text: 'Transaction History',
            fontSize: 22.0,
            color: "#FFFFFF",
          ),
          bottom: TabBar(
            tabs: [],
          ),
        ),
        body: TabBarView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: _txHistoryModel.tx == null
                  ? Container()
                  : ListView.builder(
                      itemCount: _txHistoryModel.tx.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: DismissibleBackground(),
                          onDismissed: (direction) {
                            _deleteHistory(
                                index, _txHistoryModel.tx[index].symbol);
                          },
                          child: GestureDetector(
                            onTap: () {
                              showDetailDialog(_txHistoryModel.tx[index]);
                            },
                            child: rowDecorationStyle(
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: const EdgeInsets.all(6),
                                    margin: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color:
                                          hexaCodeToColor(AppColors.secondary),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child:
                                        Image.asset('assets/SelendraCircle-White.png'),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          text:
                                              _txHistoryModel.tx[index].symbol,
                                          color: "#FFFFFF",
                                        ),
                                        MyText(
                                            text: _txHistoryModel.tx[index].org,
                                            fontSize: 15),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          MyText(
                                            text:
                                                _txHistoryModel.tx[index].date,
                                            fontSize: 12,
                                          ),
                                          const SizedBox(height: 5.0),
                                          MyText(
                                            text:
                                                '-${_txHistoryModel.tx[index].amount}',
                                            color: AppColors.secondarytext,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: _txHistoryModel.txKpi == null
                  ? Container()
                  : ListView.builder(
                      itemCount: _txHistoryModel.txKpi.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: DismissibleBackground(),
                          onDismissed: (direction) {
                            _deleteHistory(
                                index, _txHistoryModel.txKpi[index].symbol);
                          },
                          child: GestureDetector(
                            onTap: () {
                              showDetailDialog(_txHistoryModel.txKpi[index]);
                            },
                            child: rowDecorationStyle(
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: const EdgeInsets.all(6),
                                    margin: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                        color: hexaCodeToColor(
                                            AppColors.secondary),
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                    child: Image.asset(
                                        'assets/koompi_white_logo.png'),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          text: _txHistoryModel
                                              .txKpi[index].symbol,
                                          color: "#FFFFFF",
                                        ),
                                        MyText(
                                            text: _txHistoryModel
                                                .txKpi[index].org,
                                            fontSize: 15),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          MyText(
                                            text: _txHistoryModel
                                                .txKpi[index].date,
                                            fontSize: 12,
                                          ),
                                          const SizedBox(height: 5.0),
                                          MyText(
                                            text:
                                                '-${_txHistoryModel.txKpi[index].amount}',
                                            color: AppColors.secondarytext,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
