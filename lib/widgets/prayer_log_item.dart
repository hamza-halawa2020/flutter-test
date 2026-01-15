import 'package:flutter/material.dart';
import '../models/prayer_model.dart';

class PrayerLogItem extends StatelessWidget {
  final PrayerLog log;
  final VoidCallback onDelete;
  final Color prayerColor;

  const PrayerLogItem({
    required this.log,
    required this.onDelete,
    required this.prayerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: prayerColor.withOpacity(0.2),
            border: Border.all(color: prayerColor, width: 2),
          ),
          child: Center(
            child: Icon(Icons.check, color: prayerColor),
          ),
        ),
        title: Text(
          log.prayerName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              '${log.dateLogged.toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Time: ${log.timeLogged}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
