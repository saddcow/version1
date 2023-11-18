import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:try1/markers/hazard_area_markers.dart';
import 'package:try1/markers/reports_marker_helper.dart';
import 'risk_markers_helper.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});
  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  List<Marker> combinedMarkers = [];
  String selectedMarkerType = 'All'; 

  @override
  void initState() {
    super.initState();
    loadMarkers();
    _loadMarkers(); // Load markers when the app starts
  }

  Future<void> _loadMarkers() async {
    List<Marker> markers = await retrieveMarkersFromFirestore();

    setState(() {
      combinedMarkers.addAll(markers);
    });
  }

  Future<void> hazardAreaMarkers() async {
    List<Marker> markers = await hazardMarkers();
     
    setState(() {
      combinedMarkers.addAll(markers);
    });
  }

  Future<void> loadMarkers() async {
    List<Marker> riskMarkers = await getRiskMarkers();

    setState(() {
      combinedMarkers.addAll(riskMarkers);
    });
  }

    List<DropdownMenuItem<String>> buildDropdownMenuItems() {
    return ['All', 'Flood Prone Areas', 'Flood Report Markers'].map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

void onDropdownChanged(String? selectedValue) {
  if (selectedValue != null) {
    setState(() {
      selectedMarkerType = selectedValue;
      // Clear existing markers
      combinedMarkers.clear();
      // Load the selected type of markers
      if (selectedValue == 'All') {
        loadMarkers();
        _loadMarkers();
      } else if (selectedValue == 'Flood Prone Areas') {
        hazardAreaMarkers();
      } else if (selectedValue == 'Flood Report Markers') {
        _loadMarkers();
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedMarkerType,
              items: buildDropdownMenuItems(),
              onChanged: onDropdownChanged,
              decoration: const InputDecoration(
                labelText: 'Marker Filter',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Google Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(13.6217753, 123.1948238),
                zoom: 15,
              ),
              markers: Set.from(combinedMarkers),
            ),
          ),
        ],
      ),
    );
  }
}
