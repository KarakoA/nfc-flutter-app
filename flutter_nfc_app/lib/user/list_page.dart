import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openapi/api.dart';

import '../widgets/reserve_machine_widget.dart';

class ListPage extends StatefulWidget {
  static const routeName = "/list";

  ListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListPageState createState() => new _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Machine> items;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: getBody());
  }

  getBody() {
    if (showLoadingDialog()) {
      return getProgressDialog();
    } else if (showEmptyPlaceholder()) {
      return getEmptyPlaceholder();
    } else {
      return getListView();
    }
  }

  showEmptyPlaceholder() => items?.length == 0;

  showLoadingDialog() => items == null;

  getProgressDialog() => new Center(child: new CircularProgressIndicator());

  getEmptyPlaceholder() =>
      Center(child: Text("No available machines at this time."));

  Widget getListView() =>
      RefreshIndicator(
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (BuildContext context, int position) {
              return getRow(position);
            }),
        onRefresh: loadData,
      );

  Widget getRow(int i) {
    final currentItem = items[i];

      return new ListTile(
        title:
        Text("House ${currentItem.houseNumber}, Machine ${currentItem.name}"),
        leading: Icon(Icons.local_laundry_service, size: 32),
        trailing: ReserveMachineWidget(machine: currentItem)
    );

  }

  void onReserve(Machine machine) {}

  Future<void> loadData() async {
    try {
      var apiClient = MachineApi();
      var machines = await apiClient.listAvailableMachines();
      machines.sort((a, b) =>
      a.houseNumber * 100 + b.name > b.houseNumber * 100 + b.name ? 1 : -1);
      setState(() {
        items = machines.where((x) => x.type != "Dryer").toList();
      });
    } catch (e) {
      setState(() {
        items = [];
      });
    }
  }
}
