import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewvio/main.dart';

import 'support/fake_accounts.dart';

void main() {
  testWidgets('The video-first shell exposes five navigation actions', (tester) async {
    final accounts = FakeAccounts();
    addTearDown(accounts.changes.close);
    await tester.pumpWidget(MewvioApp(accounts: accounts));
    expect(find.byKey(const Key('nav-Vibes')), findsOneWidget);
    expect(find.byKey(const Key('nav-Connect')), findsOneWidget);
    expect(find.byKey(const Key('nav-Chats')), findsOneWidget);
    expect(find.byKey(const Key('nav-Me')), findsOneWidget);
    expect(find.text('Vibes'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
