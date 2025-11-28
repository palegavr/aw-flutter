import 'dart:convert';

import 'package:drift/drift.dart';

class ListToStringConverter<T> extends TypeConverter<List<T>, String> {
  final TypeConverter<T, String> elementConverter;

  const ListToStringConverter(this.elementConverter);

  @override
  List<T> fromSql(String fromDb) {
    final List<dynamic> rawList = jsonDecode(fromDb);
    return rawList
        .map((e) => elementConverter.fromSql(e))
        .toList();
  }

  @override
  String toSql(List<T> value) {
    final encoded = value
        .map((e) => elementConverter.toSql(e))
        .toList();
    return jsonEncode(encoded);
  }
}