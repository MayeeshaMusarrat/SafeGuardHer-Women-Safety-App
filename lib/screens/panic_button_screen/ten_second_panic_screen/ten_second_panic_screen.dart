import 'dart:async';
import 'package:awesome_ripple_animation/awesome_ripple_animation.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/helpers/timer_util.dart';
import '../../../services/background/sms_service/sms_sender.dart';
import '../stop_panic_alert_screen/stop_panic_alert_screen.dart';

class TenSecondPanicScreen extends StatefulWidget {
  const TenSecondPanicScreen({super.key});

  @override
  TenSecondPanicScreenState createState() => TenSecondPanicScreenState();
}

class TenSecondPanicScreenState extends State<TenSecondPanicScreen> {
  late Timer _timer;
  int _countdown = 3;
  final SMSSender smsSender = SMSSender(); // Initialize SMSSender

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = TimerUtil.startCountdown(
      initialCount: _countdown,
      onTick: (currentCount) {
        setState(() {
          _countdown = currentCount;
          _vibrate();
        });
      },
      onComplete: () async {
        _timer.cancel();
        await _fetchAndSendEmergencyContacts();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StopPanicAlertScreen(),
          ),
        );
      },
    );
  }

  Future<void> _vibrate() async {
    await Vibration.vibrate(duration: 500);
  }

  final userdoc = 0;

  Future<void> _fetchAndSendEmergencyContacts() async {
    try {
      // Fetch user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc('01719958727') // Replace with actual user ID
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final emergencyContacts =
            userData?['emergency_contacts'] as List<dynamic>? ?? [];

        if (emergencyContacts.isNotEmpty) {
          // Extract the emergency contact numbers
          final phoneNumbers = emergencyContacts.map((contact) {
            return contact['emergency_contact_number'] as String? ?? '';
          }).toList();

          // Check if there are valid phone numbers
          if (phoneNumbers.isNotEmpty) {
            try {
              await smsSender.sendAndNavigate(
                context,
                "Your emergency message here",
                phoneNumbers,
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error sending SMS: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No valid phone numbers available.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No emergency contacts available.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User document not found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 140),
            RippleAnimation(
              key: UniqueKey(),
              repeat: true,
              duration: const Duration(milliseconds: 900),
              ripplesCount: 5,
              color: const Color(0xFFFF9B70),
              minRadius: 100,
              size: const Size(170, 170),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFB6829),
                child: Text(
                  '$_countdown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
            const Text(
              'KEEP CALM!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Color(0xFFD20451),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Within ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '5 seconds,',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' your ',
                    ),
                    TextSpan(
                      text: 'close contacts',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' will be alerted of your whereabouts.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Press the button below to stop SOS alert.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ElevatedButton(
                onPressed: () {
                  _timer.cancel();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StopPanicAlertScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFD20452),
                  minimumSize: const Size(200, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'STOP SENDING SOS ALERT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
