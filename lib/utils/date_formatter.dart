String formatCheckInTime(String? isoString) {
  if (isoString == null) return 'No time';
  try {
    final dateTime = DateTime.parse(isoString);
    final now = DateTime.now();

    // show date if not today
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  } catch (e) {
    return 'Invalid time';
  }
}