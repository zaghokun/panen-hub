import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panenhub/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PanenHubApp()));
    expect(find.text('PanenHub'), findsOneWidget);
    
    // Allow splash screen animations and future timers (e.g. _checkSession) to complete
    await tester.pumpAndSettle();
  });
}
