String generateId([String prefix = 'ID']) {
  final millis = DateTime.now().millisecondsSinceEpoch;
  return '${prefix}_${millis}_${DateTime.now().microsecond}';
}
