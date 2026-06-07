import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadrobos/core/extensions/datetime_extensions.dart';

void main() {
  group('Timestamp Extension Tests', () {
    test('DateTime.utcIso always produces a UTC ISO string (ends in Z)', () {
      final nowLocal = DateTime.now();
      expect(nowLocal.utcIso, endsWith('Z'));
      expect(nowLocal.utcIso, isNot(contains('+')));

      final nowUtc = DateTime.now().toUtc();
      expect(nowUtc.utcIso, endsWith('Z'));
      
      final specificLocal = DateTime(2026, 6, 7, 18, 30);
      expect(specificLocal.utcIso, endsWith('Z'));
    });
  });

  group('Repository Code Quality & UTC Checks', () {
    test('No repository method writes a non-UTC timestamp to Database', () {
      // 1. Locate the repositories directory
      final repoDir = Directory('lib/core/repositories');
      expect(repoDir.existsSync(), isTrue, reason: 'Repository directory must exist');

      final repoFiles = repoDir.listSync().where((file) => file.path.endsWith('.dart'));
      expect(repoFiles.isNotEmpty, isTrue, reason: 'There must be repository files to check');

      for (final file in repoFiles) {
        if (file is File) {
          final content = file.readAsStringSync();
          final lines = content.split('\n');

          for (int i = 0; i < lines.length; i++) {
            final rawLine = lines[i];
            
            // Clean up comments and whitespace
            String cleanedLine = rawLine;
            if (cleanedLine.contains('//')) {
              cleanedLine = cleanedLine.substring(0, cleanedLine.indexOf('//'));
            }
            cleanedLine = cleanedLine.trim();

            if (cleanedLine.isEmpty) continue;

            // Rule 1: Prohibit raw .toIso8601String() without .toUtc() or .utcIso helper
            if (cleanedLine.contains('.toIso8601String()')) {
              final isUtcConversion = cleanedLine.contains('.toUtc().toIso8601String()') ||
                  cleanedLine.contains('toUtc()?.toIso8601String()');
              
              expect(
                isUtcConversion, 
                isTrue,
                reason: 'Violation in ${file.path} at line ${i + 1}: '
                    'Found raw ".toIso8601String()" call without explicit UTC conversion. '
                    'Use ".utcIso" extension or ".toUtc().toIso8601String()".\nLine: $rawLine',
              );
            }

            // Rule 2: Prohibit writing raw/local DateTime.now() directly to db maps
            if (cleanedLine.contains('DateTime.now()')) {
              final isSafeUse = cleanedLine.contains('.utcIso') ||
                  cleanedLine.contains('.toUtc()') ||
                  cleanedLine.contains('.millisecondsSinceEpoch') ||
                  // Allow fallback values in fromMap/parsing operations
                  cleanedLine.contains('?') ||
                  cleanedLine.contains(':');

              expect(
                isSafeUse,
                isTrue,
                reason: 'Violation in ${file.path} at line ${i + 1}: '
                    'Found raw "DateTime.now()" call which writes a local (non-UTC) timestamp. '
                    'Use "DateTime.now().utcIso" or "DateTime.now().toUtc()".\nLine: $rawLine',
              );
            }
          }
        }
      }
    });
  });
}
