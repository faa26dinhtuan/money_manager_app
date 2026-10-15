import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager_app/app.dart';

void main() {
  testWidgets('App khởi động và hiện thanh điều hướng', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Tổng quan'), findsOneWidget);
    expect(find.text('Giao dịch'), findsOneWidget);
    expect(find.text('Danh mục'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
  });
}
