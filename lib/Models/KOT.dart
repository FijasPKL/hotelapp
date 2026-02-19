import 'dart:convert';

import 'Dinning.dart';


class KOT {
  String deviceId;
  String Mode;
  String IssueCode;
  String Vno;
  String LedCode;
  String Vtype;
  String TableId;
  String TableSeat;
  String EmployeeId;
  double TotalAmount;
  String ExtraNote;
  List<SelectedItems>? Kotitems;

  KOT({
    required this.Mode,
    required this.IssueCode,
    required this.LedCode,
    required this.Vtype,
    required this.EmployeeId,
    required this.ExtraNote,
    required this.TableId,
    required this.TableSeat,
    required this.TotalAmount,
    required this.deviceId,
    required this.Vno,
    this.Kotitems,
  });

  Map<String, dynamic> toJson() {
    return {
      'DeviceId': deviceId,
      'Mode': Mode,
      'IssueCode': IssueCode,
      'Vno': Vno,
      'LedCode': LedCode,
      'VType': Vtype,
      'TableId': TableId,
      'TableSeat': TableSeat,
      'EmployeeId': EmployeeId,
      'TotalAmount':
          TotalAmount.toString(), // Convert double to string directly
      'ExtraNote': ExtraNote,
      'KotItems': Kotitems?.map((item) => item.toJson()).toList(),
    };
  }

  factory KOT.fromJson(Map<String, dynamic> json) {
    var kotList = json['Kot'] as List<dynamic>?;

    return KOT(
      TotalAmount: double.parse(json['TotalAmount'] ?? "0"),
      TableSeat: json['TableSeat'] ?? "",
      TableId: json['TableId'] ?? "1",
      Vno: json['Vno'] ?? "",
      ExtraNote: json['ExtraNote'] ?? "",
      EmployeeId: json['EmployeeId'] ?? "",
      IssueCode: json['IssueCode'] ?? "",
      LedCode: json['LedCode'] ?? "",
      deviceId: json['DeviceId'] ?? "",
      Mode: json['Mode'] ?? "",
      Vtype: json['VType'] ?? "",
      Kotitems: kotList != null
          ? kotList.map((v) => SelectedItems.fromJson(v)).toList()
          : null,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class SelectedItems {
  String SINO;
  String name;
  double sRate;
  int quantity;
  int? oldQuandity;
  String? ItemStatus;
  int itemId;
  double itemtotal;
  double NetAmount;
  String extraNote;
  String printer;
  String? itemModifiedStatus;
  List<SelectExtra>? selectextra;

  SelectedItems({
    required this.name,
    required this.sRate,
    required this.quantity,
    required this.oldQuandity,
    required this.extraNote,
    required this.SINO,
    required this.NetAmount,
    required this.itemtotal,
    required int itemId,
    required this.printer,
    required this.itemModifiedStatus,
    required this.ItemStatus,
    this.selectextra,
  }) : itemId = itemId;

  Map<String, dynamic> toJson() {
    return {
      'SINO': SINO.toString(),
      'ItemId': itemId.toString(),
      'Name': name,
      'SRate': sRate.toString(),
      'Printer': printer,
      'Qty': quantity.toString(),
      'OldQty': oldQuandity.toString(),
      'ItemStatus':ItemStatus,
      'Notes': extraNote,
      'NetAmount': NetAmount,
      'ItemModifiedStatus': itemModifiedStatus,
      'AddonItems': selectextra != null
          ? selectextra!.map((extra) => extra.toJson()).toList()
          : [], // Ensure it's an empty array if selectextra is null
    };
  }

  factory SelectedItems.fromJson(Map<String, dynamic> json) {
    var selectextraList = json['AddonItems'] as List<dynamic>?;
    return SelectedItems(
      SINO: json['SINO'] ?? "",
      name: json['Name'] ?? "",
      sRate: double.parse(json['SRate'] ?? "0"),
      printer: json['Printer'] ?? "",
      quantity: int.parse(json['Qty'] ?? "1"),
      oldQuandity: int.parse(json['OldQty'] ?? "0"),
      itemId: json['ItemId'] ?? "",
      extraNote: json['Notes'] ?? "",
      NetAmount: double.parse(json['NetAmount'].toString()),
      itemtotal: double.parse(json['ItemTotal'] ?? "0"),
      ItemStatus: json['ItemStatus']??"",
      itemModifiedStatus: json['ItemModifiedStatus'] ?? "",
      selectextra: selectextraList != null
          ? selectextraList.map((v) => SelectExtra.fromJson(v)).toList()
          : null,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class SelectExtra {
  int parentItemId;
  int itemId;
  String itemName;
  int? qty;
  double sRate;
  String? AddonModifiedStatus;
  double NetAmount;
  String printer;

  SelectExtra({
    required this.parentItemId,
    required this.itemId,
    required this.itemName,
    this.qty,
    required this.sRate,
    required this.AddonModifiedStatus,
    required this.printer,
    required this.NetAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'ParentItemId': parentItemId.toString(),
      'ItemId': itemId.toString(),
      'Name': itemName,
      'SRate': sRate.toString(),
      'AddonModifiedStatus': AddonModifiedStatus,
      'Printer': printer,
      'Qty': qty.toString(),
      'NetAmount': NetAmount.toString(),
    };
  }

  factory SelectExtra.fromJson(Map<String, dynamic> json) {
    return SelectExtra(
      parentItemId: json['ParentItemId'],
      itemId: json['ItemId'],
      itemName: json['Name'],
      AddonModifiedStatus: json['AddonModifiedStatus'],
      sRate: json['SRate'].toDouble(),
      printer: json['Printer'],
      qty: json['Qty'] ?? 1,
      NetAmount: json['NetAmount'].toDouble(),
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
