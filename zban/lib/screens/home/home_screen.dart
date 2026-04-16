import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_controller.dart';
import '../../app/finance/finance_controller.dart';
import '../../app/finance/finance_models.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  void _onTap(int i) {
    if (i == 2) {
      _openQuickAdd();
      return;
    }
    setState(() => _index = i);
  }

  Future<void> _openQuickAdd() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => const _QuickAddSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _DashboardTab(),
      const _AccountsTab(),
      const SizedBox.shrink(),
      const _CalendarTab(),
      const _AnalyticsTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: _HomeBottomNav(index: _index, onTap: _onTap),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final name = session?.user.fullName ?? 'Хэрэглэгч';
    final initials = name.trim().isEmpty
        ? 'XX'
        : name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

    final data = ref.watch(financeProvider);
    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _EmptyState(
        title: 'Өгөгдөл татаж чадсангүй',
        subtitle: '$e',
        action: 'Дахин ачаалах',
        onTap: () => ref.read(financeProvider.notifier).load(),
      ),
      data: (snapshot) => RefreshIndicator(
        onRefresh: () => ref.read(financeProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Сайн байна уу',
                          style: TextStyle(fontSize: 12, color: Color(0xFF748197))),
                      const SizedBox(height: 2),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0B1220))),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(authSessionProvider.notifier).logout(),
                  icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFF748197)),
                ),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: _Avatar(initials: initials),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _BalanceCard(snapshot: snapshot),
            const SizedBox(height: 16),
            const _SectionTitle('Сүүлийн гүйлгээ'),
            const SizedBox(height: 8),
            if (snapshot.transactions.isEmpty)
              _EmptyCard(
                text: 'Та одоохондоо орлого/зарлага нэмээгүй байна. Доорх "+" дээр дарж нэмнэ үү.',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Гүйлгээ нэмэхийн тулд "+" дарна уу.'))),
              )
            else
              _TxnList(items: snapshot.transactions.take(8).toList()),
            const SizedBox(height: 16),
            const _SectionTitle('Өр / Авлага'),
            const SizedBox(height: 8),
            if (snapshot.debts.isEmpty)
              _EmptyCard(
                text: 'Та өр/авлага бүртгээгүй байна. "+" дээр дарж нэмнэ үү.',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Өр/Авлага нэмэхийн тулд "+" дарна уу.'))),
              )
            else
              _DebtList(items: snapshot.debts),
          ],
        ),
      ),
    );
  }
}

class _AccountsTab extends ConsumerWidget {
  const _AccountsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(financeProvider);
    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (snapshot) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
        children: [
          const Text('Данснууд',
              style: TextStyle(color: Color(0xFF0B1220), fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 12),
          if (snapshot.accounts.isEmpty)
            _EmptyCard(
              text: 'Та одоогоор данс нэмээгүй байна. "+" дээр дарж данс нэмнэ үү.',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Данс нэмэхийн тулд "+" дарна уу.'))),
            )
          else
            ...snapshot.accounts.map((a) => _AccountRow(account: a)),
        ],
      ),
    );
  }
}

class _CalendarTab extends ConsumerWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = List<FinanceTransaction>.from(ref.watch(financeProvider).valueOrNull?.transactions ?? const []);
    list.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        const Text('Календарь',
            style: TextStyle(color: Color(0xFF0B1220), fontWeight: FontWeight.w800, fontSize: 22)),
        const SizedBox(height: 10),
        if (list.isEmpty)
          const _EmptyCardStatic(text: 'Календарийн өгөгдөл алга. Эхлээд гүйлгээ нэмнэ үү.')
        else
          ...list.map((t) => Card(
                child: ListTile(
                  title: Text('${_date(t.occurredAt)} • ${t.category ?? 'Ангилалгүй'}'),
                  subtitle: Text(t.accountName),
                  trailing: Text(
                    '${t.type == 'INCOME' ? '+' : '-'}₮${_fmt(t.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: t.type == 'INCOME'
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}

class _AnalyticsTab extends ConsumerWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(financeProvider).valueOrNull;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        const Text('Шинжилгээ',
            style: TextStyle(color: Color(0xFF0B1220), fontWeight: FontWeight.w800, fontSize: 22)),
        const SizedBox(height: 12),
        _StatCard(title: 'Нийт орлого', value: _fmt(s?.totalIncome ?? 0), color: const Color(0xFF059669)),
        const SizedBox(height: 10),
        _StatCard(title: 'Нийт зарлага', value: _fmt(s?.totalExpense ?? 0), color: const Color(0xFFDC2626)),
        const SizedBox(height: 10),
        _StatCard(title: 'Одоогийн үлдэгдэл', value: _fmt(s?.totalBalance ?? 0), color: const Color(0xFF2563EB)),
      ],
    );
  }
}

