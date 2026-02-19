import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:RestroApp/Models/Dinning.dart';
import 'package:http/http.dart' as http;
import '../../Utils/GlobalFn.dart';
import '../Models/KOT.dart';
import '../Models/Provider/Sending KOT.dart';
import '../Models/Reorder.dart';
import '../Models/printer.dart';
import '../Pages/homepage.dart';


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
      localItems,
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

    for (var i in localItems) {
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
        extraNote: receivedKOT.extraNote,
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
