import 'dart:convert';
import 'dart:io';

/// CLI validator for assets/data/movies.json
void main(List<String> args) {
  final file = File('assets/data/movies.json');
  if (!file.existsSync()) {
    stderr.writeln('Missing assets/data/movies.json');
    exit(1);
  }
  final movies =
      ((jsonDecode(file.readAsStringSync()) as Map)['movies'] as List)
          .cast<Map<String, dynamic>>();

  var errors = 0;
  void fail(String msg) {
    stderr.writeln('ERROR: $msg');
    errors++;
  }

  final bollywood = movies.where((m) => m['industry'] == 'bollywood').length;
  final hollywood = movies.where((m) => m['industry'] == 'hollywood').length;
  if (bollywood != 50) fail('Expected 50 Bollywood, got $bollywood');
  if (hollywood != 50) fail('Expected 50 Hollywood, got $hollywood');

  final seen = <String>{};
  for (final m in movies) {
    final title = (m['title'] as String?) ?? '';
    if (title.isEmpty) fail('Empty title');
    if (RegExp(r'\d').hasMatch(title)) fail('Digit in title: $title');
    final year = m['year'];
    if (year is! int || year < 1990 || year > 2026) {
      fail('Bad year for $title: $year');
    }
    final cast = m['cast'];
    if (cast is! List || cast.isEmpty) fail('Missing cast: $title');
    final hints = m['hints'];
    if (hints is! List || hints.length != 4) fail('Hints != 4: $title');
    final industry = m['industry'];
    if (industry != 'bollywood' && industry != 'hollywood') {
      fail('Invalid industry for $title');
    }
    final key = '$industry:${title.toLowerCase()}';
    if (!seen.add(key)) fail('Duplicate: $key');
    for (final h in hints) {
      if (h.toString().toLowerCase().contains(title.toLowerCase())) {
        fail('Hint reveals title: $title');
      }
    }
  }

  if (errors > 0) {
    stderr.writeln('Validation failed with $errors error(s).');
    exit(1);
  }
  stdout.writeln('OK: ${movies.length} movies validated.');
}
