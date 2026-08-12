import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('movies.json validates 50+50 and schema', () async {
    final raw = await rootBundle.loadString('assets/data/movies.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final movies = (decoded['movies'] as List).cast<Map<String, dynamic>>();

    expect(movies.length, 100);
    final bollywood =
        movies.where((m) => m['industry'] == 'bollywood').toList();
    final hollywood =
        movies.where((m) => m['industry'] == 'hollywood').toList();
    expect(bollywood.length, 50);
    expect(hollywood.length, 50);

    final titles = <String>{};
    for (final m in movies) {
      final title = m['title'] as String;
      expect(title.isNotEmpty, isTrue);
      expect(RegExp(r'\d').hasMatch(title), isFalse, reason: title);
      expect(m['year'] as int, inInclusiveRange(1990, 2026));
      expect((m['cast'] as List).isNotEmpty, isTrue);
      expect((m['hints'] as List).length, 4);
      expect(m['about'], isNotEmpty);
      expect(m['era'], isNotEmpty);
      final key = '${m['industry']}:${title.toLowerCase()}';
      expect(titles.contains(key), isFalse, reason: 'duplicate $key');
      titles.add(key);

      final titleLower = title.toLowerCase();
      for (final hint in m['hints'] as List) {
        expect(
          hint.toString().toLowerCase().contains(titleLower),
          isFalse,
          reason: 'hint reveals title for $title',
        );
      }
    }
  });
}
