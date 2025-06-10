import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_pro/pages/profile_page.dart';
import 'package:flutter_pro/auth_service.dart';

@GenerateMocks([AuthService, User])
import 'profile_page_test.mocks.dart';

late ValueNotifier<AuthService> authService;

void main() {
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    when(mockUser.displayName).thenReturn('Test User');
    when(mockAuthService.currentUser).thenReturn(mockUser);
    authService = ValueNotifier<AuthService>(mockAuthService);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return ProfilePage(authService: authService);
        },
      ),
    );
  }

  group('ProfilePage UI', () {
    testWidgets('displays user information correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Test User'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Update Username'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Delete My Account'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('shows update username dialog', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Update Username'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Update Username'),
        findsNWidgets(2),
      ); // One in list, one in dialog
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('shows change password dialog', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Change Password'),
        findsNWidgets(2),
      ); // One in list, one in dialog
      expect(
        find.byType(TextField),
        findsNWidgets(3),
      ); // Email, current password, new password
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('shows delete account dialog', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Delete My Account'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Delete Account'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('ProfilePage Interactions', () {
    testWidgets('updates username successfully', (WidgetTester tester) async {
      // Arrange
      when(
        mockAuthService.updateUsername(username: 'newUsername'),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Update Username'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'newUsername');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthService.updateUsername(username: 'newUsername')).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Username updated successfully'), findsOneWidget);
    });

    testWidgets('updates password successfully', (WidgetTester tester) async {
      // Arrange
      when(
        mockAuthService.resetPasswordFromCurrentPassword(
          currentPassword: 'currentPass',
          newPassword: 'newPass',
          email: 'test@example.com',
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Current Password'),
        'currentPass',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'New Password'),
        'newPass',
      );
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      // Assert
      verify(
        mockAuthService.resetPasswordFromCurrentPassword(
          currentPassword: 'currentPass',
          newPassword: 'newPass',
          email: 'test@example.com',
        ),
      ).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Password updated successfully'), findsOneWidget);
    });

    testWidgets('handles logout successfully', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthService.signOut()).called(1);
    });
  });

  group('ProfilePage Error Handling', () {
    testWidgets('handles username update error', (WidgetTester tester) async {
      // Arrange
      when(
        mockAuthService.updateUsername(username: 'newUsername'),
      ).thenThrow(FirebaseAuthException(code: 'error'));

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Update Username'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'newUsername');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Authentication failed'), findsOneWidget);
    });

    testWidgets('handles password update error', (WidgetTester tester) async {
      // Arrange
      when(
        mockAuthService.resetPasswordFromCurrentPassword(
          currentPassword: 'currentPass',
          newPassword: 'newPass',
          email: 'test@example.com',
        ),
      ).thenThrow(FirebaseAuthException(code: 'error'));

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Current Password'),
        'currentPass',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'New Password'),
        'newPass',
      );
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Authentication failed'), findsOneWidget);
    });
  });
}
