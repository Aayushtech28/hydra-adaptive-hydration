import 'package:flutter_test/flutter_test.dart';
// Importing the real entry point proves lib/main.dart compiles and links.
import 'package:hydra/main.dart' as app;

void main() {
  testWidgets('startup error screen renders with a retry action', (
    tester,
  ) async {
    await tester.pumpWidget(const app.StartupErrorApp());
    expect(find.text("HYDRA couldn't start"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(
      find.text('Your data is safe on this device. Please try again.'),
      findsOneWidget,
    );
  });

  test('main() entrypoint is defined', () {
    expect(app.main, isA<Function>());
  });
}
