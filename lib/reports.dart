import 'package:flutter/material.dart';
import 'package:try1/database_manager.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  List dataList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: FireStoreDataBase().getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              "Something went wrong",
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            dataList = snapshot.data as List;
            return buildDataTable(dataList);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildDataTable(List dataList) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Baranggay')),
        DataColumn(label: Text('Street')),
        DataColumn(label: Text('User ID')),
        DataColumn(label: Text('Report Description')),
        DataColumn(label: Text('Report Hazard Type')),
      ],
      rows: dataList.map((data){
        return DataRow(
          cells: [
            DataCell(Text(data['Baranggay'])),
            DataCell(Text(data['Street'])),
            DataCell(Text(data['User_ID'])),
            DataCell(Text(data['Report_Description'])),
            DataCell(Text(data['Report_Hazard_Type'])),
          ],
        );
      }).toList(),
    );
  }
}