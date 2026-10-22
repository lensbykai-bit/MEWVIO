import 'package:flutter/material.dart';

const _bg = Color(0xFF090A15);
const _surface = Color(0xFF19182A);
const _pink = Color(0xFFFF4EAA);
const _cyan = Color(0xFF5DDFF0);

class MewvioWalletPage extends StatefulWidget {
  const MewvioWalletPage({super.key});
  @override
  State<MewvioWalletPage> createState() => _MewvioWalletPageState();
}

class _MewvioWalletPageState extends State<MewvioWalletPage> {
  int? selectedPack;
  static const packages = <(int, String)>[
    (20, '0.39'), (70, '1.19'), (350, '5.59'),
    (700, '11.00'), (1400, '22.00'), (3500, '55.00'),
    (7000, '110.99'), (17500, '279.00'),
  ];

  void previewPurchase() {
    showModalBottomSheet<void>(
      context: context, showDragHandle: true, backgroundColor: _surface,
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.shield_outlined, color: _cyan, size: 40),
          const SizedBox(height: 12),
          const Text('MEWVIO Wallet Preview',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const Text('Payments are not enabled. No charges will be made and no coins will be credited.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(
      backgroundColor: _bg, foregroundColor: Colors.white,
      title: const Column(children: [
        Text('MEWVIO Wallet', style: TextStyle(fontWeight: FontWeight.w900)),
        Text('PREVIEW • No real funds', style: TextStyle(color: Colors.white54, fontSize: 10)),
      ]),
      centerTitle: true,
    ),
    body: ListView(padding: const EdgeInsets.fromLTRB(17, 12, 17, 28), children: [
      Container(
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF36216F), Color(0xFF7338A6), Color(0xFFBE3581)]),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.auto_awesome_rounded, color: _cyan),
            SizedBox(width: 8),
            Text('My Vibe Balance', style: TextStyle(color: Colors.white70, fontSize: 15)),
            Spacer(),
            Icon(Icons.lock_outline, color: Colors.white70, size: 18),
          ]),
          const SizedBox(height: 14),
          const Text('0', style: TextStyle(color: Colors.white, fontSize: 49, fontWeight: FontWeight.w900)),
          const Text('MEWVIO Coins • Demo', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: previewPurchase,
            icon: const Icon(Icons.receipt_long_outlined), label: const Text('Transaction history'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white)),
        ]),
      ),
      const SizedBox(height: 25),
      const Text('Top up your vibe', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      const Text('Coin packs are shown for design preview only',
        style: TextStyle(color: Colors.white54, fontSize: 12)),
      const SizedBox(height: 15),
      GridView.builder(
        itemCount: packages.length, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1.03),
        itemBuilder: (context, i) {
          final pack = packages[i];
          final active = selectedPack == i;
          return InkWell(
            onTap: () => setState(() => selectedPack = i),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: active ? const Color(0xFF382042) : _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: active ? _pink : Colors.white10, width: active ? 2 : 1),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.paid_rounded, color: Color(0xFFFFD273), size: 27),
                const SizedBox(height: 6),
                Text('${pack.$1}', style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w900, fontSize: 19)),
                Text('US\$${pack.$2}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
            ),
          );
        },
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20)),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded, color: _cyan),
          SizedBox(width: 12),
          Expanded(child: Text('This is a non-transactional UI preview. No payment methods are connected.',
            style: TextStyle(color: Colors.white70, fontSize: 12))),
        ]),
      ),
      const SizedBox(height: 20),
      SizedBox(height: 52, child: FilledButton(
        onPressed: selectedPack == null ? null : previewPurchase,
        style: FilledButton.styleFrom(backgroundColor: _pink, disabledBackgroundColor: Color(0xFF413143)),
        child: const Text('Preview Coin Pack', style: TextStyle(fontWeight: FontWeight.w900)),
      )),
    ]),
  );
}
