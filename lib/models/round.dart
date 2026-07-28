class Round {
  final int work;
  final int rest;

  Round({required this.work, required this.rest});

  Map<String, dynamic> toJson() {
    return {'work': work, 'rest': rest};
  }

  static Round? fromJson(Map<String, dynamic> map) {
    try {
      return Round(
        work: _intFromJson(map['work']),
        rest: _intFromJson(map['rest']),
      );
    } catch (_) {
      return null;
    }
  }

  static int _intFromJson(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw FormatException('Expected int, got $value');
  }
}
