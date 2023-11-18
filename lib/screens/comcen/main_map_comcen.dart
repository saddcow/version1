import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:try1/screens/comcen/comcen_map_markers.dart';
import 'package:try1/screens/comcen/road_markers.dart';

class MainMapComcen extends StatefulWidget {
  const MainMapComcen({super.key});
  @override
  _MainMapComcenState createState() => _MainMapComcenState();
}

class _MainMapComcenState extends State<MainMapComcen> {
  List<Marker> markersCombined = [];
  String selectedMarkerType = 'All'; // Default selection

  @override
  void initState() {
    super.initState();
    loadRoadMarkers();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    List<Marker> markers = await retrieveMarkersFromFirestoreRoad();
    setState(() {
      markersCombined.addAll(markers);
    });
  }

  Future<void> loadRoadMarkers() async {
    List<Marker> roadMarkers = await getRoadMarkers();

    setState(() {
      markersCombined.addAll(roadMarkers);
    });
  }

  List<DropdownMenuItem<String>> buildDropdownMenuItems() {
    return ['All', 'Road Accident Prone Area', 'Road Accident Report Markers'].map((String value) {
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
      markersCombined.clear();
      // Load the selected type of markers
      if (selectedValue == 'All') {
        loadRoadMarkers();
        _loadMarkers();
      } else if (selectedValue == 'Road Accident Prone Area') {
        loadRoadMarkers();
      } else if (selectedValue == 'Road Accident Report Markers') {
        _loadMarkers();
      }
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedMarkerType,
              items: buildDropdownMenuItems(),
              onChanged: onDropdownChanged,
              decoration: const InputDecoration(
                labelText: 'Select Marker Type',
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
              markers: Set.from(markersCombined),
            ),
          ),
        ],
      ),
    );
  }
}
