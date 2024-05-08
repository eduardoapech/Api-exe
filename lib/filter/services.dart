import 'dart:convert';

import 'package:api_dados/filter/model.dart';
import 'package:http/http.dart' as http;

class ApiServices { 
  Future <FilterModel?> myFilterList() async { 
    Uri url = Uri.parse("https://randomuser.me/api/?results=10");
    var response = await http.get(url);
    try{ 
      if (response.statusCode == 200) { 
        return FilterModel.fromJson(jsonDecode(response.body));
      } else { 
        return null;
      }
    } catch (e) { 
      print (e);
    }
    return null;
  }
}