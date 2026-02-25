import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Models/Dinning.dart';
import '../Models/KOT.dart';
import '../Models/MethodsHomepage/ShowDiologe.dart';
import '../Models/MethodsHomepage/voucher_id.dart';
import '../Models/Provider/ReorderUsingProvider.dart';
import '../Models/Provider/Sending KOT.dart';
import '../Models/Reorder.dart';
import '../Models/SettingsSave.dart';
import '../Models/printer.dart';
import '../Models/saved_kot.dart';
import '../Utils/GlobalFn.dart';
import 'Category.dart';
import 'Dashboard.dart';
import 'ItemsTab.dart';
import 'Running.dart';
import 'Tables.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedItemsProvider(),
      child: const MaterialApp(
        home: Homepage(),
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  final String? employeeName;
  final int? employeeId;

  const Homepage({
    Key? key,
    this.employeeName,
    this.employeeId,
  }) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String? DeviceId = "";
  int selectedQuantity = 1;
  SQLMessage? sqlMessage;
  List<ExtraAddOn>? extraddon;
  List<Category>? category;
  List<Items>? items;
  List<Voucher>? voucher;
  Future<Dinning>? dinningData;
  int? selectedCategoryId;
  Map<String, List<String>> selectedAddonsMap = {};
  final List<SelectedItems> selectedItemsList = [];
  List<SelectExtra> selectedExtraAddons = [];
  KOT? kot;
  List<KOT> kotList = [];
  late List<DeviceInfo> deviceinfo;
  Map<String, Set<String>> selectedSeats = {};
  Map<String, Set<String>> selectedSeatsWithTableIdMap = {};
  TextEditingController noteController = TextEditingController();
  int _sinoCounter = 1;
  List<OrderList>? orderlist = [];
  String? selectedTableName;
  String? selectedChairIdList;
  List<Voucher>? voucherss;
  List<KOT> FromDbKOTlist = [];
  List<KotItem> displayedKotItemss = [];
  List<KotData> kotDatasrunning = [];
  String? ledId;
  List<KotPrint>? kotprint;
  List<PrintAreas>? printAreas;
  List<PrintItems>? printItems;
  ScrollController _scrollController = ScrollController();

  bool isPrinting = false;
  String? lastPrintedKotNo;
  bool printerEnabled = false;
  bool isPrintingUI = false;



  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

// Function to scroll to the bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Print icon fuction for reprint
  Future<void> reprintFullKOT(
      KotProvider kotProvider,
      KotData receivedKOT,
      ) async {
    try {
      if (PrintGuard.isPrinting) return;

      PrintGuard.isPrinting = true;

      final baseUrl = await fnGetBaseUrl();

      List<PrintAreas> apiPrintAreas = await kotProvider.fetchDataPrint();

      Map<String, PrintAreas> uniquePrinterMap = {};

      for (var p in apiPrintAreas) {
        String name = p.printAreaName?.trim() ?? "";
        String ip = p.iPAddress?.trim() ?? "";
        if (ip.isEmpty) continue;
        uniquePrinterMap[name] = p;
      }

      List<PrintAreas> printAreas = uniquePrinterMap.values.toList();

      /// 🔥 BUILD PRINT ITEMS (PRINT ALL WITHOUT CHECKING STATUS)
      List<PrintItems> printItems = [];

      for (var i in kotProvider.selectedItemsOldPrintList) {

        List<AddonItems> addonPrint = buildAddonPrint(i.selectextra);

        printItems.add(PrintItems(
          itemId: i.itemId,
          name: i.name,
          sRate: i.sRate.toInt(),
          printer: i.printer,
          catId: i.catId,
          qty: i.quantity.toString(),  // 🔥 FULL QTY
          OldQty: i.quantity.toString(),
          itemModifiedStatus: "NEW ORDER", // 👈 CUSTOM STATUS
          extraNote: i.extraNote,
          addonItems: addonPrint,
        ));
      }

      /// 🔥 GROUP BY PRINTER
      Map<String, List<PrintItems>> printerWise = {};

      for (var item in printItems) {
        String printer = item.printer?.trim() ?? "";
        if (printer.isEmpty) continue;

        printerWise.putIfAbsent(printer, () => []);
        printerWise[printer]!.add(item);
      }

      /// 🔥 PRINT EACH PRINTER
      for (var area in printAreas) {

        String areaName = area.printAreaName?.trim() ?? "";
        List<PrintItems> itemsForPrinter = printerWise[areaName] ?? [];

        if (itemsForPrinter.isEmpty) continue;

        final singlePrint = KotPrint(
          mode: receivedKOT.mode,
          extraNote: kotProvider.noteController.text.trim(),
          kOTNo: receivedKOT.vno.toString(),
          orderDate: '',
          printType: 'KOT_VOUCHER',   // 👈 DIFFERENT PRINT TYPE
          staff: kotProvider.employeeId.toString(),
          tableArea: '',
          tableName: receivedKOT.tableId.toString(),
          tableSeat: receivedKOT.tableSeat,
          printAreas: [area],
          printItems: itemsForPrinter,
        );

        debugPrint("🖨 REPRINT JSON → $areaName");
        debugPrint(jsonEncode(singlePrint.toJson()));

        await http.post(
          Uri.parse('$baseUrl/api/Dinein/kotPrint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(singlePrint.toJson()),
        );
      }

    } catch (e) {
      debugPrint("❌ REPRINT ERROR: $e");
    } finally {
      PrintGuard.isPrinting = false;
    }
  }


  void _handleKOTDataReceived(List<KotData> kotDataList) {
    setState(() {
      kotDatasrunning = kotDataList;
      // print("hhhhhhFFF$kotDatasrunning");
    });
  }

  void _handleSavePressed(Map<String, Set<String>> selectedSeatsMap) {
    setState(() {
      selectedSeats = selectedSeatsMap;
      selectedSeatsWithTableIdMap = selectedSeatsMap;
    });
  }

// Somewhere in your code, make sure displayedKotItemss is being populated correctly
//   void populateDisplayedKotItems() {
//     // Example logic to populate displayedKotItemss
//     if (kotDatasrunning.isNotEmpty) {
//       displayedKotItemss = kotDatasrunning.first.kotItems;
//       print("jhjhjhjhjhjjhjhj$displayedKotItemss");
//     } else {
//       displayedKotItemss = [];
//     }
//   }

  // Future<void> fetchKotData() async {
  //   try {
  //     String? baseUrl = await fnGetBaseUrl();
  //     String apiUrl = '$baseUrl/api/Dinein/getbyid?DeviceId=$DeviceId&IssueCode=$issueCode&Vno=$vno&LedCode=$ledCode&VType=KOT';
  //
  //     final response = await http.get(
  //       Uri.parse(apiUrl),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       final kotDatas = KotData.fromJson(jsonResponse['Data']['KotData']);
  //       _handleKOTDataReceived([kotDatas]);
  //     } else {
  //       print('Failed to fetch order list from API. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  void _handleClosePressed(
      String tableName, Set<String> seats, String tableId) {
    setState(() {
      selectedSeats.remove(tableName);
      selectedSeats.remove(tableId);
      selectedSeatsWithTableIdMap.remove(tableId);
      selectedSeatsWithTableIdMap.remove(tableName);
    });
  }

  @override
  void initState() {
    super.initState();
    dinningData = fetchData2();
    tabController = TabController(length: 4, vsync: this, initialIndex: 0);
  }

  Future<Dinning> fetchData2() async {
    DeviceId = await fnGetDeviceId();
    final String? baseUrl = await fnGetBaseUrl();
    String apiUrl = '${baseUrl}api/Dinein/alldata';
    try {
      apiUrl = '$apiUrl?DeviceId=$DeviceId';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        Dinning dinning = Dinning.fromJson(json.decode(response.body));

        sqlMessage = dinning.data?.sQLMessage;
        if (sqlMessage?.code == "200") {
          extraddon = dinning.data?.extraAddOn;
          category = dinning.data?.category;
          items = dinning.data?.items;
          voucher = dinning.data?.voucher;
          setState(() {
            orderlist = dinning.data?.orderlist;
          });
          // KotProvider kotProvider = Provider.of<KotProvider>(context, listen: false);
          // kotProvider.updateOrderList(orderlist!);
        }
        return dinning;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          hintColor: Colors.black87,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: Scaffold(
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            bool isPortrait =
                MediaQuery.of(context).orientation == Orientation.portrait;
            return isPortrait ? buildPortraitLayout() : buildLandscapeLayout();
          }),
        ));
  }

  Widget buildPortraitLayout() {
    KotProvider kotProviders = Provider.of<KotProvider>(
      context,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              int currentIndex = tabController.index;
              if (currentIndex == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Dashboardpage(),
                  ),
                );
              }
            },
          ),
          title: Text(widget.employeeName ?? 'Homepage'),
          centerTitle: true,
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.black87,
            labelColor: Colors.white,
            tabs: const [
              Tab(text: "Tables"),
              Tab(text: "CATEGORY"),
              Tab(text: "ITEMS"),
              Tab(text: "RUNNING"),
            ],
          ),
        ),
        body: FutureBuilder<Dinning>(
          future: dinningData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.data == null) {
              return const Center(child: Text('No data available'));
            } else {
              Dinning dinning = snapshot.data!;
              List<OrderList>? orderlist = dinning.data?.orderlist;
              List<Tables>? tables = dinning.data?.tables;
              List<Voucher>? voucher = dinning.data?.voucher;
              return TabBarView(
                controller: tabController,
                children: [
                  Center(
                    child: TablesTab(
                      tabIndex: 0,
                      tables: tables,
                      tabController: tabController,
                      onSavePressed: _handleSavePressed,
                      onClosePressed: _handleClosePressed,
                      orderList: orderlist,
                    ),
                  ),
                  Center(
                    child: CategoryTab(
                      category: category,
                      tabIndex: 1,
                      tabController: tabController,
                      onCategorySelected: (categoryId) {
                        setState(() {
                          selectedCategoryId = categoryId;
                        });
                      },
                    ),
                  ),
                  Center(
                    child: ItemsTab(
                      tabIndex: 2,
                      items: items,
                      selectedCategoryId: selectedCategoryId,
                      onItemAdded: (SelectedItems newItem) {
                        setState(() {
                          // Assign SINO based on the current length of selectedItemsListee
                          newItem.SINO =
                              (selectedItemsList.length + 1).toString();
                          selectedItemsList.add(newItem);
                          // Increment SINO counter
                          _sinoCounter++;
                          // Update SINO for all items in selectedItemsListee
                          //updateSinoNumbers();
                        });
                      },
                      removeItemCallback: (double itemId) {
                        setState(() {
                          // Remove the item from selectedItemsListee
                          selectedItemsList
                              .removeWhere((item) => item.itemId == itemId);
                          // Decrement SINO counter
                          _sinoCounter--;
                          // Update SINO for all items in selectedItemsListee
                          // updateSinoNumbers();
                        });
                      },
                    ),
                  ),
                  Center(
                    child: RunningTab(
                      orderList: orderlist,
                      tabIndex: 3,
                      voucher: voucher,
                      tabController: tabController,
                      onKOTDataReceived: _handleKOTDataReceived,
                    ),
                  )
                ],
              );
            }
          },
        ),
        bottomNavigationBar: SingleChildScrollView(
          child: Container(
            child: Card(
              color: Colors.white70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Consumer<SelectedItemsProvider>(
                          builder: (context, SelectedItemsProvider, child) {
                            return Text(
                              "KOT : ${SelectedItemsProvider.issuecodeFromDB}",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 400,
                          child: Center(
                            child: Consumer<SelectedItemsProvider>(
                              builder: (context, provider, _) {
                                return Text(
                                  provider.DisplayTbSc,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2, color: Colors.black87),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Text(
                                        "Item",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(
                                        "Quantity",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Text(
                                        "Rate",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Text(
                                        "Total",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 50),
                                  ],
                                ),
                                SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount:
                                        kotProviders.selectedItemsListKot.length,
                                    itemBuilder: (context, index) {
                                      SelectedItems selectedItem = kotProviders
                                          .selectedItemsListKot[index];
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Text(
                                              '${index + 1}. ', // Add serial number
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                showExtraAddonDialog(
                                                  context,
                                                  extraddon!,
                                                  selectedItem,
                                                );
                                              },
                                              child: SizedBox(
                                                width: 150,
                                                child: Text(
                                                  selectedItem.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 50),
                                              child: SizedBox(
                                                width: 50,
                                                child: Center(
                                                    child: DropdownButton<int>(
                                                  value: selectedItem.quantity,
                                                  onChanged:
                                                      (int? newQuantity) {
                                                    final KotProvider
                                                        kotProvider = Provider
                                                            .of<KotProvider>(
                                                                context,
                                                                listen: false);
                                                    if (newQuantity != null) {
                                                      setState(() {
                                                        if (kotProvider.kotDatasrunning.isNotEmpty && kotProvider.kotDatasrunning[0].mode == 'U') {
                                                          {
                                                            if (selectedItem.ItemStatus == 'OLD') {
                                                              if (selectedItem.quantity < newQuantity) {selectedItem.itemModifiedStatus = 'ADD_QTY';
                                                              } else if (selectedItem.quantity > newQuantity) {selectedItem.itemModifiedStatus = 'CANCELLED_QTY';
                                                              }
                                                            }
                                                            selectedItem.quantity = newQuantity;
                                                            selectedItem.NetAmount = selectedItem.sRate * newQuantity;
                                                          }
                                                        } else {
                                                          selectedItem.quantity = newQuantity;
                                                          selectedItem.NetAmount = selectedItem.sRate * newQuantity;
                                                        }
                                                      });
                                                    }
                                                  },
                                                  items: List.generate(10,
                                                      (index) {
                                                    return DropdownMenuItem<
                                                        int>(
                                                      value: index + 1,
                                                      child: Text((index + 1)
                                                          .toString()),
                                                    );
                                                  }),
                                                )),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 60),
                                              child: Text(selectedItem.sRate
                                                  .toString()),
                                            ),
                                            Text(
                                                selectedItem.NetAmount
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            const SizedBox(width: 10),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {

                                                final kotProvider =
                                                Provider.of<KotProvider>(context, listen: false);
                                                final itemName = selectedItem.name; // current row item
                                                kotProvider.removeSelectedItemfromDb(itemName);
                                                /// 🔥 REMOVE FROM PROVIDER
                                                kotProvider.removeSelectedItemone(itemName);
                                              },
                                            ),
                                          ],
                                        ),
                                        subtitle: buildSelectExtras(
                                            selectedItem.selectextra),
                                      );
                                    },

                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: Row(
                                    children: [
                                      const Spacer(),
                                      const Text("Total : ",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      const SizedBox(width: 5),
                                      Text(
                                          "${kotProviders.OverallTotal(kotProviders.selectedItemsListKot)}",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      const SizedBox(
                                        width: 80,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17.0),
                            ),
                            elevation: 5,
                            child: IconButton(
                              iconSize: 30,
                              icon: const Icon(
                                Icons.add,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17.0),
                            ),
                            elevation: 5,
                            child: IconButton(
                              iconSize: 30,
                              icon: const Icon(
                                Icons.remove,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(
                            width: 100,
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Enter Note"),
                                    content: TextField(
                                      controller: kotProviders.noteController,
                                      decoration: const InputDecoration(
                                          hintText: "Type your note here"),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("OK"),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Dismiss the dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Card(
                              color: Colors.black87,
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text(
                                  "NOTE",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                noteController.clear();
                                selectedSeats.clear();
                                selectedItemsList.clear();
                                kotProviders.noteController.clear();
                                kotProviders.selectedSeats.clear();
                                kotProviders.selectedItemsListKot.clear();
                                kotProviders.selectedItemsOldPrintList.clear();
                              });
                            },
                            child: const Card(
                              color: Colors.black87,
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text(
                                  "CLEAR",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          InkWell(
                            onTap: () async {
                              if (kotProviders.kotDatasrunning.isEmpty) return;

                              final receivedKOT = kotProviders.kotDatasrunning.first;

                              await reprintFullKOT(kotProviders, receivedKOT);
                            },
                            child: const Icon(Icons.print, size: 35),
                          ),
                          const SizedBox(
                            width: 20,
                          ),

              GestureDetector(
                onTap: () async {
                  debugPrint("🟢 KOT BUTTON CLICKED");
                  final noteText = kotProviders.noteController.text.trim();
                  final kotProvider =
                  Provider.of<KotProvider>(context, listen: false);
                  /// 🔥 PROCESS ALL REMOVED ITEMS BEFORE SENDING
                  for (String name in kotProvider.removedItemNames) {
                    kotProvider.removeSelectedItemfromDb(name);
                  }
                  debugPrint("🔍 BEFORE SENDING ITEMS:");
                  for (var item in kotProvider.selectedItemsOldPrintList) {
                    debugPrint(
                        "ITEM: ${item.name} | STATUS: ${item.itemModifiedStatus}");
                  }
                  /// CLONE SEATS
                  final Map<String, Set<String>> localSeats =
                  selectedSeats.map(
                        (key, value) => MapEntry(key, Set<String>.from(value)),
                  );

                  /// ⭐ IMPORTANT: SEND selectedItemsOld (NOT UI LIST)
                  final List<SelectedItems> localItems =
                  List<SelectedItems>.from(
                      kotProvider.selectedItemsOldPrintList);
                  debugPrint("ITEM COUNT SENT TO API: ${localItems.length}");

                  /// CLEAR UI
                  setState(() {
                    selectedSeats.clear();
                    selectedItemsList.clear();
                    isPrintingUI = false;
                  });
                  await Future.delayed(Duration.zero);

                  /// PROCESS
                  await _processKotAndPrint(
                    kotProviders,
                    localSeats,
                    localItems,
                    noteText);

                  /// CLEAR PROVIDER AFTER PRINT
                  kotProvider.clearAll();
                  kotProviders.noteController.clear();
                  kotProviders.selectedItemsListKot.clear();
                  kotProviders.selectedItemsOldPrintList.clear();
                  kotProviders.selectedSeats.clear();
                },
                child: Card(
                  color: Colors.black87,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "   KOT   ",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
                          const SizedBox(
                            width: 20,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget buildLandscapeLayout() {
    KotProvider kotProviders = Provider.of<KotProvider>(
      context,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.white70,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),

                  //Landscape first row
                  Row(
                    children: [
                      Text(
                        "KOT:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      SizedBox(
                        width: 300,
                        child: Center(
                          child: Consumer<SelectedItemsProvider>(
                            builder: (context, provider, _) {
                              return Text(
                                provider.DisplayTbSc,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(thickness: 2, color: Colors.black87),




                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 20, right: 10, bottom: 0, top: 0),
                                    child: Text(
                                      "Item",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 20, right: 20, bottom: 0, top: 0),
                                    child: Text(
                                      "Qty",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 5, right: 10),
                                    child: Text(
                                      "Rate",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 0, right: 0),
                                    child: Text(
                                      "Total",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 60),
                                ],
                              ),
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount:
                                  kotProviders.selectedItemsListKot.length,
                                  itemBuilder: (context, index) {
                                    SelectedItems selectedItem = kotProviders
                                        .selectedItemsListKot[index];
                                    return ListTile(
                                      title: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              showExtraAddonDialog(
                                                context,
                                                extraddon!,
                                                selectedItem,
                                              );
                                            },
                                            child: SizedBox(
                                              width: 150,
                                              child: Text(
                                                selectedItem.name,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          // Dropdown button for selecting quantity
                                          SizedBox(
                                            width: 50,
                                            child: Center(
                                              child: DropdownButton<int>(
                                                value: selectedItem.oldQuandity,
                                                onChanged: (int? newQuantity) {
                                                  if (newQuantity != null) {
                                                    setState(() {
                                                      selectedItem.quantity =
                                                          newQuantity;
                                                      selectedItem.oldQuandity =
                                                          newQuantity;
                                                      // Update the itemtotal based on the new quantity
                                                      selectedItem.NetAmount =
                                                          selectedItem.sRate *
                                                              newQuantity;
                                                    });
                                                  }
                                                },
                                                items:
                                                    List.generate(10, (index) {
                                                  // Generate dropdown menu items for quantities 1 to 10
                                                  return DropdownMenuItem<int>(
                                                    value: index + 1,
                                                    child: Text(
                                                        (index + 1).toString()),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(selectedItem.sRate.toString()),
                                          const SizedBox(width: 5),
                                          Text(
                                            selectedItem.NetAmount.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700),
                                          ),
                                          // Button for deleting item
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            iconSize: 23,
                                            onPressed: () {
                                                final selectedItemsProvider =
                                                Provider.of<KotProvider>(
                                                    context,
                                                    listen: false);
                                                selectedItemsProvider
                                                    .removeSelectedItemone(
                                                    selectedItem.name);
                                                // kotProviders.selectedItemsListKot
                                                //     .removeWhere((item) =>
                                                //         item.name ==
                                                //         selectedIteme.name);
                                            },
                                          ),
                                        ],
                                      ),
                                      subtitle: buildSelectExtras(
                                          selectedItem.selectextra),
                                    );
                                  },
                                ),
                              ),
                              const Divider(),
                              SizedBox(
                                height: 30,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    const Text(
                                      "Total : ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${kotProviders.OverallTotal(kotProviders.selectedItemsListKot)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 70,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17.0),
                                ),
                                elevation: 5,
                                child: IconButton(
                                  iconSize: 25,
                                  icon: const Center(
                                    child: Icon(
                                      Icons.add,
                                    ),
                                  ),
                                  onPressed: () {
                                    // Implement your logic
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17.0),
                                ),
                                elevation: 5,
                                child: IconButton(
                                  iconSize: 25,
                                  icon: const Center(
                                    child: Icon(
                                      Icons.remove,
                                    ),
                                  ),
                                  onPressed: () {
                                    // Implement your logic
                                  },
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  noteController.clear();
                                  selectedSeats.clear();
                                  selectedItemsList.clear();
                                  kotProviders.noteController.clear();
                                  kotProviders.selectedSeats.clear();
                                  kotProviders.selectedItemsListKot.clear();
                                  kotProviders.selectedItemsOldPrintList.clear();
                                });
                              },
                              child: const Card(
                                color: Colors.black87,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    "CLEAR",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Enter Note"),
                                      content: TextField(
                                        controller: kotProviders.noteController,
                                        decoration: const InputDecoration(
                                            hintText: "Type your note here"),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Dismiss the dialog
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Card(
                                color: Colors.black87,
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text("NOTE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  debugPrint("🟢 KOT BUTTON CLICKED");

                                  final kotProvider =
                                  Provider.of<KotProvider>(context, listen: false);

                                  /// CLONE SEATS
                                  final Map<String, Set<String>> localSeats =
                                  selectedSeats.map(
                                        (key, value) => MapEntry(key, Set<String>.from(value)),
                                  );

                                  /// ✅ CLONE CORRECT ITEMS LIST
                                  final List<SelectedItems> localItems =
                                  List<SelectedItems>.from(
                                      kotProvider.selectedItemsListKot);

                                  debugPrint("ITEM COUNT: ${localItems.length}");

                                  final localNote = noteController.text;

                                  /// CLEAR UI FAST
                                  setState(() {
                                    selectedSeats.clear();
                                    selectedItemsList.clear();
                                    noteController.clear();
                                    isPrintingUI = false;
                                  });

                                  /// CLEAR PROVIDER AFTER CLONE
                                  kotProvider.clearAll();

                                  await Future.delayed(Duration.zero);

                                  /// PROCESS
                                  _processKotAndPrint(
                                      kotProvider, localSeats, localItems, localNote);
                                },
                                child: InkWell(
                                    onTap: () async {
                                      if (kotProviders.kotDatasrunning.isEmpty) return;

                                      final receivedKOT = kotProviders.kotDatasrunning.first;

                                      await reprintFullKOT(kotProviders, receivedKOT);
                                    },
                                    child: const Icon(Icons.print, size: 35))),


                            const SizedBox(
                              width: 20,
                            ),

                            GestureDetector(
                              onTap: () async {
                                debugPrint("🟢 KOT BUTTON CLICKED");

                                final kotProvider =
                                Provider.of<KotProvider>(context, listen: false);
                                /// 🔥 PROCESS ALL REMOVED ITEMS BEFORE SENDING
                                for (String name in kotProvider.removedItemNames) {
                                  kotProvider.removeSelectedItemfromDb(name);
                                }
                                debugPrint("🔍 BEFORE SENDING ITEMS:");
                                for (var item in kotProvider.selectedItemsOldPrintList) {
                                  debugPrint(
                                      "ITEM: ${item.name} | STATUS: ${item.itemModifiedStatus}");
                                }
                                /// CLONE SEATS
                                final Map<String, Set<String>> localSeats =
                                selectedSeats.map(
                                      (key, value) => MapEntry(key, Set<String>.from(value)),
                                );

                                /// ⭐ IMPORTANT: SEND selectedItemsOld (NOT UI LIST)
                                final List<SelectedItems> localItems =
                                List<SelectedItems>.from(
                                    kotProvider.selectedItemsOldPrintList);
                                debugPrint("ITEM COUNT SENT TO API: ${localItems.length}");
                                final localNote = noteController.text;

                                /// CLEAR UI
                                setState(() {
                                  selectedSeats.clear();
                                  selectedItemsList.clear();
                                  noteController.clear();
                                  isPrintingUI = false;
                                });

                                /// DO NOT clear provider here
                                await Future.delayed(Duration.zero);

                                /// PROCESS
                                await _processKotAndPrint(
                                    kotProvider, localSeats, localItems, localNote);

                                /// CLEAR PROVIDER AFTER PRINT
                                kotProvider.clearAll();
                              },
                              child: Card(
                                color: Colors.black87,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 20.0,left: 20,top: 10,bottom: 10),
                                  child: Text("KOT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: double.infinity,
          width: 600,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueGrey,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  int currentIndex = tabController.index;
                  if (currentIndex == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Dashboardpage(),
                      ),
                    );
                  }
                },
              ),
              title: Text(widget.employeeName ?? 'Homepage'),
              centerTitle: true,
              bottom: TabBar(
                controller: tabController,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                labelColor: Colors.white,
                tabs: const [
                  Tab(text: "Tables"),
                  Tab(text: "CATEGORY"),
                  Tab(text: "ITEMS"),
                  Tab(text: "RUNNING"),
                ],
              ),
            ),
            body: FutureBuilder<Dinning>(
              future: dinningData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data == null ||
                    snapshot.data!.data == null) {
                  return const Center(child: Text('No data available'));
                } else {
                  Dinning dinning = snapshot.data!;
                  List<OrderList>? orderlist = dinning.data?.orderlist;
                  List<Tables>? tables = dinning.data?.tables;
                  List<Voucher>? voucher = dinning.data?.voucher;

                  return TabBarView(
                    controller: tabController,
                    children: [
                      Center(
                        child: TablesTab(
                          tabIndex: 0,
                          tables: tables,
                          tabController: tabController,
                          onSavePressed: _handleSavePressed,
                          onClosePressed: _handleClosePressed,
                          orderList: orderlist,
                        ),
                      ),
                      Center(
                        child: CategoryTab(
                          category: category,
                          tabIndex: 1,
                          tabController: tabController,
                          onCategorySelected: (categoryId) {
                            setState(() {
                              selectedCategoryId = categoryId;
                            });
                          },
                        ),
                      ),
                      Center(
                        child: ItemsTab(
                          tabIndex: 2,
                          items: items,
                          selectedCategoryId: selectedCategoryId,
                          onItemAdded: (SelectedItems newItem) {
                            setState(() {
                              // Assign SINO based on the current length of selectedItemsListee
                              newItem.SINO =
                                  (selectedItemsList.length + 1).toString();
                              selectedItemsList.add(newItem);
                              // Increment SINO counter
                              _sinoCounter++;
                              // Update SINO for all items in selectedItemsListee
                              //updateSinoNumbers();
                            });
                          },
                          removeItemCallback: (double itemId) {
                            setState(() {
                              // Remove the item from selectedItemsListee
                              selectedItemsList.removeWhere(
                                  (item) => item.itemId == itemId);
                              // Decrement SINO counter
                              _sinoCounter--;
                              // Update SINO for all items in selectedItemsListee
                              // updateSinoNumbers();
                            });
                          },
                        ),
                      ),
                      Center(
                        child: RunningTab(
                          orderList: orderlist,
                          tabIndex: 3,
                          voucher: voucher,
                          tabController: tabController,
                          onKOTDataReceived: _handleKOTDataReceived,
                        ),
                      )
                    ],
                  );
                }
              },
            ),
          ),
        )
      ],
    );
  }
}

Future<void> _processKotAndPrint(
    KotProvider kotProvider,
    Map<String, Set<String>> localSeats,
    List<SelectedItems> localItems,
    String localNote,
    ) async {
  try {
    if (localItems.isEmpty) {
      debugPrint("❌ NO ITEMS SELECTED");
      return;
    }

    await kotProvider.fetchingvoucherID(localSeats);
    final voucher = kotProvider.voucher;

    if (voucher == null || voucher.isEmpty) {
      debugPrint("❌ VOUCHER EMPTY");
      return;
    }

    final ledId = voucher.first.ledId.toString();

    final kotDataToSend = kotProvider.SendingKotToDb(
      localSeats,
      ledId,
      localNote,
    );

    if (kotDataToSend == null) return;

    debugPrint("🟢 KOT SENDING DATA: ${jsonEncode(kotDataToSend.toJson())}");

    final baseUrl = await fnGetBaseUrl();

    /// 🔥 SAVE KOT
    final saveResponse = await http.post(
      Uri.parse('$baseUrl/api/Dinein/saveKOT?DeviceId=${kotProvider.deviceId}'),
      headers: {'Content-Type': 'application/json'},
       body: jsonEncode(kotDataToSend.toJson()),
    );

    if (saveResponse.statusCode != 200) {
      debugPrint("❌ SAVE KOT FAILED");
      return;
    }

    final saveJson = jsonDecode(saveResponse.body);
    final savedKotJson = saveJson['Data']?['SavedKot'];

    if (savedKotJson == null) {
      debugPrint("❌ SAVED KOT NULL");
      return;
    }

    final receivedKOT = KotData.fromJson(savedKotJson);

    /// 🔐 PRINT LOCK
    if (PrintGuard.isPrinting) {
      debugPrint("🚫 PRINT BLOCKED");
      return;
    }

    PrintGuard.isPrinting = true;

    /// 🖨 FETCH PRINTERS
    List<PrintAreas> apiPrintAreas = await kotProvider.fetchDataPrint();

    Map<String, PrintAreas> uniquePrinterMap = {};

    for (var p in apiPrintAreas) {
      String name = p.printAreaName?.trim() ?? "";
      String ip = p.iPAddress?.trim() ?? "";

      if (ip.isEmpty) continue;
      uniquePrinterMap[name] = p;
    }

    List<PrintAreas> printAreas = uniquePrinterMap.values.toList();
    List<PrintItems> printItems = [];

    for (var i in kotProvider.selectedItemsOldPrintList) {
      int oldQty = i.oldQuandity ?? 0;
      int newQty = i.quantity ?? 0;
      String status = i.itemModifiedStatus?.trim() ?? "";

      /// ⭐ BUILD ADDON LIST HERE
      List<AddonItems> addonPrint = buildAddonPrint(i.selectextra);

      debugPrint("🧾 ADDONS COUNT => ${addonPrint.length}");

      /// FRESH
      if (status == "FRESH") {
        printItems.add(PrintItems(
          itemId: i.itemId,
          name: i.name,
          sRate: i.sRate.toInt(),
          printer: i.printer,
          qty: newQty.toString(),
          OldQty: oldQty.toString(),
          itemModifiedStatus: "FRESH",
          extraNote: i.extraNote,
          addonItems: addonPrint,   // ⭐ FIXED
        ));
      }

      /// NEW ORDER
      else if (status == "NEW ORDER") {
        printItems.add(PrintItems(
          itemId: i.itemId,
          name: i.name,
          sRate: i.sRate.toInt(),
          printer: i.printer,
          catId: i.catId,
          qty: newQty.toString(),
          OldQty: oldQty.toString(),
          itemModifiedStatus: "NEW ORDER",
          extraNote: i.extraNote,
          addonItems: addonPrint,   // ⭐ FIXED
        ));
      }

      /// REMOVED FULL
      else if (status == "REMOVED") {
        printItems.add(PrintItems(
          itemId: i.itemId,
          name: i.name,
          sRate: i.sRate.toInt(),
          printer: i.printer,
          catId: i.catId,
          qty: oldQty.toString(),
          OldQty: oldQty.toString(),
          itemModifiedStatus: "REMOVED",
          extraNote: i.extraNote,
          addonItems: addonPrint,   // ⭐ FIXED
        ));
      }

      /// QTY INCREASE
      else if (newQty > oldQty) {
        int diff = newQty - oldQty;

        printItems.add(PrintItems(
          itemId: i.itemId,
          name: i.name,
          sRate: i.sRate.toInt(),
          printer: i.printer,
          catId: i.catId,
          qty: diff.toString(),
          OldQty: oldQty.toString(),
          itemModifiedStatus: "NEW ORDER",
          extraNote: i.extraNote,
          addonItems: addonPrint,   // ⭐ FIXED
        ));
      }

      /// QTY DECREASE
      else if (newQty < oldQty) {
        int diff = oldQty - newQty;

        printItems.add(PrintItems(
          itemId: i.itemId,
          name: i.name,
          sRate: i.sRate.toInt(),
          printer: i.printer,
          catId: i.catId,
          qty: diff.toString(),
          OldQty: oldQty.toString(),
          itemModifiedStatus: "REMOVED",
          extraNote: i.extraNote,
          addonItems: addonPrint,   // ⭐ FIXED
        ));
      }
    }


    if (printItems.isEmpty) {
      debugPrint("🚫 NOTHING TO PRINT");
      PrintGuard.isPrinting = false;
      return;
    }

    /// 🔥 GROUP BY PRINTER
    Map<String, List<PrintItems>> printerWise = {};

    for (var item in printItems) {
      String printer = item.printer?.trim() ?? "";
      if (printer.isEmpty) continue;

      printerWise.putIfAbsent(printer, () => []);
      printerWise[printer]!.add(item);
    }

    /// 🖨 PRINT EACH PRINTER
    for (var area in printAreas) {
      String areaName = area.printAreaName?.trim() ?? "";

      List<PrintItems> itemsForPrinter = printerWise[areaName] ?? [];

      if (itemsForPrinter.isEmpty) {
        debugPrint("⛔ NO ITEMS FOR $areaName");
        continue;
      }

      final singlePrint = KotPrint(
        mode: receivedKOT.mode,
        extraNote:localNote,
        kOTNo: receivedKOT.vno.toString(),
        orderDate: '',
        printType: 'KOT_VOUCHER',
        staff: kotProvider.employeeId.toString(),
        tableArea: '',
        tableName: receivedKOT.tableId.toString(),
        tableSeat: receivedKOT.tableSeat,
        printAreas: [area],
        printItems: itemsForPrinter,
      );

      debugPrint("🧾 PRINT JSON FOR $areaName");
      debugPrint(jsonEncode(singlePrint.toJson()));

      final printResponse = await http.post(
        Uri.parse('$baseUrl/api/Dinein/kotPrint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(singlePrint.toJson()),
      );

      if (printResponse.statusCode == 200) {
        debugPrint("✅ PRINT SUCCESS → $areaName");
      } else {
        debugPrint("❌ PRINT FAILED → $areaName");
      }
    }

    /// RESET STATUS
    for (var i in localItems) {
      i.oldQuandity = i.quantity;
      i.itemModifiedStatus = "";
    }

  } catch (e) {
    debugPrint("❌ ERROR: $e");
  } finally {
    PrintGuard.isPrinting = false;
  }
}

// Function using addons in printing only
List<AddonItems> buildAddonPrint(List<SelectExtra>? addons) {
  List<AddonItems> addonList = [];
  if (addons == null || addons.isEmpty) return addonList;

  for (var a in addons) {
    addonList.add(
      AddonItems(
        name: a.itemName,
        AddonModifiedStatus: a.AddonModifiedStatus,
        itemId: a.itemId,
        qty: a.qty,
      ),
    );
  }

  return addonList;
}




class PrintGuard {
  static bool isPrinting = false;
  static String? lastKotNo;
}

