import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import if you're using Firestore for GeoPoint
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:geocoding/geocoding.dart'; // Import for geocoding
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG icons
import 'package:safeguardher_flutter_app/screens/tracking_screen/track_others_screen.dart';
import 'package:safeguardher_flutter_app/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/alert_model.dart';
import '../../widgets/custom_widgets/track_others_app_bar.dart';

class TrackOthersBottomDrawer extends StatefulWidget {
  final String panickedPersonName;
  final String panickedPersonProfilePic;
  final String panickedPersonSafetyCode;
  final Alert panickedPersonAlertDetails;

  const TrackOthersBottomDrawer({
    super.key,
    required this.panickedPersonName,
    required this.panickedPersonProfilePic,
    required this.panickedPersonSafetyCode,
    required this.panickedPersonAlertDetails,
  });

  @override
  TrackCloseContactState createState() => TrackCloseContactState();
}

class TrackCloseContactState extends State<TrackOthersBottomDrawer> {
  double _currentChildSize = 0.18;
  String _userLocationStart = '';
  String _formattedTimestamp = '';

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async
  {
    _formattedTimestamp = _formatTimestamp(widget.panickedPersonAlertDetails.alertStart);
    _userLocationStart = await _convertGeoPointToString(widget.panickedPersonAlertDetails.userLocationStart);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
           TrackOthersScreen(
            panickedPersonName: widget.panickedPersonName,
            panickedPersonProfilePic : widget.panickedPersonProfilePic,
             panickedPersonSafetyCode : widget.panickedPersonSafetyCode,

           ),
          DraggableScrollableSheet(
            initialChildSize: 0.18,
            minChildSize: 0.18,
            maxChildSize: 0.44,
            expand: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  setState(() {
                    _currentChildSize = notification.extent;
                  });
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      if (_currentChildSize <= 0.18)
                        _buildMinimizedUI()
                      else
                        _buildExpandedUI(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMinimizedUI() {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0, left: 8.0, top: 0.0,
          bottom: 10.0),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 2), // Border color and width
                  ),
                  child: CircleAvatar(
                    backgroundImage: widget.panickedPersonProfilePic != null &&
                        widget.panickedPersonProfilePic!.isNotEmpty
                        ? NetworkImage(widget.panickedPersonProfilePic!)
                        : const NetworkImage('https://firebasestorage.googleapis.com/v0/b/safeguardher-app.appspot.com/o/profile_pics%2F01719958727%2F1000007043.png?alt=media&token=34a85510-d1e2-40bd-b84b-5839bef880bc'),
                    radius: 30,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              SizedBox(width: 5, height: 10),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.panickedPersonName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'has triggered panic alert!',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () {
                      // Handle call action
                    },
                  ),
                  Text('Call', style: TextStyle(fontSize: 10)),
                ],
              ),
              SizedBox(width: 5),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      // Handle share action
                    },
                  ),
                  const Text('Share', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 2), // Border color and width
              ),
              child: CircleAvatar(
                backgroundImage: widget.panickedPersonProfilePic.isNotEmpty
                    ? NetworkImage(widget.panickedPersonProfilePic)
                    : const NetworkImage('https://firebasestorage.googleapis.com/v0/b/safeguardher-app.appspot.com/o/profile_pics%2F01719958727%2F1000007043.png?alt=media&token=34a85510-d1e2-40bd-b84b-5839bef880bc'),
                radius: 33,
                backgroundColor: Colors.transparent,
              ),
            ),
            title: Text(
              widget.panickedPersonName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              'Alert sent on $_formattedTimestamp from $_userLocationStart',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 5,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle view captured images action
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/view_image.svg',
                    width: 35,
                    height: 35,
                  ),
                  label: Text(
                    'View captured images',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: AppColors.secondary,),
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () {
                        // Handle call action
                      },
                    ),
                    Text('Call', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        // Handle share action
                      },
                    ),
                    Text('Share', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 10),
          const Text(
            'Tap on “Get Directions” button to navigate in Google Maps',
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async
            {
              GeoPoint userLocationStart = widget.panickedPersonAlertDetails.userLocationStart;
              double latitude = userLocationStart.latitude;
              double longitude = userLocationStart.longitude;
              final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
              if (await canLaunchUrl(Uri.parse(googleMapsUrl)))
              {
                await launchUrl(Uri.parse(googleMapsUrl));
              }
              else
              {
                print("Could not open Google Maps.");
              }

              if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                await launchUrl(Uri.parse(googleMapsUrl));
              } else {
                // Handle the error if Google Maps can't be opened
                print("Could not open Google Maps.");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary, // Ensure `AppColors.secondary` is defined
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: Size(double.infinity, 50), // Full width button
            ),
            child: Text("Get Directions"),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final DateFormat formatter = DateFormat('MMMM d, yyyy h:mm a');
    return formatter.format(date);
  }

  Future<String> _convertGeoPointToString(GeoPoint geoPoint) async {
    final placemarks = await placemarkFromCoordinates(geoPoint.latitude, geoPoint.longitude);
    final placemark = placemarks.first;
    return '${placemark.name}, ${placemark.locality}';
  }
}