// GestureDetector(
// onTap: isPrintingUI
// ? null
//     : () async {
// debugPrint("🟢 KOT BUTTON CLICKED");
//
// setState(() => isPrintingUI = true);
//
// try {
// final kotProvider =
// Provider.of<KotProvider>(context, listen: false);
//
// /// 1️⃣ FETCH VOUCHER
// await kotProvider.fetchingvoucherID(selectedSeats);
// final voucher = kotProvider.voucher;
//
// if (voucher == null || voucher.isEmpty) {
// debugPrint("❌ VOUCHER EMPTY");
// return;
// }
//
// final ledId = voucher.first.ledId.toString();
//
// /// 2️⃣ PREPARE KOT DATA
// final kotDataToSend =
// kotProvider.SendingKotToDb(selectedSeats, ledId);
//
// if (kotDataToSend == null) {
// debugPrint("❌ KOT DATA NULL");
// return;
// }
//
// final baseUrl = await fnGetBaseUrl();
//
// /// 3️⃣ SAVE KOT
// final saveResponse = await http.post(
// Uri.parse(
// '$baseUrl/api/Dinein/saveKOT?DeviceId=${kotProvider.deviceId}'),
// headers: {'Content-Type': 'application/json'},
// body: jsonEncode(kotDataToSend.toJson()),
// );
//
// if (saveResponse.statusCode != 200) {
// debugPrint("❌ saveKOT FAILED");
// return;
// }
//
// final saveJson = jsonDecode(saveResponse.body);
// final savedKotJson = saveJson['Data']?['SavedKot'];
//
// if (savedKotJson == null) {
// debugPrint("❌ SavedKot missing");
// return;
// }
//
// final receivedKOT = KotData.fromJson(savedKotJson);
//
// /// 🔒 HARD PRINT LOCK (MOST IMPORTANT PART)
// if (PrintGuard.isPrinting) {
// debugPrint("🚫 PRINT BLOCKED: already printing");
// return;
// }
//
// if (PrintGuard.lastKotNo == receivedKOT.vno.toString()) {
// debugPrint("🚫 DUPLICATE KOT PRINT BLOCKED");
// return;
// }
//
// PrintGuard.isPrinting = true;
// PrintGuard.lastKotNo = receivedKOT.vno.toString();
//
// /// 4️⃣ PREPARE PRINT DATA
// final rawPrintAreas =
// await kotProvider.fetchDataPrint();
//
// /// 🔐 ENSURE SINGLE PRINTER (NO DUPLICATE IP)
// final Map<String, PrintAreas> uniquePrinters = {};
// for (var area in rawPrintAreas) {
// uniquePrinters[area.iPAddress!] = area;
// }
//
// final printAreas = uniquePrinters.values.toList();
//
// final selectedItemsOld =
// kotProvider.selectedItemsOld;
//
// final List<PrintItems> printItems =
// selectedItemsOld.map((i) {
// return PrintItems(
// itemModifiedStatus: i.itemModifiedStatus,
// name: i.name,
// OldQty: i.oldQuandity?.toString() ?? "0",
// qty: i.quantity.toString(),
// sRate: i.sRate.toInt(),
// printer: i.printer,
// itemId: i.itemId,
// extraNote: i.extraNote,
// addonItems: [],
// );
// }).toList();
//
// final kotPrint = KotPrint(
// mode: receivedKOT.mode,
// extraNote: receivedKOT.extraNote,
// kOTNo: receivedKOT.vno.toString(),
// orderDate: '',
// printType: 'KOT_VOUCHER',
// staff: kotProvider.employeeId.toString(),
// tableArea: '',
// tableName: receivedKOT.tableId.toString(),
// tableSeat: receivedKOT.tableSeat,
// printAreas: printAreas,
// printItems: printItems,
// );
//
// /// 5️⃣ CALL PRINT API (ONLY ONCE)
// debugPrint(
// "🟠 CALLING PRINT API FOR KOT: ${receivedKOT.vno}");
//
// final printResponse = await http.post(
// Uri.parse('$baseUrl/api/Dinein/kotPrint'),
// headers: {'Content-Type': 'application/json'},
// body: jsonEncode(kotPrint.toJson()),
// );
//
// if (printResponse.statusCode != 200) {
// debugPrint("❌ PRINT FAILED");
// return;
// }
//
// debugPrint("✅ PRINT DONE");
//
// /// 6️⃣ CLEAR UI + PROVIDER
// setState(() {
// noteController.clear();
// selectedSeats.clear();
// selectedItemsList.clear();
// });
//
// kotProvider.clearAll();
// } catch (e) {
// debugPrint("❌ PRINT ERROR: $e");
// } finally {
// /// 🔓 RELEASE PRINT LOCK
// PrintGuard.isPrinting = false;
// setState(() => isPrintingUI = false);
// }
// },
// child: Card(
// color: isPrintingUI ? Colors.grey : Colors.black87,
// child: const Padding(
// padding: EdgeInsets.all(10),
// child: Text(
// "   KOT   ",
// style: TextStyle(
// color: Colors.white,
// fontWeight: FontWeight.bold,
// ),
// ),
// ),
// ),
// ),