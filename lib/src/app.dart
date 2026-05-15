import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/admin/view/admin_page.dart';
import 'features/contact/view/contact_us_page.dart';
import 'features/portfolio/bloc/portfolio_bloc.dart';
import 'features/portfolio/data/portfolio_backend.dart';
import 'features/portfolio/data/editable_portfolio_store.dart';
import 'features/portfolio/view/portfolio_page.dart';

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  late final EditablePortfolioStore _store;

  @override
  void initState() {
    super.initState();
    _store = EditablePortfolioStore(backend: PortfolioBackend.instance);
    _store.loadRemote();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PortfolioScope(
      store: _store,
      child: BlocProvider(
        create: (_) => PortfolioBloc(),
        child: MaterialApp(
          title: 'Aniket Parihar | Flutter Engineer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: false,
          ),
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  Route<void> _onGenerateRoute(RouteSettings settings) {
    final routeName = _normalizeRoute(settings.name);

    return MaterialPageRoute<void>(
      settings: RouteSettings(name: routeName),
      builder: (_) => switch (routeName) {
        '/admin' => const AdminPage(),
        '/contact-us' => const ContactUsPage(),
        _ => const PortfolioPage(),
      },
    );
  }

  String _normalizeRoute(String? routeName) {
    final raw = (routeName == null || routeName.isEmpty) ? '/' : routeName;
    final withoutQuery = raw.split('?').first.split('#').first;
    final normalized = withoutQuery.endsWith('/') && withoutQuery.length > 1
        ? withoutQuery.substring(0, withoutQuery.length - 1)
        : withoutQuery;

    return switch (normalized) {
      'admin' || '/admin' => '/admin',
      'contact-us' || '/contact-us' => '/contact-us',
      _ => '/',
    };
  }
}
