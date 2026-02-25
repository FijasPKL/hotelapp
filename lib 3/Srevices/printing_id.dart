// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import '../Models/KOT.dart';
// import '../Models/Provider/Sending KOT.dart';
// import '../Models/Reorder.dart';
// import '../Models/printer.dart';
// import '../Pages/homepage.dart';
// import '../Utils/GlobalFn.dart';
//
// Future<void> _printKotOnly(
//     KotProvider kotProvider,
//     KotData receivedKOT,
//     List<SelectedItems> selectedItemsOldPrintList,
//     ) async {
//
//   try {
//
//     if (PrintGuard.isPrinting) {
//       debugPrint("🚫 PRINT BLOCKED");
//       return;
//     }
//
//     PrintGuard.isPrinting = true;
//
//     final baseUrl = await fnGetBaseUrl();
//
//     /// 🖨 FETCH PRINTER AREAS
//     List<PrintAreas> apiPrintAreas = await kotProvider.fetchDataPrint();
//
//     Map<String, PrintAreas> uniquePrinterMap = {};
//
//     for (var p in apiPrintAreas) {
//       String name = p.printAreaName?.trim() ?? "";
//       String ip = p.iPAddress?.trim() ?? "";
//
//       if (ip.isEmpty) continue;
//       uniquePrinterMap[name] = p;
//     }
//
//     List<PrintAreas> printAreas = uniquePrinterMap.values.toList();
//     List<PrintItems> printItems = [];
//
//     /// 🔥 BUILD PRINT ITEMS USING PRINT LIST ONLY
//     for (var i in selectedItemsOldPrintList) {
//
//       int oldQty = i.oldQuandity ?? 0;
//       int newQty = i.quantity;
//       String status = i.itemModifiedStatus?.trim() ?? "";
//
//       List<AddonItems> addonPrint = buildAddonPrint(i.selectextra);
//
//       if (status == "FRESH" ||
//           status == "NEW ORDER" ||
//           newQty > oldQty) {
//
//         int qtyToPrint = (newQty > oldQty)
//             ? newQty - oldQty
//             : newQty;
//
//         printItems.add(PrintItems(
//           itemId: i.itemId,
//           name: i.name,
//           sRate: i.sRate.toInt(),
//           printer: i.printer,
//           qty: qtyToPrint.toString(),
//           OldQty: oldQty.toString(),
//           itemModifiedStatus: "NEW ORDER",
//           extraNote: i.extraNote,
//           addonItems: addonPrint,
//         ));
//       }
//
//       else if (status == "REMOVED" || newQty < oldQty) {
//
//         int qtyToPrint = (newQty < oldQty)
//             ? oldQty - newQty
//             : oldQty;
//
//         printItems.add(PrintItems(
//           itemId: i.itemId,
//           name: i.name,
//           sRate: i.sRate.toInt(),
//           printer: i.printer,
//           qty: qtyToPrint.toString(),
//           OldQty: oldQty.toString(),
//           itemModifiedStatus: "REMOVED",
//           extraNote: i.extraNote,
//           addonItems: addonPrint,
//         ));
//       }
//     }
//
//     if (printItems.isEmpty) {
//       debugPrint("🚫 NOTHING TO PRINT");
//       return;
//     }
//
//     /// 🔥 GROUP BY PRINTER
//     Map<String, List<PrintItems>> printerWise = {};
//
//     for (var item in printItems) {
//       String printer = item.printer?.trim() ?? "";
//       if (printer.isEmpty) continue;
//
//       printerWise.putIfAbsent(printer, () => []);
//       printerWise[printer]!.add(item);
//     }
//
//     /// 🖨 PRINT EACH PRINTER
//     for (var area in printAreas) {
//
//       String areaName = area.printAreaName?.trim() ?? "";
//       List<PrintItems> itemsForPrinter = printerWise[areaName] ?? [];
//
//       if (itemsForPrinter.isEmpty) continue;
//
//       final singlePrint = KotPrint(
//         mode: receivedKOT.mode,
//         extraNote: receivedKOT.extraNote,
//         kOTNo: receivedKOT.vno.toString(),
//         orderDate: '',
//         printType: 'KOT_VOUCHER',
//         staff: kotProvider.employeeId.toString(),
//         tableArea: '',
//         tableName: receivedKOT.tableId.toString(),
//         tableSeat: receivedKOT.tableSeat,
//         printAreas: [area],
//         printItems: itemsForPrinter,
//       );
//
//       final printResponse = await http.post(
//         Uri.parse('$baseUrl/api/Dinein/kotPrint'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(singlePrint.toJson()),
//       );
//
//       if (printResponse.statusCode == 200) {
//         debugPrint("✅ PRINT SUCCESS → $areaName");
//       } else {
//         debugPrint("❌ PRINT FAILED → $areaName");
//       }
//     }
//
//     /// ✅ RESET PRINT LIST AFTER PRINT
//     for (var item in selectedItemsOldPrintList) {
//       item.oldQuandity = item.quantity;
//       item.itemModifiedStatus = "";
//     }
//
//   } catch (e) {
//     debugPrint("❌ PRINT ERROR: $e");
//   } finally {
//     PrintGuard.isPrinting = false;
//   }
// }
//
// KOT SendingKotToDb(Map<String, Set<String>> selectedSeatsMap, String? ledId) {
//   double totalAmount = OverallTotal(selectedItemsListee);
//   Object employeeIdString = (kotDatasrunning.isNotEmpty) ? kotDatasrunning[0]
//       .employeeId : employeeId.toString();
//   String mode = (kotDatasrunning.isNotEmpty) ? kotDatasrunning[0].mode : 'I';
//   Object tableId = (kotDatasrunning.isNotEmpty)
//       ? kotDatasrunning[0].tableId
//       : selectedSeatsMap.keys
//       .where((key) => key.startsWith(RegExp(r'[0-9]')))
//       .map((key) => key.replaceAll('-', ''))
//       .firstWhere((element) => true, orElse: () => '');
//   String seats = (kotDatasrunning.isNotEmpty)
//       ? kotDatasrunning[0].tableSeat
//       : selectedSeatsMap.values
//       .where((seats) => seats.isNotEmpty)
//       .map((seats) => seats.join(""))
//       .join(', ');
//   Object Issuecode = (kotDatasrunning.isNotEmpty) ? kotDatasrunning[0]
//       .issueCode : '-1';
//   Object Vno = (kotDatasrunning.isNotEmpty) ? kotDatasrunning[0].vno : '-1';
//   String Text = (kotDatasrunning.isNotEmpty)
//       ? kotDatasrunning[0].extraNote
//       : noteController.text;
//   KOT kotDataFromSelected = KOT(
//     Mode: mode,
//     IssueCode: Issuecode.toString(),
//     LedCode: ledId ?? '',
//     Vtype: 'KOT',
//     EmployeeId: employeeIdString.toString(),
//     ExtraNote: Text,
//     TableId: tableId.toString(),
//     TableSeat: seats,
//     TotalAmount: totalAmount,
//     deviceId: deviceId,
//     Vno: Vno.toString(),
//     Kotitems: selectedItemsListee,
//   );
//   print("kotDataFromSelected: $kotDataFromSelected");
//   notifyListeners();
//   return kotDataFromSelected;
// }
