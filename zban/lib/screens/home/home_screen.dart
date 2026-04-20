import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _QuickAddSheet(),
    );
  }

  Future<void> _openAnalytics() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => const _AnalyticsSheet(),
    );
  }

  Future<void> _openChatbot() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChatbotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _DashboardTab(),
      const _AccountsTab(),
      const SizedBox.shrink(),
      const _CalendarTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      endDrawer: _HomeDrawer(
        onOpenAnalytics: _openAnalytics,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1120), Color(0xFF070B14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: pages[_index]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openChatbot,
        backgroundColor: AppColors.primary,
        elevation: 8,
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        label: const Text(
          'AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      bottomNavigationBar: _HomeBottomNav(
        index: _index,
        onTap: _onTap,
      ),
    );
  }
}

class AppColors {
  static const bg = Color(0xFF070B14);
  static const surface = Color(0xFF111827);
  static const surface2 = Color(0xFF151D2E);
  static const border = Color(0xFF23304A);
  static const primary = Color(0xFF7C3AED);
  static const secondary = Color(0xFF22D3EE);
  static const text = Color(0xFFF8FAFC);
  static const muted = Color(0xFF94A3B8);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static const brandGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color.fromARGB(255, 32, 80, 87)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final name = session?.user.fullName ?? 'Хэрэглэгч';

    final data = ref.watch(financeProvider);

    return data.when(
      loading: () => const _PageLoader(),
      error: (e, _) => _ErrorState(
        title: 'Өгөгдөл татаж чадсангүй',
        subtitle: '$e',
        action: 'Дахин ачаалах',
        onTap: () => ref.read(financeProvider.notifier).load(),
      ),
      data: (snapshot) => RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.read(financeProvider.notifier).load(),
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            _DashboardHeader(name: name),
            const SizedBox(height: 20),
            _BalanceCard(snapshot: snapshot),
            const SizedBox(height: 18),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Сүүлийн гүйлгээ',
              subtitle: 'Таны хамгийн сүүлийн орлого, зарлагын бүртгэл',
            ),
            const SizedBox(height: 10),
            if (snapshot.transactions.isEmpty)
              const _EmptyGlassCard(
                text: 'Та одоогоор орлого, зарлага нэмээгүй байна.',
              )
            else
              _TxnList(items: snapshot.transactions.take(6).toList()),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Өр / Авлага',
              subtitle: 'Таны өглөг, авлагын товч мэдээлэл',
            ),
            const SizedBox(height: 10),
            if (snapshot.debts.isEmpty)
              const _EmptyGlassCard(
                text: 'Та одоогоор өр, авлагын мэдээлэл бүртгээгүй байна.',
              )
            else
              _DebtSummary(items: snapshot.debts),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Санхүүгийн товч дүгнэлт',
              subtitle: 'Одоогийн төлөвийн ерөнхий үзүүлэлт',
            ),
            const SizedBox(height: 10),
            _SummaryCards(snapshot: snapshot),
          ],
        ),
      ),
    );
  }

  void _showQuickAddFromPage(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _QuickAddSheet(),
    );
  }
}

class _AccountsTab extends ConsumerWidget {
  const _AccountsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(financeProvider);

    return data.when(
      loading: () => const _PageLoader(),
      error: (e, _) => _ErrorState(
        title: 'Дансны мэдээлэл ачаалж чадсангүй',
        subtitle: '$e',
        action: 'Дахин оролдох',
        onTap: () => ref.read(financeProvider.notifier).load(),
      ),
      data: (snapshot) => ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          const _PageTitle(
            title: 'Данснууд',
            subtitle: 'Таны бүх дансны үлдэгдэл, төрөл',
          ),
          const SizedBox(height: 16),
          if (snapshot.accounts.isEmpty)
            const _EmptyGlassCard(
              text:
                  'Та одоогоор данс нэмээгүй байна. Нэмэх товчоор данс үүсгэнэ үү.',
            )
          else
            ...snapshot.accounts.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AccountRow(account: a),
                )),
        ],
      ),
    );
  }
}

