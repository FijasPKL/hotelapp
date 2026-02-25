import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../KOT.dart';

class SelectedItemsProvider with ChangeNotifier {
  final List<SelectedItems> selectedItemsListee = [];
  List<KOT> kotItemLissss = [];
  List<SelectedItems> get selectedItemsList => selectedItemsListee;
  List<SelectExtra> selectedExtras = [];
  int _sinoCounter = 1;
  String? selectedTableName;
  String? selectedChairIdListDB;
  Map<String, Set<String>> selectedSeats = {};
  List<KOT> kotItemList = [];
  List<SelectedItems> kotItemLists = [];
  KOT? kotData;
  List<KOT> selectedKOTListee = [];
  String _issuecodeFromDB = "";
  String get issuecodeFromDB => _issuecodeFromDB;

  String get DisplayTbSc {
    return selectedSeats.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => '${entry.key}: ${entry.value.join(", ")}')
        .join(", ");
  }

  void updateSelectExtras(List<SelectExtra> updatedExtras) {
    selectedExtras = updatedExtras;
    notifyListeners();
  }


  void updateKotData(KOT kotData) {
    // Update KotData with the provided kotData
    this.kotData = kotData;
    print("ggggg$kotData");
    notifyListeners();
  }

  void Runningsitems(List<KOT> items) {
    kotItemLissss = items;
  }

  //Issuecode Updating Section From Database to Listview Homepage
  void RunningIssueCode(String issueCode) {
    _issuecodeFromDB = issueCode;
    print("issuecodeFromDB $_issuecodeFromDB");
    notifyListeners();
  }

  //Table and seats updating section from Database to Listview Homepage
  void RunningTabTbCh(String tableName, String chairIdList) {
    selectedTableName = tableName;
    selectedChairIdListDB = chairIdList;
    notifyListeners();
  }
  void UpdateselectedSeatIntoRunningTabTbCh() {
    if (selectedTableName != null && selectedChairIdListDB != null) {
      // Clear existing selectedSeats and add the new entry
      selectedSeats.clear();
      selectedSeats[selectedTableName!] = {selectedChairIdListDB!};
      notifyListeners();
    }
  }



  // updateKOTFromDb() {
  //   if (kotItemList.isNotEmpty) {
  //     kotItemLissss.clear();
  //     for (KotData kotData in kotItemList) {
  //       List<SelectedItems> selectedItemsList = [];
  //       for (KotItem kotItem in kotData.kotItems) {
  //         List<SelectExtra> mappedAddonItems = [];
  //         for (AddonItem addon in kotItem.addonItems) {
  //           SelectExtra mappedAddon = SelectExtra(
  //             parentItemId: addon.parentItemId,
  //             itemId: addon.itemId,
  //             itemName: addon.name,
  //             sRate: addon.sRate,
  //             printer: '',
  //             qty: addon.quantity.toInt(), // Convert quantity to int
  //             NetAmount: addon.NetAmount ?? 0.0,
  //           );
  //           mappedAddonItems.add(mappedAddon);
  //         }
  //         // Create a SelectedItems instance and include mapped addon items
  //         SelectedItems selectedItem = SelectedItems(
  //             name: kotItem.name,
  //             sRate: kotItem.sRate,
  //             quantity: kotItem.quantity.toInt(), // Convert quantity to int
  //             extraNote: '',
  //             SINO: kotItem.slNo.toString(),
  //             itemId: kotItem.itemId,
  //             NetAmount: kotItem.NetAmount ?? 0.0,
  //             printer: '',
  //             itemtotal: 0.0,
  //             selectextra: mappedAddonItems,
  //             extraddon: []);
  //         selectedItemsList.add(selectedItem);
  //       }
  //       KOT kotdatas = KOT(
  //         Mode: kotData.mode,
  //         IssueCode: kotData.issueCode.toString(),
  //         LedCode: kotData.ledCode.toString(),
  //         Vno: kotData.vno.toString(),
  //         TableId: kotData.tableId.toString(),
  //         TableSeat: kotData.tableSeat,
  //         EmployeeId: kotData.employeeId.toString(),
  //         TotalAmount: kotData.totalAmount,
  //         ExtraNote: kotData.extraNote ?? '',
  //         Vtype: kotData.vType ?? '',
  //         deviceId: kotData.deviceId ?? '',
  //         Kotitems: selectedItemsList,
  //       );
  //       kotItemLissss.add(kotdatas);
  //     }
  //     notifyListeners();
  //     print("KOTTTTTTTT$kotItemLissss");
  //     // UpdateselectedItemsRtoS();
  //   }
  // }

  void updateSelectedSeatsMap(Map<String, Set<String>> newSeatsMap) {
    selectedSeats = newSeatsMap;
    print("selecteddddddddd$selectedSeats");
    notifyListeners();
  }

//normal items using provider
  void addItemIntoSListee(SelectedItems newItem) {
    newItem.SINO = (++_sinoCounter).toString(); // Assign new SINO number
    selectedItemsListee.add(newItem);
    updateSinoNumbers();
    print("kkkkkkkkkkkkkkk$selectedItemsListee");
  }

  void addKOTIntoSListee(KOT newKOT) {
    selectedKOTListee.add(newKOT);
    updateSinoNumbers();
    print("kkkkkkkkkkkkkkk$selectedKOTListee");
  }

  void removeSelectedItem(String nameToRemove) {
    selectedItemsListee.removeWhere((item) => item.name == nameToRemove);
    updateSinoNumbers(); // Update SINO numbers after removing item
    notifyListeners();
  }

  void clearSelectedItemsclear() {
    selectedItemsListee.clear();
    selectedExtras.clear();
    selectedSeats.clear();
    notifyListeners();
    _issuecodeFromDB = '';
  }


  void addSelectExtraList(SelectExtra extra) {
    selectedExtras.add(extra);
    notifyListeners();
  }

//Removing the selected Extra from the diologe
  void removeSelectExtra(SelectExtra selectedAddon) {
    selectedExtras.remove(selectedAddon);
    notifyListeners();
  }

//Updating the SerialNumber of items
  void updateSinoNumbers() {
    for (int i = 0; i < selectedItemsListee.length; i++) {
      selectedItemsListee[i].SINO = (i + 1).toString();
    }
    notifyListeners();
  }
// void addSelectExtra(SelectExtra extra) {
//   selectedExtras.add(extra);
//   print("etraaaaaaaa$selectedExtras");
//   notifyListeners();
// }
}