class _QuickAddSheet extends ConsumerWidget {
  const _QuickAddSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> addAccount(String type) async {
      final name = TextEditingController();
      final balance = TextEditingController();
      await _formDialog(
        context: context,
        title: type == 'SAVINGS' ? 'Хадгаламж нэмэх' : 'Данс нэмэх',
        fields: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Нэр')),
          const SizedBox(height: 10),
          TextField(controller: balance, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Эхний үлдэгдэл')),
        ],
        onSave: () async {
          if (name.text.trim().isEmpty) return _toast(context, 'Нэрээ оруулна уу.');
          await ref.read(financeProvider.notifier).addAccount(
                name: name.text.trim(),
                type: type,
                balance: int.tryParse(balance.text.trim()) ?? 0,
              );
          if (context.mounted) Navigator.pop(context);
          if (context.mounted) Navigator.pop(context);
        },
      );
    }

    Future<void> addTxn(String type) async {
      final snapshot = ref.read(financeProvider).valueOrNull;
      if (snapshot == null || snapshot.accounts.isEmpty) return _toast(context, 'Эхлээд данс нэмнэ үү.');
      final amount = TextEditingController();
      final category = TextEditingController();
      final note = TextEditingController();
      String accountId = snapshot.accounts.first.id;
      await showDialog(
        context: context,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(type == 'INCOME' ? 'Орлого нэмэх' : 'Зарлага нэмэх'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: accountId,
                  items: snapshot.accounts
                      .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                      .toList(),
                  onChanged: (v) => setState(() => accountId = v ?? accountId),
                  decoration: const InputDecoration(labelText: 'Данс'),
                ),
                const SizedBox(height: 10),
                TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Дүн')),
                const SizedBox(height: 10),
                TextField(controller: category, decoration: const InputDecoration(labelText: 'Ангилал')),
                const SizedBox(height: 10),
                TextField(controller: note, decoration: const InputDecoration(labelText: 'Тайлбар')),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Болих')),
              FilledButton(
                onPressed: () async {
                  final value = int.tryParse(amount.text.trim()) ?? 0;
                  if (value <= 0) return _toast(context, 'Дүнгээ зөв оруулна уу.');
                  await ref.read(financeProvider.notifier).addTransaction(
                        accountId: accountId,
                        type: type,
                        amount: value,
                        category: category.text.trim().isEmpty ? null : category.text.trim(),
                        note: note.text.trim().isEmpty ? null : note.text.trim(),
                      );
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Хадгалах'),
              ),
            ],
          );
        }),
      );
    }

    Future<void> addDebt(String kind) async {
      final who = TextEditingController();
      final amount = TextEditingController();
      final note = TextEditingController();
      await _formDialog(
        context: context,
        title: kind == 'LOAN' ? 'Өр нэмэх' : 'Авлага нэмэх',
        fields: [
          TextField(controller: who, decoration: const InputDecoration(labelText: 'Харилцагч')),
          const SizedBox(height: 10),
          TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Дүн')),
          const SizedBox(height: 10),
          TextField(controller: note, decoration: const InputDecoration(labelText: 'Тайлбар')),
        ],
        onSave: () async {
          final value = int.tryParse(amount.text.trim()) ?? 0;
          if (who.text.trim().isEmpty || value <= 0) return _toast(context, 'Мэдээллээ зөв оруулна уу.');
          await ref.read(financeProvider.notifier).addDebt(
                kind: kind,
                counterparty: who.text.trim(),
                amount: value,
                note: note.text.trim().isEmpty ? null : note.text.trim(),
              );
          if (context.mounted) Navigator.pop(context);
          if (context.mounted) Navigator.pop(context);
        },
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Wrap(
          runSpacing: 10,
          spacing: 10,
          children: [
            _QuickAction(label: 'Орлого', onTap: () => addTxn('INCOME')),
            _QuickAction(label: 'Зарлага', onTap: () => addTxn('EXPENSE')),
            _QuickAction(label: 'Зээл нэмэх', onTap: () => addDebt('LOAN')),
            _QuickAction(label: 'Хадгаламж нэмэх', onTap: () => addAccount('SAVINGS')),
            _QuickAction(label: 'Хүнд өртэй', onTap: () => addDebt('LOAN')),
            _QuickAction(label: 'Хүнээс авлагатай', onTap: () => addDebt('RECEIVABLE')),
            _QuickAction(label: 'Данс нэмэх', onTap: () => addAccount('BANK')),
          ],
        ),
      ),
    );
  }
}

