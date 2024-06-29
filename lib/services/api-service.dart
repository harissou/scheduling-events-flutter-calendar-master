import 'dart:convert';

import '../models/user.dart';
import 'package:http/http.dart' as http;
class ApiService{

  static Future<List<User>> getUsers() async{
    var data = await await http.get(Uri.parse("https://62442d2139aae3e3b74c8b08.mockapi.io/aaaa"));
    List<dynamic> jsonData = json.decode(data.body);
    List<User> users = jsonData.map((e) => User.fromJson(e)).toList();
    return users;
  }
  static Future postinfomeeting(List<dynamic> user) async {
    var data = await await http.post(Uri.parse("https://js.syncfusion.com/demos/ejservices/api/Schedule/LoadData") , body: {

      "Subject": user[0].eventName,
      "AllDay": user[0].isAllDay,
      "description": user[0].description,
      "StartTime": user[0].startTimeZone,


    });
  }
  }

