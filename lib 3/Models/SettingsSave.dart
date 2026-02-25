class SettingsSave {
  DeviceInfo? devideInfo; // Corrected the typo here
  List<SettingsList>? settingsList;

  SettingsSave({this.devideInfo, this.settingsList});

  SettingsSave.fromJson(Map<String, dynamic> json) {
    devideInfo = json['DevideInfo'] != null
        ? DeviceInfo.fromJson(json['DevideInfo'])
        : null;
    if (json['SettingsList'] != null) {
      settingsList = <SettingsList>[];
      json['SettingsList'].forEach((v) {
        settingsList!.add(SettingsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (devideInfo != null) {
      data['DevideInfo'] = devideInfo!.toJson();
    }
    if (settingsList != null) {
      data['SettingsList'] = settingsList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeviceInfo {
  String? deviceId;

  DeviceInfo({this.deviceId});

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    deviceId = json['DeviceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DeviceId'] = deviceId;
    return data;
  }
}

class SettingsList {
  String? identifierKey;
  String? identifierValue;

  SettingsList({this.identifierKey, this.identifierValue});

  SettingsList.fromJson(Map<String, dynamic> json) {
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