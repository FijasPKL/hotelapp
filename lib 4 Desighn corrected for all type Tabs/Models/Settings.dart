class Settings {
  String? status;
  String? responseMessage;
  Data? data;
  String? message;

  Settings({this.status, this.responseMessage, this.data, this.message});

  Settings.fromJson(Map<String, dynamic> json) {
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
  List<TableClass>? tableClass;
  List<KOTVoucher>? kOTVoucher;
  List<TAVoucher>? tAVoucher;
  List<PrintArea>? printArea;
  List<SavedSettings>?savedSettings;

  Data(
      {this.sQLMessage,
      this.tableClass,
      this.kOTVoucher,
      this.tAVoucher,
      this.printArea,
      this.savedSettings});

  Data.fromJson(Map<String, dynamic> json) {
    sQLMessage = json['SQLMessage'] != null
        ? SQLMessage.fromJson(json['SQLMessage'])
        : null;
    if (json['TableClass'] != null) {
      tableClass = <TableClass>[];
      json['TableClass'].forEach((v) {
        tableClass!.add(TableClass.fromJson(v));
      });
    }
    if (json['KOTVoucher'] != null) {
      kOTVoucher = <KOTVoucher>[];
      json['KOTVoucher'].forEach((v) {
        kOTVoucher!.add(KOTVoucher.fromJson(v));
      });
    }
    if (json['TAVoucher'] != null) {
      tAVoucher = <TAVoucher>[];
      json['TAVoucher'].forEach((v) {
        tAVoucher!.add(TAVoucher.fromJson(v));
      });
    }
    if (json['PrintArea'] != null) {
      printArea = <PrintArea>[];
      json['PrintArea'].forEach((v) {
        printArea!.add(PrintArea.fromJson(v));
      });
    }
    if (json['SavedSettings'] != null) {
      savedSettings = <SavedSettings>[];
      json['SavedSettings'].forEach((v) {
        savedSettings!.add(SavedSettings.fromJson(v));
      });
    }
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sQLMessage != null) {
      data['SQLMessage'] = sQLMessage!.toJson();
    }
    if (tableClass != null) {
      data['TableClass'] = tableClass!.map((v) => v.toJson()).toList();
    }
    if (kOTVoucher != null) {
      data['KOTVoucher'] = kOTVoucher!.map((v) => v.toJson()).toList();
    }
    if (tAVoucher != null) {
      data['TAVoucher'] = tAVoucher!.map((v) => v.toJson()).toList();
    }
    if (printArea != null) {
      data['PrintArea'] = printArea!.map((v) => v.toJson()).toList();
    }
    if (savedSettings != null) {
      data['SavedSettings'] =
          savedSettings!.map((v) => v.toJson()).toList();
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

class TableClass {
  String? className;
  void description;
  String? selected;

  TableClass({this.className, this.description, this.selected});

  TableClass.fromJson(Map<String, dynamic> json) {
    className = json['ClassName'];
    description = json['Description'];
    selected = json['Selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ClassName'] = className;
    // data['Description'] = description;
    data['Selected'] = selected;
    return data;
  }
}

class KOTVoucher {
  int? ledId;
  String? ledgerName;
  int? tax;
  int? cashDisc;
  String? selected;

  KOTVoucher(
      {this.ledId, this.ledgerName, this.tax, this.cashDisc, this.selected});

  KOTVoucher.fromJson(Map<String, dynamic> json) {
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
    data['Selected'] = selected;
    return data;
  }
}

class TAVoucher {
  int? ledId;
  String? ledgerName;
  int? tax;
  int? cashDisc;
  String? selected;

  TAVoucher(
      {this.ledId, this.ledgerName, this.tax, this.cashDisc, this.selected});

  TAVoucher.fromJson(Map<String, dynamic> json) {
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
    data['Selected'] = selected;
    return data;
  }
}

class PrintArea {
  String? printAreaName;
  int? printAreaId;
  String? ipAddress;

  PrintArea({this.printAreaName, this.printAreaId, this.ipAddress});

  PrintArea.fromJson(Map<String, dynamic> json) {
    printAreaName = json['PrintAreaName'];
    printAreaId = json['PrintAreaId'];
    ipAddress = json['IPAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PrintAreaName'] = printAreaName;
    data['PrintAreaId'] = printAreaId;
    data['IPAddress'] = ipAddress;
    return data;
  }
}

class SavedSettings {
  String? identifierKey;
  String? identifierValue;

  SavedSettings({this.identifierKey, this.identifierValue});

  SavedSettings.fromJson(Map<String, dynamic> json) {
    identifierKey = json['IdentifierKey'];
    identifierValue = json['IdentifierValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['IdentifierKey'] = identifierKey;
    data['IdentifierValue'] = identifierValue;
    return data;
  }
}
