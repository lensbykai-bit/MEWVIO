import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewvio/creator/mewvio_photo_edit_page.dart';

void main() {
  testWidgets('MEWVIO photo editor can add, filter and remove overlays', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MewvioPhotoEditPage()));
    expect(find.byKey(const Key('photo-edit-save')), findsOneWidget);
    expect(find.byKey(const Key('photo-edit-text')), findsOneWidget);
    expect(find.byKey(const Key('photo-edit-sticker')), findsOneWidget);
    expect(find.byKey(const Key('photo-edit-filters')), findsOneWidget);

    await tester.tap(find.byKey(const Key('photo-edit-text')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('photo-edit-text-input')), 'MEWVIO');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('MEWVIO'), findsWidgets);
    expect(find.byKey(const Key('photo-edit-layer-0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('photo-edit-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mono'));
    await tester.pumpAndSettle();
    expect(find.text('Filter: Mono · Drag text or stickers'), findsOneWidget);

    await tester.tap(find.byKey(const Key('photo-edit-undo')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo-edit-layer-0')), findsNothing);
  });
}
