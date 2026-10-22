import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewvio/main.dart';

import 'support/fake_accounts.dart';

void main() {
  testWidgets('Profile tab opens live account flow without gating demo tabs', (tester) async {
    final accounts = FakeAccounts();
    addTearDown(accounts.changes.close);
    await tester.pumpWidget(MewvioApp(accounts: accounts));
    await tester.tap(find.byKey(const Key('nav-Profile')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('account-email')), findsOneWidget);
    expect(find.text('Create a new account'), findsOneWidget);
    accounts.changeUser('alice');
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Private profile'), 200);
    await tester.pumpAndSettle();
    expect(find.text('Private profile'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
