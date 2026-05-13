import 'package:flutter_test/flutter_test.dart';
import 'package:panenhub/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const PanenHubApp());
    expect(find.text('PanenHub'), findsOneWidget);
  });
}
