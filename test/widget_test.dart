import 'package:flutter_test/flutter_test.dart';
import 'package:warungposku/core/helpers/currency_helper.dart';

void main() {
  test('formatRupiah formats Indonesian currency', () {
    expect(formatRupiah(12000), 'Rp 12.000');
    expect(formatRupiah(1500000), 'Rp 1.500.000');
  });
}
