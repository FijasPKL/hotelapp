import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:RestroApp/Models/Dinning.dart';
import 'package:http/http.dart' as http;
import '../../Utils/GlobalFn.dart';

String? DeviceId = "";
SQLMessage? sqlMessage;
List<ExtraAddOn>? extraddon;
List<Category>? category;
List<Items>? items;
List<Voucher>? voucher;
List<OrderList>? orderlist;


Future<Dinning> fetchingvoucherid() async {
  DeviceId = await fnGetDeviceId();
  final String? baseUrl = await fnGetBaseUrl();
  String apiUrl = '${baseUrl}api/Dinein/alldata';

  try {
    apiUrl = '$apiUrl?DeviceId=$DeviceId';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      Dinning dinning = Dinning.fromJson(json.decode(response.body));
      sqlMessage = dinning.data?.sQLMessage;
      if (sqlMessage?.code == "200") {
        extraddon = dinning.data?.extraAddOn;
        category = dinning.data?.category;
        items = dinning.data?.items;
        voucher = dinning.data?.voucher;
        orderlist = dinning.data?.orderlist;


        if (voucher != null) {
          for (var v in voucher!) {
            print('LedIdsssssssssssssssssssss: ${v.ledId}');
          }
        }
      }
      return dinning;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}