class _CalendarTab extends ConsumerWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = List<FinanceTransaction>.from(
      ref.watch(financeProvider).valueOrNull?.transactions ?? const [],
    )..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        const _PageTitle(
          title: 'Календарь',
          subtitle: 'Гүйлгээний огнооны дагуух хөдөлгөөн',
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          const _EmptyGlassCard(
            text: 'Календарийн өгөгдөл алга. Эхлээд гүйлгээ нэмнэ үү.',
          )
        else
          ...list.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CalendarTxnCard(txn: t),
            ),
          ),
      ],
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final snapshot = ref.watch(financeProvider).valueOrNull;

    final name = session?.user.fullName ?? 'Хэрэглэгч';
    final email = session?.user.email ?? 'no-email';
    final initials = _initials(name);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        const _PageTitle(
          title: 'Профайл',
          subtitle: 'Таны бүртгэл ба санхүүгийн ерөнхий төлөв',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _glassDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(initials: initials, size: 62),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfoCard(
                      title: 'Нийт үлдэгдэл',
                      value: '₮${_fmt(snapshot?.totalBalance ?? 0)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniInfoCard(
                      title: 'Нийт данс',
                      value: '${snapshot?.accounts.length ?? 0}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _ProfileMenuTile(
          icon: Icons.lock_outline_rounded,
          title: 'Аюулгүй байдал',
          subtitle: 'Нууц үг, нэвтрэх тохиргоо',
          onTap: () {
            _showComingSoon(
                context, 'Аюулгүй байдлын хэсэг удахгүй нэмэгдэнэ.');
          },
        ),
        const SizedBox(height: 12),
        _ProfileMenuTile(
          icon: Icons.notifications_none_rounded,
          title: 'Мэдэгдэл',
          subtitle: 'Сануулах болон дохиоллын тохиргоо',
          onTap: () {
            _showComingSoon(context, 'Мэдэгдлийн хэсэг удахгүй нэмэгдэнэ.');
          },
        ),
        const SizedBox(height: 12),
        _ProfileMenuTile(
          icon: Icons.palette_outlined,
          title: 'Өнгөний сэдэв',
          subtitle: 'UI theme болон брэнд өнгө',
          onTap: () {
            _showComingSoon(
                context, 'Theme тохиргоо дараагийн шатанд нэмэгдэнэ.');
          },
        ),
        const SizedBox(height: 12),
        _ProfileMenuTile(
          icon: Icons.logout_rounded,
          title: 'Гарах',
          subtitle: 'Бүртгэлээс гарах',
          danger: true,
          onTap: () => ref.read(authSessionProvider.notifier).logout(),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface2,
        content: Text(text),
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  final String name;
  const _DashboardHeader({required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сайн байна уу 👋',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.68),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        Builder(
          builder: (drawerContext) => InkWell(
            onTap: () => Scaffold.of(drawerContext).openEndDrawer(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 48,
              height: 48,
              decoration: _glassDecoration(),
              child: const Icon(
                Icons.menu_rounded,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final FinanceSnapshot snapshot;
  const _SummaryCards({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final savings = snapshot.accounts
        .where((e) => e.type.toUpperCase() == 'SAVINGS')
        .fold<int>(0, (sum, e) => sum + e.balance);

    final loans = snapshot.debts
        .where((e) => e.kind.toUpperCase() == 'LOAN')
        .fold<int>(0, (sum, e) => sum + e.amount);

    final receivables = snapshot.debts
        .where((e) => e.kind.toUpperCase() == 'RECEIVABLE')
        .fold<int>(0, (sum, e) => sum + e.amount);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                title: 'Хадгаламж',
                value: '₮${_fmt(savings)}',
                icon: Icons.savings_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                title: 'Өр',
                value: '₮${_fmt(loans)}',
                icon: Icons.trending_down_rounded,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Авлага',
          value: '₮${_fmt(receivables)}',
          icon: Icons.trending_up_rounded,
          color: AppColors.success,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _HomeDrawer extends ConsumerWidget {
  final Future<void> Function() onOpenAnalytics;
  const _HomeDrawer({
    required this.onOpenAnalytics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final name = session?.user.fullName ?? 'Хэрэглэгч';
    final email = session?.user.email ?? 'no-email';

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              _DrawerItem(
                icon: Icons.auto_graph_rounded,
                label: 'Шинжилгээ',
                onTap: () async {
                  Navigator.pop(context);
                  await onOpenAnalytics();
                },
              ),
              _DrawerItem(
                icon: Icons.savings_rounded,
                label: 'Хадгаламж',
                onTap: () {
                  Navigator.pop(context);
                  _showDrawerToast(context,
                      'Хадгаламжийн дэлгэрэнгүй хэсэг удахгүй нэмэгдэнэ.');
                },
              ),
              _DrawerItem(
                icon: Icons.payments_rounded,
                label: 'Зээл / Авлага',
                onTap: () {
                  Navigator.pop(context);
                  _showDrawerToast(
                      context, 'Зээл/Авлагын тусгай хэсэг удахгүй нэмэгдэнэ.');
                },
              ),
              _DrawerItem(
                icon: Icons.settings_rounded,
                label: 'Тохиргоо',
                onTap: () {
                  Navigator.pop(context);
                  _showDrawerToast(
                      context, 'Тохиргооны хэсэг удахгүй нэмэгдэнэ.');
                },
              ),
              _DrawerItem(
                icon: Icons.help_outline_rounded,
                label: 'Тусламж',
                onTap: () {
                  Navigator.pop(context);
                  _showDrawerToast(
                      context, 'Тусламжийн хэсэг удахгүй нэмэгдэнэ.');
                },
              ),
              const Spacer(),
              _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'Гарах',
                danger: true,
                onTap: () => ref.read(authSessionProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDrawerToast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface2,
        content: Text(text),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  final int index;
  final void Function(int) onTap;

  const _HomeBottomNav({
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.text
                : AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.text
                : AppColors.muted,
          ),
        ),
      ),
      child: NavigationBar(
        height: 76,
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0xFF1F2A44),
        selectedIndex: index,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Нүүр',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Данс',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_rounded),
            label: 'Нэмэх',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Календарь',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Профайл',
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final FinanceSnapshot snapshot;
  const _BalanceCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Column(
                children: [
                  Text(
                    'Орлого',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.78),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₮${_fmt(snapshot.totalBalance)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                children: [
                  Text(
                    'Зарлага',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.78),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₮${_fmt(snapshot.totalBalance)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassMiniStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _GlassMiniStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '₮$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: _glassDecoration(),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: t.type == 'INCOME'
                          ? AppColors.success.withOpacity(0.18)
                          : AppColors.danger.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      t.type == 'INCOME'
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: t.type == 'INCOME'
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ),
                  title: Text(
                    t.category ?? 'Ангилалгүй',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    '${t.accountName} • ${_date(t.occurredAt)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    '${t.type == 'INCOME' ? '+' : '-'}₮${_fmt(t.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: t.type == 'INCOME'
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DebtSummary extends StatelessWidget {
  final List<FinanceDebt> items;
  const _DebtSummary({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: _glassDecoration(),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: d.kind == 'LOAN'
                          ? AppColors.danger.withOpacity(0.18)
                          : AppColors.success.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      d.kind == 'LOAN'
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      color: d.kind == 'LOAN'
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                  title: Text(
                    d.kind == 'LOAN' ? 'Өр' : 'Авлага',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    d.counterparty,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    '₮${_fmt(d.amount)}',
                    style: TextStyle(
                      color: d.kind == 'LOAN'
                          ? AppColors.danger
                          : AppColors.success,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final FinanceAccount account;
  const _AccountRow({required this.account});

  @override
  Widget build(BuildContext context) {
    final icon = account.type.toUpperCase() == 'SAVINGS'
        ? Icons.savings_rounded
        : Icons.account_balance_wallet_rounded;

    return Container(
      decoration: _glassDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          account.name,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          account.type,
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          '₮${_fmt(account.balance)}',
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CalendarTxnCard extends StatelessWidget {
  final FinanceTransaction txn;
  const _CalendarTxnCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final positive = txn.type == 'INCOME';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: positive
                  ? AppColors.success.withOpacity(0.18)
                  : AppColors.danger.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              positive ? Icons.call_received_rounded : Icons.call_made_rounded,
              color: positive ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.category ?? 'Ангилалгүй',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${txn.accountName} • ${_date(txn.occurredAt)}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${positive ? '+' : '-'}₮${_fmt(txn.amount)}',
            style: TextStyle(
              color: positive ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final String title;
  final String value;
  const _MiniInfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.text;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: danger
                    ? AppColors.danger.withOpacity(0.18)
                    : AppColors.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsSheet extends ConsumerWidget {
  const _AnalyticsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(financeProvider).valueOrNull;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                const _PageTitle(
                  title: 'Шинжилгээ',
                  subtitle: 'Санхүүгийн гол үзүүлэлтүүдийн товч тойм',
                ),
                const SizedBox(height: 18),
                _InfoCard(
                  title: 'Нийт орлого',
                  value: '₮${_fmt(s?.totalIncome ?? 0)}',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.success,
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Нийт зарлага',
                  value: '₮${_fmt(s?.totalExpense ?? 0)}',
                  icon: Icons.trending_down_rounded,
                  color: AppColors.danger,
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Одоогийн үлдэгдэл',
                  value: '₮${_fmt(s?.totalBalance ?? 0)}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.secondary,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatbotSheet extends ConsumerWidget {
  const _ChatbotSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(financeProvider).valueOrNull;
    final topExpense = _topExpenseCategory(snapshot?.transactions ?? const []);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Санхүүгийн Туслах',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Хурдан дүгнэлт ба асуултын санаанууд',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _BotInsightCard(
                  title: 'Одоогийн үлдэгдэл',
                  value: '₮${_fmt(snapshot?.totalBalance ?? 0)}',
                ),
                const SizedBox(height: 12),
                _BotInsightCard(
                  title: 'Нийт зарлага',
                  value: '₮${_fmt(snapshot?.totalExpense ?? 0)}',
                ),
                const SizedBox(height: 12),
                _BotInsightCard(
                  title: 'Хамгийн их зардалтай ангилал',
                  value: topExpense ?? 'Мэдээлэл хангалтгүй',
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _BotQuestionChip(
                        label: 'Энэ сарын зарлага хэд вэ?',
                        onTap: () => _askStub(
                          context,
                          'Энэ хэсгийг chatbot backend-тэй холбоход бодит хариу гарна.',
                        ),
                      ),
                      _BotQuestionChip(
                        label: 'Хэрхэн хадгаламж өсгөх вэ?',
                        onTap: () => _askStub(
                          context,
                          'Savings insight хэсгийг дараагийн шатанд AI зөвлөмжтэй холбоно.',
                        ),
                      ),
                      _BotQuestionChip(
                        label: 'Миний мөнгөн урсгал ямар байна?',
                        onTap: () => _askStub(
                          context,
                          'Cash flow summary-г AI engine-тэй холбоход бүрэн ажиллана.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _askStub(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface2,
        content: Text(text),
      ),
    );
  }
}

class _BotInsightCard extends StatelessWidget {
  final String title;
  final String value;

  const _BotInsightCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotQuestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BotQuestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: AppColors.surface2,
      side: const BorderSide(color: AppColors.border),
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
      ),
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
          _sheetField(
            controller: name,
            label: 'Нэр',
          ),
          const SizedBox(height: 12),
          _sheetField(
            controller: balance,
            label: 'Эхний үлдэгдэл',
            keyboardType: TextInputType.number,
          ),
        ],
        onSave: () async {
          if (name.text.trim().isEmpty) {
            _toast(context, 'Нэрээ оруулна уу.');
            return;
          }

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

      if (snapshot == null || snapshot.accounts.isEmpty) {
        _toast(context, 'Эхлээд данс нэмнэ үү.');
        return;
      }

      final amount = TextEditingController();
      final category = TextEditingController();
      final note = TextEditingController();
      String accountId = snapshot.accounts.first.id;

      await showDialog<void>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.border),
              ),
              title: Text(
                type == 'INCOME' ? 'Орлого нэмэх' : 'Зарлага нэмэх',
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.surface2,
                    value: accountId,
                    items: snapshot.accounts
                        .map(
                          (a) => DropdownMenuItem<String>(
                            value: a.id,
                            child: Text(
                              a.name,
                              style: const TextStyle(color: AppColors.text),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => accountId = v ?? accountId);
                    },
                    style: const TextStyle(color: AppColors.text),
                    decoration: _inputDecoration('Данс'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.text),
                    decoration: _inputDecoration('Дүн'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: category,
                    style: const TextStyle(color: AppColors.text),
                    decoration: _inputDecoration('Ангилал'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: note,
                    style: const TextStyle(color: AppColors.text),
                    decoration: _inputDecoration('Тайлбар'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Болих',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () async {
                    final value = int.tryParse(amount.text.trim()) ?? 0;
                    if (value <= 0) {
                      _toast(context, 'Дүнгээ зөв оруулна уу.');
                      return;
                    }

                    await ref.read(financeProvider.notifier).addTransaction(
                          accountId: accountId,
                          type: type,
                          amount: value,
                          category: category.text.trim().isEmpty
                              ? null
                              : category.text.trim(),
                          note: note.text.trim().isEmpty
                              ? null
                              : note.text.trim(),
                        );

                    if (context.mounted) Navigator.pop(dialogContext);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Хадгалах'),
                ),
              ],
            );
          },
        ),
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
          _sheetField(
            controller: who,
            label: 'Харилцагч',
          ),
          const SizedBox(height: 12),
          _sheetField(
            controller: amount,
            label: 'Дүн',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _sheetField(
            controller: note,
            label: 'Тайлбар',
          ),
        ],
        onSave: () async {
          final value = int.tryParse(amount.text.trim()) ?? 0;

          if (who.text.trim().isEmpty || value <= 0) {
            _toast(context, 'Мэдээллээ зөв оруулна уу.');
            return;
          }

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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Wrap(
            runSpacing: 12,
            spacing: 12,
            children: [
              const _BottomSheetGrabber(),
              _QuickAction(
                label: 'Орлого',
                icon: Icons.add_card_rounded,
                onTap: () => addTxn('INCOME'),
              ),
              _QuickAction(
                label: 'Зарлага',
                icon: Icons.remove_circle_outline_rounded,
                onTap: () => addTxn('EXPENSE'),
              ),
              _QuickAction(
                label: 'Зээл нэмэх',
                icon: Icons.payments_rounded,
                onTap: () => addDebt('LOAN'),
              ),
              _QuickAction(
                label: 'Хадгаламж нэмэх',
                icon: Icons.savings_rounded,
                onTap: () => addAccount('SAVINGS'),
              ),
              _QuickAction(
                label: 'Хүнээс авлагатай',
                icon: Icons.trending_up_rounded,
                onTap: () => addDebt('RECEIVABLE'),
              ),
              _QuickAction(
                label: 'Данс нэмэх',
                icon: Icons.account_balance_wallet_rounded,
                onTap: () => addAccount('BANK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetGrabber extends StatelessWidget {
  const _BottomSheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 52,
        height: 5,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(999),
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
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: fields,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Болих',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          onPressed: onSave,
          child: const Text('Хадгалах'),
        ),
      ],
    ),
  );
}

Widget _sheetField({
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(color: AppColors.text),
    decoration: _inputDecoration(label),
  );
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.muted),
    filled: true,
    fillColor: AppColors.surface2,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.border),
    ),
  );
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.surface2,
      content: Text(msg),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.secondary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _EmptyGlassCard extends StatelessWidget {
  final String text;
  const _EmptyGlassCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _glassDecoration(),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PageLoader extends StatelessWidget {
  const _PageLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;

  const _ErrorState({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _glassDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: onTap,
                child: Text(action),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const _Avatar({
    required this.initials,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.32,
          ),
        ),
      ),
    );
  }
}

BoxDecoration _glassDecoration() {
  return BoxDecoration(
    color: AppColors.surface.withOpacity(0.88),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: AppColors.border),
    boxShadow: const [
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 18,
        offset: Offset(0, 10),
      ),
    ],
  );
}

String _fmt(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final pos = s.length - i;
    b.write(s[i]);
    if (pos > 1 && pos % 3 == 1) {
      b.write(',');
    }
  }
  return b.toString();
}

String _date(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}

String _initials(String name) {
  final parts =
      name.trim().split(' ').where((e) => e.trim().isNotEmpty).take(2).toList();

  if (parts.isEmpty) return 'AM';
  return parts.map((e) => e[0].toUpperCase()).join();
}

String? _topExpenseCategory(List<FinanceTransaction> txns) {
  final map = <String, int>{};

  for (final t in txns) {
    if (t.type != 'EXPENSE') continue;
    final key = (t.category == null || t.category!.trim().isEmpty)
        ? 'Ангилалгүй'
        : t.category!.trim();
    map[key] = (map[key] ?? 0) + t.amount;
  }

  if (map.isEmpty) return null;

  final sorted = map.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return '${sorted.first.key} • ₮${_fmt(sorted.first.value)}';
}
