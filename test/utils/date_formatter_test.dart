import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro/utils/date_formatter.dart';

void main() {
  group('formatDate', () {
    test('formats valid ISO date correctly', () {
      // Arrange
      const inputDate = '2024-03-15T10:30:00Z';
      const expectedOutput = '15 March 2024';

      // Act
      final actualOutput = formatDate(inputDate);

      // Assert
      expect(actualOutput, expectedOutput);
    });

    test('handles null input', () {
      // Arrange
      const String? inputDate = null;
      const expectedOutput = '';

      // Act
      final actualOutput = formatDate(inputDate);

      // Assert
      expect(actualOutput, expectedOutput);
    });

    test('handles invalid date string', () {
      // Arrange
      const inputDate = 'invalid-date';
      const expectedOutput = '';

      // Act
      final actualOutput = formatDate(inputDate);

      // Assert
      expect(actualOutput, expectedOutput);
    });

    test('formats date with different months', () {
      // Arrange
      final testCases = {
        '2024-01-15T10:30:00Z': '15 January 2024',
        '2024-06-15T10:30:00Z': '15 June 2024',
        '2024-12-15T10:30:00Z': '15 December 2024',
      };

      // Act & Assert
      testCases.forEach((input, expected) {
        final actual = formatDate(input);
        expect(actual, expected, reason: 'Failed for date: $input');
      });
    });

    test('formats date with different days', () {
      // Arrange
      final testCases = {
        '2024-03-01T10:30:00Z': '01 March 2024',
        '2024-03-15T10:30:00Z': '15 March 2024',
        '2024-03-31T10:30:00Z': '31 March 2024',
      };

      // Act & Assert
      testCases.forEach((input, expected) {
        final actual = formatDate(input);
        expect(actual, expected, reason: 'Failed for date: $input');
      });
    });
  });
}
