import 'package:api_dados/filter/model.dart';
import 'package:api_dados/filter/services.dart';
import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  filterProduct() {
    ApiServices().myFilterList().then((value) {
      myItems(value!.results!);
      setState(() {});
    });
  }

  // for filtering the items based on gender
  List<Results> filterLists = [];
  List<Results> myItems(List<Results> list) {
    filterLists.clear();
    for (var element in list) {
      if (element.gender == "female") {
        filterLists.add(element);
      }
    }
    return filterLists;
  }

  @override
  void initState() {
    super.initState();
    filterProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter The Item's From API"),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: filterLists.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              filterLists[index].name.toString(),
            ),
            // subtitle: Text(
            //   "Gender : ${filterLists[index].gender.toString()}",
            // ),
          );
        }),
    );
  }
}