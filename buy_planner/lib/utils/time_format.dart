import 'package:intl/intl.dart';

String formatMonths(double months) {
  if (months <= 0) return 'Done';
  if (months < 1) return '${(months * 30).round()} days';
  int m = months.floor();
  int d = ((months - m) * 30).round();
  if (d == 0) return '$m month${m > 1 ? 's' : ''}';
  return '${m}mo ${d}d';
}

String formatTargetDate(DateTime date) {
  final now = DateTime.now();
  String month = DateFormat('MMMM').format(date);
  String year = date.year != now.year ? ' ${date.year}' : '';
  if (date.day <= 10) return 'By early $month$year';
  if (date.day <= 20) return 'By mid $month$year';
  return 'By late $month$year';
}

String formatShortETA(double months) {
  if (months <= 0) return 'Done!';
  DateTime target = DateTime.now().add(Duration(days: (months * 30.44).round()));
  return formatTargetDate(target);
}
