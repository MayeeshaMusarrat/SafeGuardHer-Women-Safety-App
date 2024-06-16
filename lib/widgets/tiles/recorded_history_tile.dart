import 'package:flutter/material.dart';

class RecordedHistoryTile extends StatelessWidget {
  final String date;
  final String duration;

  const RecordedHistoryTile({
    super.key,
    required this.date,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(Icons.video_library_rounded),
        title: Text(
          'Recorded on $date',
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('Lasted $duration seconds', style: const TextStyle
          (fontFamily: 'Poppins', fontSize: 11),),
        onTap: () {
          // Navigate to record details page

        },
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF263238),
          size: 13,
        ),
      ),
    );
  }
}
