import 'package:intl/intl.dart';

String formatRupiah (int number) {
  final currencyFormatter = NumberFormat.currency(locale: 'id_IDN', symbol: 'Rp. ', decimalDigits: 0);
  return currencyFormatter.format(number);
}


