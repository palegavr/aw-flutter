extension DateTimeExtension on DateTime {
  String toDefaultString() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final dd = twoDigits(this.day);
    final mm = twoDigits(this.month);
    final yyyy = this.year.toString();
    final HH = twoDigits(this.hour);
    final MM = twoDigits(this.minute);
    final ss = twoDigits(this.second);
    final secondPartWithSpace = (this.hour > 0 || this.minute > 0 || this. second > 0) ? ' $HH:$MM:$ss' : '';
    return '$dd.$mm.$yyyy$secondPartWithSpace';
  }
}
