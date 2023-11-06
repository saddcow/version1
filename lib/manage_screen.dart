import 'package:flutter/material.dart';
import 'package:try1/maps4.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});

  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
        ],
      ),
    );
  }
}

class AddHazardArea extends StatelessWidget {
  const AddHazardArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Hazard Area Marker"),
      ),
      body: const SizedBox(
        height: 600,
        child: Mapp(),
      ),
    );
  }
}