import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/Settings.dart';
import '../Models/SettingsSave.dart';
import '../Utils/GlobalFn.dart';

class logsettings extends StatefulWidget {
  const logsettings({Key? key}) : super(key: key);

  @override
  State<logsettings> createState() => _logsettingsState();
}

class _logsettingsState extends State<logsettings> {
  String? DeviceId = "";
  SQLMessage? sqlMessage;
  List<TableClass>? tableClass;
  List<KOTVoucher>? kotVoucher;
  List<TAVoucher>? taVoucher;
  List<PrintArea>? printArea;
  late List<SavedSettings> savedsettings;

  //single dropdown items
  TableClass? selTableClass;
  KOTVoucher? selKOTVoucher;
  TAVoucher? selTAVoucher;
  PrintArea? selFirstprint;
  PrintArea? selSecondprint;
  PrintArea? selThirdprint;
  PrintArea? selFourthprint;
  PrintArea? selFifthprint;

  final ipController1 = TextEditingController();
  final ipController2 = TextEditingController();
  final ipController3 = TextEditingController();
  final ipController4 = TextEditingController();
  final ipController5 = TextEditingController();

  @override
  void initState() {
    fetchData();
    LoadSettings();
    super.initState();
  }

  Future<void> SaveSettings() async {
    SettingsSave settingsSave = SettingsSave();
    settingsSave.devideInfo = DeviceInfo(deviceId: await fnGetDeviceId());
    List<SettingsList> settingsLists = [];

    if (selTableClass != null) {
      settingsLists.add(SettingsList(
        identifierKey: "SETT_TAB_AREA",
        identifierValue: selTableClass?.className,
      ));
    }
    if (selKOTVoucher != null) {
      var settings = SettingsList(
        identifierKey: "SETT_TAB_KOT_LID",
        identifierValue: selKOTVoucher?.ledId.toString(),
      );
      settingsLists.add(settings);
    }
    if (selTAVoucher != null) {
      settingsLists.add(SettingsList(
        identifierKey: "SETT_TAB_TA_LID",
        identifierValue: selTAVoucher?.ledId.toString(),
      ));
    }
    if (selFirstprint != null) {
      settingsLists.add(SettingsList(
        identifierValue: selFirstprint?.printAreaName,
        identifierKey: "SETT_TAB_PA1",
      ));
    }
    if (selSecondprint != null) {
      settingsLists.add(SettingsList(
        identifierValue: selSecondprint?.printAreaName,
        identifierKey: "SETT_TAB_PA2",
      ));
    }
    if (selThirdprint != null) {
      settingsLists.add(SettingsList(
        identifierValue: selThirdprint?.printAreaName,
        identifierKey: "SETT_TAB_PA3",
      ));
    }
    if (selFourthprint != null) {
      settingsLists.add(SettingsList(
        identifierValue: selFourthprint?.printAreaName,
        identifierKey: "SETT_TAB_PA4",
      ));
    }
    if (selFifthprint != null) {
      settingsLists.add(SettingsList(
        identifierValue: selFifthprint?.printAreaName,
        identifierKey: "SETT_TAB_PA5",
      ));
    }
    settingsLists.add(SettingsList(
      identifierValue: ipController1.text,
      identifierKey: "SETT_TAB_IP1",
    ));
    settingsLists.add(SettingsList(
      identifierValue: ipController2.text,
      identifierKey: "SETT_TAB_IP2",
    ));
    settingsLists.add(SettingsList(
      identifierValue: ipController3.text,
      identifierKey: "SETT_TAB_IP3",
    ));
    settingsLists.add(SettingsList(
      identifierValue: ipController4.text,
      identifierKey: "SETT_TAB_IP4",
    ));
    settingsLists.add(SettingsList(
      identifierValue: ipController5.text,
      identifierKey: "SETT_TAB_IP5",
    ));

    settingsSave.settingsList = settingsLists;

    var settingsSaveJson = settingsSave.toJson();
    print("Settings List Save JSON: $settingsSaveJson");

    var jsonData = jsonEncode({
      "DevideInfo": settingsSave.devideInfo?.toJson(),
      "Settings": settingsSave.settingsList
    });

    final String? baseUrl = await fnGetBaseUrl();
    final String apiUrl = '${baseUrl}api/Settings/save';
    print("Complete JSON Payloadddddd: $jsonData");

    final response = await http.post(
      Uri.parse(apiUrl),
      body: (jsonData),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      print("API response:   $responseData");
    } else {
      print(
          "Error: API request failed with status code    ${response.statusCode}");
      print("Error response:   ${response.body}");
    }
  }

