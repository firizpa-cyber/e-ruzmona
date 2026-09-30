import 'package:flutter_test/flutter_test.dart';
import 'package:e_ruzmona/providers/app_state.dart';

void main() {
  test('average calculation', () {
    final s = AppState();
    // mock c1: 5,4,4,5,3,5 = 26/6 ≈ 4.33
    expect(s.average, closeTo(4.33, 0.01));
  });

  test('multiple children + switching', () {
    final s = AppState();
    expect(s.children.length, 2);
    s.selectChild(s.children.last.id);
    expect(s.selectedChild.id, s.children.last.id);
  });
}
