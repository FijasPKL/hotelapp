import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../Models/Dinning.dart';
import '../Models/Provider/ReorderUsingProvider.dart';
import '../Models/Provider/Sending KOT.dart';
import '../Models/Reorder.dart';
import '../Utils/GlobalFn.dart';

class RunningTab extends StatefulWidget {
  final int tabIndex;
  final List<OrderList>? orderList;
  final List<Voucher>? voucher;
  final TabController tabController;
  final Function(List<KotData>) onKOTDataReceived;

  const RunningTab({
    Key? key,
    required this.tabIndex,
    required this.orderList,
    required this.voucher,
    required this.tabController,
    required this.onKOTDataReceived,
  }) : super(key: key);

  @override
  _RunningTabState createState() => _RunningTabState();
}

class _RunningTabState extends State<RunningTab> {
  String? deviceId = "";
  List<Reorder> reorderList = [];
  List<KotData> fromDbKOTlist = [];

  @override
  void initState() {
    super.initState();
    KotProvider kotProvider = Provider.of<KotProvider>(context, listen: false);
    kotProvider.fetchData2();
  }

  @override
  Widget build(BuildContext context) {
    // KotProvider kotProvider = Provider.of<KotProvider>(context);

    return Scaffold(
      body: Consumer<KotProvider>(
        builder: (context, kotProvider, child) {
          return GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: kotProvider.orderList.length,
            itemBuilder: (context, index) {
              OrderList order = kotProvider.orderList[index];
              return GestureDetector(
                child: Card(
                  child: InkWell(
                    onTap: () async {
                      SelectedItemsProvider selectedItemsProvider =
                          Provider.of<SelectedItemsProvider>(context,
                              listen: false);
                      KotProvider selectedKOTprovider =
                          Provider.of<KotProvider>(context, listen: false);
                      String? tableName = order?.tableName;
                      String? chairIdList = order?.chairIdList;
                      int? issueCodeInt = order?.issueCode;
                      String? issueCode = issueCodeInt?.toString();
                      String? vno = order?.vNo;
                      String? ledCode = order?.ledcodeCr;

                      try {
                        String? baseUrl = await fnGetBaseUrl();
                        String apiUrl =
                            '$baseUrl/api/Dinein/getbyid?DeviceId=$deviceId&IssueCode=$issueCode&Vno=$vno&LedCode=$ledCode&VType=KOT';
                        final response = await http.get(
                          Uri.parse(apiUrl),
                          headers: {'Content-Type': 'application/json'},
                        );
                        if (response.statusCode == 200) {
                          final jsonResponse = json.decode(response.body);
                          final kotDatas =
                              KotData.fromJson(jsonResponse['Data']['KotData']);
                          print("Data received: $kotDatas");
                          selectedKOTprovider.updateKotDatas(kotDatas);
                          selectedItemsProvider.RunningTabTbCh(
                              tableName ?? '', chairIdList ?? '');
                          selectedItemsProvider.RunningIssueCode(issueCode!);
                          selectedItemsProvider
                              .UpdateselectedSeatIntoRunningTabTbCh();
                          widget.onKOTDataReceived([kotDatas]);
                          selectedKOTprovider.UpdateselectedItemsRtoS();
                          widget.tabController.animateTo(1);
                        } else {
                          print(
                              'Failed to fetch order list from API. Status code: ${response.statusCode}');
                        }
                      } catch (e) {
                        print('Error: $e');
                      }
                    },
                    child: SizedBox(
                      height: 100,
                      child: ListTile(
                        title: Text(
                          order.tableName ?? '',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID: ${order?.issueCode ?? ''}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                            ),
                            Text(
                              'Time ${order?.timeAgo ?? ''}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
