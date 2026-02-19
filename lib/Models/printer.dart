
class KotPrint {
  String? mode;
  String? printType;
  String? tableName;
  String? tableSeat;
  String? tableArea;
  String? orderDate;
  String? kOTNo;
  String? staff;
  String? extraNote;
  List<PrintAreas>? printAreas;
  List<PrintItems>? printItems;

  KotPrint({
    this.mode,
    this.printType,
    this.tableName,
    this.tableSeat,
    this.tableArea,
    this.orderDate,
    this.kOTNo,
    this.staff,
    this.extraNote,
    this.printAreas,
    this.printItems,
  });

  KotPrint.fromJson(Map<String, dynamic> json) {
    mode = json['Mode'];
    printType = json['PrintType'];
    tableName = json['TableName'];
    tableSeat = json['TableSeat'];
    tableArea = json['TableArea'];
    orderDate = json['OrderDate'];
    kOTNo = json['KOTNo'];
    staff = json['Staff'];
    extraNote = json['ExtraNote'];
    if (json['PrintAreas'] != null) {
      printAreas = <PrintAreas>[];
      json['PrintAreas'].forEach((v) {
        printAreas!.add(PrintAreas.fromJson(v));
      });
    }
    if (json['PrintItems'] != null) {
      printItems = <PrintItems>[];
      json['PrintItems'].forEach((v) {
        printItems!.add(PrintItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Mode'] = mode;
    data['PrintType'] = printType;
    data['TableName'] = tableName;
    data['TableSeat'] = tableSeat;
    data['TableArea'] = tableArea;
    data['OrderDate'] = orderDate;
    data['KOTNo'] = kOTNo;
    data['Staff'] = staff;
    data['ExtraNote'] = extraNote;
    if (printAreas != null) {
      data['PrintAreas'] = printAreas!.map((v) => v.toJson()).toList();
    }
    if (printItems != null) {
      data['PrintItems'] = printItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return '''{"Mode": "$mode","PrintType": "$printType","TableName": "$tableName","TableSeat": "$tableSeat","TableArea": "$tableArea","OrderDate": "$orderDate","KOTNo": "$kOTNo","Staff": "$staff","ExtraNote": "$extraNote","PrintAreas": ${printAreas?.toString() ?? '[]'}, "PrintItems": ${printItems?.toString() ?? '[]'}}''';}
}

class PrintAreas {
  String? printAreaName;
  int? printAreaId;
  String? iPAddress;

  PrintAreas({this.printAreaName, this.printAreaId, this.iPAddress});

  PrintAreas.fromJson(Map<String, dynamic> json) {
    printAreaName = json['PrintAreaName'];
    printAreaId = json['PrintAreaId'];
    iPAddress = json['IPAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PrintAreaName'] = printAreaName;
    data['PrintAreaId'] = printAreaId;
    data['IPAddress'] = iPAddress;
    return data;
  }

  @override
  String toString() {
    return'{"PrintAreaName":"$printAreaName","PrintAreaId":$printAreaId,"IPAddress":"$iPAddress"}';
  }
}

class PrintItems {
  int? itemId;
  int? catId;
  String? name;
  int? sRate;
  String? printer;
  String? qty;
  String? OldQty;
  String? itemModifiedStatus;
  String?extraNote;
  List<AddonItems>? addonItems;

  PrintItems({
    this.itemId,
    this.catId,
    this.name,
    this.sRate,
    this.printer,
    this.qty,
    this.OldQty,
    this.itemModifiedStatus,
    this.addonItems,
    this.extraNote,
  });

  PrintItems.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    catId = json['CatId'];
    name = json['Name'];
    sRate = json['SRate'];
    printer = json['Printer'];
    qty = json['Qty'];
    OldQty= json['OldQty'];
    extraNote = json['ExtraNote'];
    itemModifiedStatus = json['ItemModifiedStatus'];
    if (json['AddonItems'] != null) {
      addonItems = <AddonItems>[];
      json['AddonItems'].forEach((v) {
        addonItems!.add(AddonItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemId'] = itemId;
    data['CatId'] = catId;
    data['Name'] = name;
    data['SRate'] = sRate;
    data['Printer'] = printer;
    data['ExtraNote'] = extraNote;
    data['Qty'] = qty;
    data['OldQty'] = OldQty;
    data['ItemModifiedStatus'] = itemModifiedStatus;
    if (addonItems != null) {
      data['AddonItems'] = addonItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return '''{"ItemId": $itemId,"ItemModifiedStatus": "$itemModifiedStatus","CatId": $catId,"Name": "$name","SRate": $sRate,"ExtraNote": "$extraNote","Printer": "$printer","Qty": "$qty","OldQty":"$OldQty","AddonItems": ${addonItems?.toString() ?? '[]'}}''';
  }
}

class AddonItems {
  int? itemId;
  String? name;
  int? sRate;
  String? AddonModifiedStatus;
  int? qty;


  AddonItems({this.itemId, this.name, this.sRate,this.AddonModifiedStatus, this.qty});

  AddonItems.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    name = json['Name'];
    sRate = json['SRate'];
    AddonModifiedStatus =json['AddonModifiedStatus'];
    qty = json['Qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemId'] = itemId;
    data['Name'] = name;
    data['SRate'] = sRate;
    data['AddonModifiedStatus'] = AddonModifiedStatus;
    data['Qty'] = qty;
    return data;
  }

  @override
  String toString() {
    return '''
  {"ItemId": $itemId,"Name": "$name","SRate": $sRate,"AddonModifiedStatus": $AddonModifiedStatus,"Qty": $qty}''';
  }
}