  Future<void> LoadSettings() async {
    await fetchData();

    if (savedsettings.isNotEmpty) {
      if (tableClass != null && tableClass!.isNotEmpty) {
        SavedSettings? selTableClassSettings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_AREA",
          orElse: () => SavedSettings(),
        );
        selTableClass = tableClass!.firstWhere(
          (element) =>
              element.className == selTableClassSettings.identifierValue,
          orElse: () => tableClass!.first,
        );
      }
      if (kotVoucher != null && kotVoucher!.isNotEmpty) {
        SavedSettings? selkotVoucherSettings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_KOT_LID",
          orElse: () => SavedSettings(),
        );
        selKOTVoucher = kotVoucher!.firstWhere(
          (element) => element.ledId == selkotVoucherSettings.identifierValue,
          orElse: () => kotVoucher!.first,
        );
      }
      if (taVoucher != null && taVoucher!.isNotEmpty) {
        SavedSettings? seltaVoucherSettings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_TA_LID",
          orElse: () => SavedSettings(),
        );
        selTAVoucher = taVoucher!.firstWhere(
          (element) => element.ledId == seltaVoucherSettings.identifierValue,
          orElse: () => taVoucher!.first,
        );
      }

      if (printArea != null && printArea!.isNotEmpty) {
        SavedSettings? selFirstPrintSettings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_PA1",
          orElse: () => SavedSettings(),
        );

        selFirstprint = printArea!.firstWhere(
          (element) =>
              element.printAreaName == selFirstPrintSettings.identifierValue,
          orElse: () => printArea!.first,
        );
      }
      if (printArea != null && printArea!.isNotEmpty) {
        SavedSettings? selSecondPrintSettings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_PA2",
          orElse: () => SavedSettings(),
        );

        selSecondprint = printArea!.firstWhere(
          (element) =>
              element.printAreaName == selSecondPrintSettings.identifierValue,
          orElse: () => printArea!.first,
        );
      }
      if (printArea != null && printArea!.isNotEmpty) {
        SavedSettings? selThirdPrintSettings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_PA3",
          orElse: () => SavedSettings(),
        );

        selThirdprint = printArea!.firstWhere(
          (element) =>
              element.printAreaName == selThirdPrintSettings.identifierValue,
          orElse: () => printArea!.first,
        );
      }
      if (printArea != null && printArea!.isNotEmpty) {
        SavedSettings? selFourthSettings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_PA4",
          orElse: () => SavedSettings(),
        );

        selFourthprint = printArea!.firstWhere(
          (element) =>
              element.printAreaName == selFourthSettings.identifierValue,
          orElse: () => printArea!.first,
        );
      }
      if (printArea != null && printArea!.isNotEmpty) {
        SavedSettings? selFifthPrintSettings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_PA5",
          orElse: () => SavedSettings(),
        );

        selFifthprint = printArea!.firstWhere(
          (element) =>
              element.printAreaName == selFifthPrintSettings.identifierValue,
          orElse: () => printArea!.first,
        );
      }
      SavedSettings? ipController1Settings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_IP1",
          orElse: () => SavedSettings());
      SavedSettings? ipController2Settings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_IP2",
          orElse: () => SavedSettings());
      SavedSettings? ipController3Settings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_IP3",
          orElse: () => SavedSettings());
      SavedSettings? ipController4Settings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_IP4",
          orElse: () => SavedSettings());
      SavedSettings? ipController5Settings = savedsettings.firstWhere(
          (element) => element.identifierKey == "SETT_TAB_IP5",
          orElse: () => SavedSettings());

      setState(() {
        ipController1.text = ipController1Settings.identifierValue ?? "";
        ipController2.text = ipController2Settings.identifierValue ?? "";
        ipController3.text = ipController3Settings.identifierValue ?? "";
        ipController4.text = ipController4Settings.identifierValue ?? "";
        ipController5.text = ipController5Settings.identifierValue ?? "";
      });
    }
  }

  Future<void> fetchData() async {
    DeviceId = await fnGetDeviceId();
    final String? baseUrl = await fnGetBaseUrl();
    String apiUrl = '${baseUrl}api/Settings/data';

    try {
      apiUrl = '$apiUrl?DeviceId=$DeviceId';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        Settings settings = Settings.fromJson(json.decode(response.body));

        sqlMessage = settings.data?.sQLMessage;

        if (sqlMessage?.code == "200") {
          setState(() {
            tableClass = settings.data?.tableClass;
            kotVoucher = settings.data?.kOTVoucher;
            taVoucher = settings.data?.tAVoucher;
            printArea = settings.data?.printArea;
            savedsettings = settings.data!.savedSettings!;
            // Set initial values for dropdowns based on fetched data
            if (tableClass != null && tableClass!.isNotEmpty) {
              selTableClass = tableClass!.first;
            }
            if (kotVoucher != null && kotVoucher!.isNotEmpty) {
              selKOTVoucher = kotVoucher!.first;
            }
            if (taVoucher != null && taVoucher!.isNotEmpty) {
              selTAVoucher = taVoucher!.first;
            }
            if (printArea != null && printArea!.isNotEmpty) {
              selFirstprint = printArea!.first;
              selSecondprint = printArea!.first;
              selThirdprint = printArea!.first;
              selFourthprint = printArea!.first;
              selFifthprint = printArea!.first;
            }
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 50, bottom: 10, left: 10, right: 10),
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Column(
                              children: [
                                Text(
                                  "Table Class",
                                  style: TextStyle(fontSize: 17),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "   KOT Voucher",
                                  style: TextStyle(fontSize: 17),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "  T A Voucher",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 36,
                            ),
                            Column(
                              children: [
                                DropdownButton<TableClass>(
                                  value: selTableClass,
                                  onChanged: (TableClass? newArea) {
                                    setState(() {
                                      selTableClass = newArea;
                                    });
                                  },
                                  items: tableClass
                                      ?.map<DropdownMenuItem<TableClass>>(
                                          (TableClass tableArea) {
                                    return DropdownMenuItem<TableClass>(
                                      value: tableArea,
                                      child:
                                          Text(tableArea.className.toString()),
                                    );
                                  }).toList(),
                                ),
                                DropdownButton<KOTVoucher>(
                                  value: selKOTVoucher,
                                  onChanged: (KOTVoucher? newArea) {
                                    setState(() {
                                      selKOTVoucher = newArea;
                                    });
                                  },
                                  items: kotVoucher
                                      ?.map<DropdownMenuItem<KOTVoucher>>(
                                          (KOTVoucher kotArea) {
                                    return DropdownMenuItem<KOTVoucher>(
                                      value: kotArea,
                                      child:
                                          Text(kotArea.ledgerName.toString()),
                                    );
                                  }).toList(),
                                ),
                                DropdownButton<TAVoucher>(
                                  value: selTAVoucher,
                                  onChanged: (TAVoucher? newArea) {
                                    setState(() {
                                      selTAVoucher = newArea;
                                    });
                                  },
                                  items: taVoucher
                                      ?.map<DropdownMenuItem<TAVoucher>>(
                                          (TAVoucher tavArea) {
                                    return DropdownMenuItem<TAVoucher>(
                                      value: tavArea,
                                      child:
                                          Text(tavArea.ledgerName.toString()),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:0,right:250),
              child: Text(
                "Print Settings",
                style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text("Print  Area",
                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                          const SizedBox(
                              height: 20),
                          SizedBox(width: 20),
                          DropdownButton<PrintArea>(
                            value: selFirstprint,
                            onChanged: (PrintArea? newArea) {
                              setState(() {
                                selFirstprint = newArea;
                              });
                            },
                            items: printArea
                                ?.map<DropdownMenuItem<PrintArea>>(
                                    (PrintArea tavArea) {
                              return DropdownMenuItem<PrintArea>(
                                value: tavArea,
                                child:
                                    Text(tavArea.printAreaName.toString()),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(width: 20,),
                          DropdownButton<PrintArea>(
                            value: selSecondprint,
                            onChanged: (PrintArea? newArea) {
                              setState(() {
                                selSecondprint = newArea;
                              });
                            },
                            items: printArea
                                ?.map<DropdownMenuItem<PrintArea>>(
                                    (PrintArea tavArea) {
                              return DropdownMenuItem<PrintArea>(
                                value: tavArea,
                                child: Text(tavArea.printAreaName.toString()),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButton<PrintArea>(
                            value: selThirdprint,
                            onChanged: (PrintArea? newArea) {
                              setState(() {
                                selThirdprint = newArea;
                              });
                            },
                            items: printArea
                                ?.map<DropdownMenuItem<PrintArea>>(
                                    (PrintArea tavArea) {
                              return DropdownMenuItem<PrintArea>(
                                value: tavArea,
                                child: Text(tavArea.printAreaName.toString()),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButton<PrintArea>(
                            value: selFourthprint,
                            onChanged: (PrintArea? newArea) {
                              setState(() {
                                selFourthprint = newArea;
                              });
                            },
                            items: printArea
                                ?.map<DropdownMenuItem<PrintArea>>(
                                    (PrintArea tavArea) {
                              return DropdownMenuItem<PrintArea>(
                                value: tavArea,
                                child: Text(tavArea.printAreaName.toString()),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButton<PrintArea>(
                            value: selFifthprint,
                            onChanged: (PrintArea? newArea) {
                              setState(() {
                                selFifthprint = newArea;
                              });
                            },
                            items: printArea
                                ?.map<DropdownMenuItem<PrintArea>>(
                                    (PrintArea tavArea) {
                              return DropdownMenuItem<PrintArea>(
                                value: tavArea,
                                child: Text(tavArea.printAreaName.toString()),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 60,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 70,top: 15),
                            child: const Text("Print  IP",
                                style: TextStyle(fontSize: 21,fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: Center(
                                    child: TextField(
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true, signed: false),
                                      textAlignVertical: TextAlignVertical.center,
                                      controller: ipController1,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              20.0), // Adjust the value as needed
                                        ),
                                      ),
                                    ),
                                  )),
                               SizedBox(width: 20,),
                              IconButton(
                                iconSize: 30,
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    selFirstprint = null;
                                    ipController1.clear();
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),
                          Row(
                            children: [
                              SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: TextField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true, signed: false),
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: ipController2,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Adjust the value as needed
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 20,),
                              IconButton(
                                iconSize: 30,
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    selSecondprint = null;
                                    ipController2.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: TextField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true, signed: false),
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: ipController3,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Adjust the value as needed
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 20,),
                              IconButton(
                                iconSize: 30,
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    selThirdprint = null;
                                    ipController3.clear();
                                  });
                                },
                              ),
                            ],

                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: TextField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true, signed: false),
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: ipController4,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Adjust the value as needed
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 20,),
                              IconButton(
                                iconSize: 30,
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    selFourthprint = null;
                                    ipController4.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: TextField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true, signed: false),
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: ipController5,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Adjust the value as needed
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 20,),
                              IconButton(
                                iconSize: 30,
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    selFifthprint = null;
                                    ipController5.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(right: 180.0),
                    child: ElevatedButton(
                      onPressed: () {
                        SaveSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 70, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              3.0),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
