// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import '../Models/KOT.dart';
// import '../Models/Provider/Sending KOT.dart';
// import '../Models/Reorder.dart';
// import '../Utils/GlobalFn.dart';
//
// Future<KotData?> _saveKotOnly(
//     KotProvider kotProvider,
//     Map<String, Set<String>> localSeats,
//     List<SelectedItems> selectedItemsListKot,
//     String localNote,
//     ) async {
//
//   try {
//
//     if (selectedItemsListKot.isEmpty) {
//       debugPrint("❌ NO ITEMS FOR KOT SAVE");
//       return null;
//     }
//
//     await kotProvider.fetchingvoucherID(localSeats);
//
//     final voucher = kotProvider.voucher;
//     if (voucher == null || voucher.isEmpty) {
//       debugPrint("❌ VOUCHER EMPTY");
//       return null;
//     }
//
//     final ledId = voucher.first.ledId.toString();
//
//     /// 🔥 CREATE KOT OBJECT USING KOT LIST
//     final kotDataToSend = kotProvider.SendingKotToDb(
//       localSeats,
//       ledId,
//       selectedItemsListKot,   // ✅ ONLY KOT LIST
//       localNote,
//     );
//
//     if (kotDataToSend == null) return null;
//
//     final baseUrl = await fnGetBaseUrl();
//
//     final saveResponse = await http.post(
//       Uri.parse('$baseUrl/api/Dinein/saveKOT?DeviceId=${kotProvider.deviceId}'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(kotDataToSend.toJson()),
//     );
//
//     if (saveResponse.statusCode != 200) {
//       debugPrint("❌ SAVE KOT FAILED");
//       return null;
//     }
//
//     final saveJson = jsonDecode(saveResponse.body);
//     final savedKotJson = saveJson['Data']?['SavedKot'];
//
//     if (savedKotJson == null) {
//       debugPrint("❌ SAVED KOT NULL");
//       return null;
//     }
//
//     final receivedKOT = KotData.fromJson(savedKotJson);
//
//     /// ✅ RESET OLD QTY AFTER SAVE
//     for (var item in selectedItemsListKot) {
//       item.oldQuandity = item.quantity;
//       item.itemModifiedStatus = "";
//     }
//
//     debugPrint("✅ KOT SAVED SUCCESSFULLY");
//
//     return receivedKOT;
//
//   } catch (e) {
//     debugPrint("❌ SAVE ERROR: $e");
//     return null;
//   }
// }