Future<void> _formDialog({
  required BuildContext context,
  required String title,
  required List<Widget> fields,
  required Future<void> Function() onSave,
}) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Column(mainAxisSize: MainAxisSize.min, children: fields),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Болих')),
        FilledButton(onPressed: onSave, child: const Text('Хадгалах')),
      ],
    ),
  );
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class _QuickAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E6EE)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  final int index;
  final void Function(int) onTap;
  const _HomeBottomNav({required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onTap,
      destinations: [
        const NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Самбар'),
        const NavigationDestination(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Данснууд'),
        NavigationDestination(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          label: 'Нэмэх',
        ),
        const NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
        const NavigationDestination(icon: Icon(Icons.auto_graph_rounded), label: 'Шинжилгээ'),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final FinanceSnapshot snapshot;
  const _BalanceCard({required this.snapshot});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E6EE)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('НИЙТ ҮЛДЭГДЭЛ', style: TextStyle(fontSize: 11, color: Color(0xFF748197))),
        const SizedBox(height: 6),
        Text('₮${_fmt(snapshot.totalBalance)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0B1220))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatMini(title: 'Орлого', value: _fmt(snapshot.totalIncome), good: true)),
            const SizedBox(width: 10),
            Expanded(child: _StatMini(title: 'Зарлага', value: _fmt(snapshot.totalExpense), good: false)),
          ],
        )
      ]),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String title;
  final String value;
  final bool good;
  const _StatMini({required this.title, required this.value, required this.good});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: good ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF748197))),
        const SizedBox(height: 4),
        Text('₮$value',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: good ? const Color(0xFF059669) : const Color(0xFFDC2626))),
      ]),
    );
  }
}

class _TxnList extends StatelessWidget {
  final List<FinanceTransaction> items;
  const _TxnList({required this.items});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((t) => Card(
                child: ListTile(
                  title: Text(t.category ?? 'Ангилалгүй'),
                  subtitle: Text('${t.accountName} • ${_date(t.occurredAt)}'),
                  trailing: Text(
                    '${t.type == 'INCOME' ? '+' : '-'}₮${_fmt(t.amount)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: t.type == 'INCOME'
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626)),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _DebtList extends StatelessWidget {
  final List<FinanceDebt> items;
  const _DebtList({required this.items});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((d) => Card(
                child: ListTile(
                  title: Text(d.kind == 'LOAN' ? 'Өр' : 'Авлага'),
                  subtitle: Text(d.counterparty),
                  trailing: Text('₮${_fmt(d.amount)}',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: d.kind == 'LOAN'
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF059669))),
                ),
              ))
          .toList(),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final FinanceAccount account;
  const _AccountRow({required this.account});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet_rounded),
        title: Text(account.name),
        subtitle: Text(account.type),
        trailing: Text('₮${_fmt(account.balance)}',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text('₮$value', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
      child: Center(
        child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11, color: Color(0xFF748197), letterSpacing: 1.0, fontWeight: FontWeight.w700));
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _EmptyCard({required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E6EE)),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xFF5B6474), fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _EmptyCardStatic extends StatelessWidget {
  final String text;
  const _EmptyCardStatic({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E6EE)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF5B6474), fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onTap, child: Text(action)),
        ]),
      ),
    );
  }
}

String _fmt(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final pos = s.length - i;
    b.write(s[i]);
    if (pos > 1 && pos % 3 == 1) b.write(',');
  }
  return b.toString();
}

String _date(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}

