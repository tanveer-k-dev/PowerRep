import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powerrep/main.dart';

void main() {
  testWidgets('App loads and shows PowerRep title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PowerRepApp()));

    // Verify that the app title is shown.
    expect(find.text('PowerRep'), findsAtLeastNWidgets(1));
  });
}
