import 'package:RestroApp/Models/printer.dart';

class Dinning {
  String? status;
  String? responseMessage;
  Data? data;
  String? message;

  Dinning({this.status, this.responseMessage, this.data, this.message});

  Dinning.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    responseMessage = json['ResponseMessage'];
    data = json['Data'] != null ? Data.fromJson(json['Data']) : null;
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Status'] = status;
    data['ResponseMessage'] = responseMessage;
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    data['Message'] = message;
    return data;
  }
}

class Data {
  SQLMessage? sQLMessage;
  List<Category>? category;
  List<Items>? items;
  List<ExtraAddOn>? extraAddOn;
  List<Tables>? tables;
  List<Voucher>? voucher;
  List<OrderList>? orderlist;

  Data(
      {this.sQLMessage,
      this.category,
      this.items,
      this.extraAddOn,
      this.tables,
      this.voucher,
      required this.orderlist});

  Data.fromJson(Map<String, dynamic> json) {
    sQLMessage = json['SQLMessage'] != null
        ? SQLMessage.fromJson(json['SQLMessage'])
        : null;
    if (json['Category'] != null) {
      category = <Category>[];
      json['Category'].forEach((v) {
        category!.add(Category.fromJson(v));
      });
    }
    if (json['Items'] != null) {
      items = <Items>[];
      json['Items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    if (json['ExtraAddOn'] != null) {
      extraAddOn = <ExtraAddOn>[];
      json['ExtraAddOn'].forEach((v) {
        extraAddOn!.add(ExtraAddOn.fromJson(v));
      });
    }
    if (json['Tables'] != null) {
      tables = <Tables>[];
      json['Tables'].forEach((v) {
        tables!.add(Tables.fromJson(v));
      });
    }

    if (json['Voucher'] != null) {
      voucher = <Voucher>[];
      json['Voucher'].forEach((v) {
        voucher!.add(Voucher.fromJson(v));
      });
    }
    if (json['OrderList'] != null) {
      orderlist = <OrderList>[];
      json['OrderList'].forEach((v) {
        orderlist!.add(OrderList.fromJson(v)); // Add data to the list
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sQLMessage != null) {
      data['SQLMessage'] = sQLMessage!.toJson();
    }
    if (category != null) {
      data['Category'] = category!.map((v) => v.toJson()).toList();
    }
    if (items != null) {
      data['Items'] = items!.map((v) => v.toJson()).toList();
    }
    if (extraAddOn != null) {
      data['ExtraAddOn'] = extraAddOn!.map((v) => v.toJson()).toList();
    }
    if (tables != null) {
      data['Tables'] = tables!.map((v) => v.toJson()).toList();
    }
    if (voucher != null) {
      data['Voucher'] = voucher!.map((v) => v.toJson()).toList();
    }
    if (orderlist != null) {
      data['OrderList'] = orderlist!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SQLMessage {
  void level;
  String? status;
  String? code;
  String? message;

  SQLMessage({this.level, this.status, this.code, this.message});

  SQLMessage.fromJson(Map<String, dynamic> json) {
    level = json['Level'];
    status = json['Status'];
    code = json['Code'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['Level'] = level;
    data['Status'] = status;
    data['Code'] = code;
    data['Message'] = message;
    return data;
  }
}

class Category {
  int? catId;
  String? catName;

  Category({this.catId, this.catName});

  Category.fromJson(Map<String, dynamic> json) {
    catId = json['CatId'];
    catName = json['CatName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CatId'] = catId;
    data['CatName'] = catName;
    return data;
  }
}

class Items {
  int? itemId;
  int? catId;
  String? name;
  double? sRate;
  String? printer;

  Items({this.itemId, this.catId, this.name, this.sRate, this.printer});

  Items.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    catId = json['CatId'];
    name = json['Name'];
    sRate = json['SRate'];
    printer = json['Printer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemId'] = itemId;
    data['CatId'] = catId;
    data['Name'] = name;
    data['SRate'] = sRate;
    data['Printer'] = printer;
    return data;
  }
}

class ExtraAddOn {
  int? itemId;
  int? catId;
  String? name;
  double? sRate;
  String? printer;

  ExtraAddOn({this.itemId, this.catId, this.name, this.sRate, this.printer});

  ExtraAddOn.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    catId = json['CatId'];
    name = json['Name'];
    sRate = json['SRate'];
    printer = json['Printer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemId'] = itemId;
    data['CatId'] = catId;
    data['Name'] = name;
    data['SRate'] = sRate;
    data['Printer'] = printer;
    return data;
  }
}

class Tables {
  int? tableId;
  String? tableName;
  int? chair;
  String? guest;
  String? tableStatus;

  Tables({
    this.tableId,
    this.tableName,
    this.chair,
    this.guest,
    this.tableStatus,
  });

  Tables.fromJson(Map<String, dynamic> json) {
    tableId = json['TableId'];
    tableName = json['TableName'];
    chair = json['Chair'];
    guest = json['Guest'];
    tableStatus = json['TableStatus'];
    chair = chair ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TableId'] = tableId;
    data['TableName'] = tableName;
    data['Chair'] = chair;
    data['Guest'] = guest;
    data['TableStatus'] = tableStatus;
    return data;
  }
}

class Voucher {
  int? ledId;
  String? ledgerName;
  int? tax;
  int? cashDisc;
  void selected;

  Voucher(
      {this.ledId, this.ledgerName, this.tax, this.cashDisc, this.selected});

  Voucher.fromJson(Map<String, dynamic> json) {
    ledId = json['LedId'];
    ledgerName = json['LedgerName'];
    tax = json['Tax'];
    cashDisc = json['CashDisc'];
    selected = json['Selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['LedId'] = ledId;
    data['LedgerName'] = ledgerName;
    data['Tax'] = tax;
    data['CashDisc'] = cashDisc;
    // data['Selected'] = selected;
    return data;
  }
}

class OrderList {
  int? id;
  String? guest;
  String? chairIdList;
  int? tableId;
  String? tableName;
  int? issueCode;
  String? vNo;
  String? ledcodeCr;
  double? amt;
  String? issueDate;
  String? timeAgo;

  OrderList({
    this.id,
    this.guest,
    this.chairIdList,
    this.tableId,
    this.tableName,
    this.issueCode,
    this.vNo,
    this.ledcodeCr,
    this.amt,
    this.issueDate,
    this.timeAgo,
  });

  OrderList.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    guest = json['Guest'];
    chairIdList = json['ChairIdList'];
    tableId = json['TableId'];
    tableName = json['TableName'];
    issueCode = json['IssueCode'];
    vNo = json['VNo'];
    ledcodeCr = json['LedcodeCr'];
    amt = json['Amt'];
    issueDate = json['IssueDate'];
    timeAgo = json['TimeAgo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Guest'] = guest;
    data['ChairIdList'] = chairIdList;
    data['TableId'] = tableId;
    data['TableName'] = tableName;
    data['IssueCode'] = issueCode;
    data['VNo'] = vNo;
    data['LedcodeCr'] = ledcodeCr;
    data['Amt'] = amt;
    data['IssueDate'] = issueDate;
    data['TimeAgo'] = timeAgo;
    return data;
  }
}
