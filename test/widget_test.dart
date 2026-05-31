import 'package:flutter_test/flutter_test.dart';
import 'package:clima_app/main.dart';

void main() {
  testWidgets('la app arranca', (WidgetTester tester) async {
    await tester.pumpWidget(const MiApp());
  });
}
