import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../portfolio/data/editable_portfolio_store.dart';
import '../../portfolio/data/portfolio_backend.dart';
import '../../portfolio/models/portfolio_models.dart';
import '../../portfolio/utils/platform_file_picker.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _unlocked = false;
  bool _loading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    PortfolioBackend.instance.isAdmin().then((allowed) {
      if (mounted && allowed) {
        setState(() => _unlocked = true);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final backend = PortfolioBackend.instance;
    if (!backend.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Firebase config missing. Add dart-defines first.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await backend.signInAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      setState(() => _unlocked = true);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppPalette.canvas, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: _unlocked
                    ? const _AdminDashboard()
                    : _AdminLogin(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        loading: _loading,
                        onUnlock: _unlock,
                        titleStyle: theme.textTheme.headlineMedium,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminLogin extends StatelessWidget {
  const _AdminLogin({
    required this.emailController,
    required this.passwordController,
    required this.loading,
    required this.onUnlock,
    required this.titleStyle,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool loading;
  final VoidCallback onUnlock;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: AppPalette.line),
          boxShadow: [
            BoxShadow(
              color: AppPalette.ink.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portfolio Admin', style: titleStyle),
            const SizedBox(height: 10),
            const Text(
              'Secure Firebase Auth login for editing production portfolio content.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Admin email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              onSubmitted: (_) => onUnlock(),
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: loading ? null : onUnlock,
                  icon: loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_open_rounded),
                  label: const Text('Login'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context) {
    final content = PortfolioScope.of(context);

    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          _AdminTopBar(content: content),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppPalette.line),
            ),
            child: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Profile'),
                Tab(text: 'Hero'),
                Tab(text: 'Projects'),
                Tab(text: 'Experience'),
                Tab(text: 'Skills'),
                Tab(text: 'Contact'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _ProfileAdmin(content: content),
                _HeroAdmin(content: content),
                _ProjectsAdmin(content: content),
                _ExperienceAdmin(content: content),
                _SkillsAdmin(content: content),
                _ContactAdmin(content: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({required this.content});

  final EditablePortfolioStore content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppPalette.heroGradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: AppPalette.accentGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: const Text(
              'AP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Admin Panel',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Edit, add, delete and upload content for ${content.name}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Preview'),
              ),
              FilledButton.icon(
                onPressed: content.resetAll,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppPalette.ink,
                ),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAdmin extends StatefulWidget {
  const _ProfileAdmin({required this.content});

  final EditablePortfolioStore content;

  @override
  State<_ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<_ProfileAdmin> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final content = widget.content;
    _controllers = {
      'name': TextEditingController(text: content.name),
      'title': TextEditingController(text: content.title),
      'headline': TextEditingController(text: content.headline),
      'summary': TextEditingController(text: content.summary),
      'location': TextEditingController(text: content.location),
      'phone': TextEditingController(text: content.phone),
      'email': TextEditingController(text: content.email),
      'profileAsset': TextEditingController(text: content.profileAsset),
      'linkedIn': TextEditingController(text: content.linkedIn),
      'github': TextEditingController(text: content.github),
      'codeChef': TextEditingController(text: content.codeChef),
      'educationTitle': TextEditingController(text: content.educationTitle),
      'educationSchool': TextEditingController(text: content.educationSchool),
      'educationPeriod': TextEditingController(text: content.educationPeriod),
      'educationResult': TextEditingController(text: content.educationResult),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await pickImageAsset();
    if (picked == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Image upload is available on Flutter Web.'),
          ),
        );
      }
      return;
    }

    var profileSource = picked.dataUrl;
    var uploadedToStorage = false;
    final backend = widget.content.backend;
    if (backend != null && backend.isConfigured) {
      try {
        profileSource = await backend.uploadProfileImage(
          fileName: picked.name,
          bytes: picked.bytes,
          mimeType: picked.mimeType,
        );
        uploadedToStorage = true;
      } catch (_) {
        if (picked.bytes.lengthInBytes > 700 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  'Firebase Storage is not enabled. Use a compressed image under 700 KB or paste an image URL.',
                ),
              ),
            );
          }
          return;
        }
      }
    }

    _controllers['profileAsset']!.text = profileSource;
    widget.content.updateProfileAsset(profileSource);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            uploadedToStorage
                ? 'Uploaded ${picked.name}'
                : 'Saved ${picked.name} without Firebase Storage',
          ),
        ),
      );
    }
  }

  void _save() {
    widget.content.updateProfile(
      name: _controllers['name']!.text,
      title: _controllers['title']!.text,
      headline: _controllers['headline']!.text,
      summary: _controllers['summary']!.text,
      location: _controllers['location']!.text,
      phone: _controllers['phone']!.text,
      email: _controllers['email']!.text,
      linkedIn: _controllers['linkedIn']!.text,
      github: _controllers['github']!.text,
      codeChef: _controllers['codeChef']!.text,
      educationTitle: _controllers['educationTitle']!.text,
      educationSchool: _controllers['educationSchool']!.text,
      educationPeriod: _controllers['educationPeriod']!.text,
      educationResult: _controllers['educationResult']!.text,
    );
    widget.content.updateProfileAsset(_controllers['profileAsset']!.text);
    _showSaved(context);
  }

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: ListView(
        children: [
          _SectionTitle(
            title: 'Profile, links and education',
            action: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Profile'),
            ),
          ),
          const SizedBox(height: 18),
          _AdminGrid(
            children: [
              _AdminField(controller: _controllers['name']!, label: 'Name'),
              _AdminField(controller: _controllers['title']!, label: 'Title'),
              _AdminField(
                controller: _controllers['headline']!,
                label: 'Headline',
              ),
              _AdminField(
                controller: _controllers['location']!,
                label: 'Location',
              ),
              _AdminField(controller: _controllers['phone']!, label: 'Phone'),
              _AdminField(controller: _controllers['email']!, label: 'Email'),
              _AdminField(
                controller: _controllers['linkedIn']!,
                label: 'LinkedIn',
              ),
              _AdminField(controller: _controllers['github']!, label: 'GitHub'),
              _AdminField(
                controller: _controllers['codeChef']!,
                label: 'CodeChef',
              ),
              _AdminField(
                controller: _controllers['educationTitle']!,
                label: 'Education title',
              ),
              _AdminField(
                controller: _controllers['educationSchool']!,
                label: 'Education school',
              ),
              _AdminField(
                controller: _controllers['educationPeriod']!,
                label: 'Education period',
              ),
              _AdminField(
                controller: _controllers['educationResult']!,
                label: 'Education result',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AdminField(
            controller: _controllers['summary']!,
            label: 'Summary',
            minLines: 4,
            maxLines: 6,
          ),
          const SizedBox(height: 14),
          _AdminField(
            controller: _controllers['profileAsset']!,
            label: 'Profile image asset or URL',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_rounded),
                label: const Text('Upload Profile Image'),
              ),
              OutlinedButton.icon(
                onPressed: () => widget.content.updateProfileAsset(
                  'assets/images/aniket_profile_cutout.png',
                ),
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Restore Default Image'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroAdmin extends StatelessWidget {
  const _HeroAdmin({required this.content});

  final EditablePortfolioStore content;

  @override
  Widget build(BuildContext context) {
    final tagsController = TextEditingController(
      text: content.heroTags.join(', '),
    );

    return _AdminCard(
      child: ListView(
        children: [
          _SectionTitle(
            title: 'Hero tags, stats and achievements',
            action: FilledButton.icon(
              onPressed: () {
                content.updateHeroTags(_splitComma(tagsController.text));
                _showSaved(context);
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Tags'),
            ),
          ),
          const SizedBox(height: 16),
          _AdminField(
            controller: tagsController,
            label: 'Hero tags comma separated',
          ),
          const SizedBox(height: 24),
          _EditableList<PortfolioStat>(
            title: 'Stats',
            items: content.stats,
            itemTitle: (item) => '${item.value} ${item.label}',
            itemSubtitle: (item) => item.detail,
            onAdd: () => _editStat(context, content, null, null),
            onEdit: (index, item) => _editStat(context, content, index, item),
            onDelete: content.deleteStat,
          ),
          const SizedBox(height: 24),
          _EditableList<AchievementItem>(
            title: 'Achievements',
            items: content.achievements,
            itemTitle: (item) => '${item.value} ${item.label}',
            itemSubtitle: (_) => 'Achievement',
            onAdd: () => _editAchievement(context, content, null, null),
            onEdit: (index, item) =>
                _editAchievement(context, content, index, item),
            onDelete: content.deleteAchievement,
          ),
        ],
      ),
    );
  }
}

class _ProjectsAdmin extends StatelessWidget {
  const _ProjectsAdmin({required this.content});

  final EditablePortfolioStore content;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: _EditableList<ProjectItem>(
        title: 'Projects',
        items: content.projects,
        itemTitle: (item) => item.title,
        itemSubtitle: (item) => '${item.category} • ${item.timeline}',
        onAdd: () => _editProject(context, content, null, null),
        onEdit: (index, item) => _editProject(context, content, index, item),
        onDelete: content.deleteProject,
      ),
    );
  }
}

class _ExperienceAdmin extends StatelessWidget {
  const _ExperienceAdmin({required this.content});

  final EditablePortfolioStore content;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: _EditableList<ExperienceItem>(
        title: 'Experience',
        items: content.experience,
        itemTitle: (item) => item.role,
        itemSubtitle: (item) => '${item.company} • ${item.period}',
        onAdd: () => _editExperience(context, content, null, null),
        onEdit: (index, item) => _editExperience(context, content, index, item),
        onDelete: content.deleteExperience,
      ),
    );
  }
}

class _SkillsAdmin extends StatelessWidget {
  const _SkillsAdmin({required this.content});

  final EditablePortfolioStore content;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: _EditableList<SkillCategory>(
        title: 'Skill categories',
        items: content.skillCategories,
        itemTitle: (item) => item.title,
        itemSubtitle: (item) => item.items.join(', '),
        onAdd: () => _editSkill(context, content, null, null),
        onEdit: (index, item) => _editSkill(context, content, index, item),
        onDelete: content.deleteSkillCategory,
      ),
    );
  }
}

class _ContactAdmin extends StatelessWidget {
  const _ContactAdmin({required this.content});

  final EditablePortfolioStore content;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: _EditableList<ContactAction>(
        title: 'Contact actions',
        items: content.contactActions,
        itemTitle: (item) => item.title,
        itemSubtitle: (item) => '${item.subtitle} • ${item.url}',
        onAdd: () => _editContact(context, content, null, null),
        onEdit: (index, item) => _editContact(context, content, index, item),
        onDelete: content.deleteContactAction,
      ),
    );
  }
}

class _EditableList<T> extends StatelessWidget {
  const _EditableList({
    required this.title,
    required this.items,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final List<T> items;
  final String Function(T item) itemTitle;
  final String Function(T item) itemSubtitle;
  final VoidCallback onAdd;
  final void Function(int index, T item) onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        _SectionTitle(
          title: title,
          action: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add New'),
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const _EmptyState()
        else
          for (int index = 0; index < items.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AdminListTile(
                title: itemTitle(items[index]),
                subtitle: itemSubtitle(items[index]),
                onEdit: () => onEdit(index, items[index]),
                onDelete: () => onDelete(index),
              ),
            ),
      ],
    );
  }
}

class _AdminListTile extends StatelessWidget {
  const _AdminListTile({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppPalette.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppPalette.line),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _AdminGrid extends StatelessWidget {
  const _AdminGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 780;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final child in children)
              SizedBox(
                width: compact
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 14) / 2,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

class _AdminField extends StatelessWidget {
  const _AdminField({
    required this.controller,
    required this.label,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppPalette.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppPalette.line),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text('No items yet. Add a new item to show it on website.'),
    );
  }
}

Future<void> _editProject(
  BuildContext context,
  EditablePortfolioStore content,
  int? index,
  ProjectItem? item,
) async {
  final title = TextEditingController(text: item?.title ?? '');
  final category = TextEditingController(text: item?.category ?? '');
  final timeline = TextEditingController(text: item?.timeline ?? '');
  final description = TextEditingController(text: item?.description ?? '');
  final contribution = TextEditingController(text: item?.contribution ?? '');
  final highlights = TextEditingController(
    text: item?.highlights.join('\n') ?? '',
  );
  final stack = TextEditingController(text: item?.stack.join(', ') ?? '');

  await _showEditor(
    context,
    titleText: index == null ? 'Add Project' : 'Edit Project',
    fields: [
      _AdminField(controller: title, label: 'Title'),
      _AdminField(controller: category, label: 'Category'),
      _AdminField(controller: timeline, label: 'Timeline'),
      _AdminField(
        controller: description,
        label: 'Description',
        minLines: 3,
        maxLines: 5,
      ),
      _AdminField(
        controller: contribution,
        label: 'Contribution',
        minLines: 2,
        maxLines: 4,
      ),
      _AdminField(
        controller: highlights,
        label: 'Highlights, one per line',
        minLines: 4,
        maxLines: 6,
      ),
      _AdminField(controller: stack, label: 'Stack comma separated'),
    ],
    onSave: () {
      content.upsertProject(
        index,
        ProjectItem(
          id: item?.id ?? _slug(title.text),
          title: title.text.trim(),
          category: category.text.trim(),
          timeline: timeline.text.trim(),
          description: description.text.trim(),
          contribution: contribution.text.trim(),
          highlights: _splitLines(highlights.text),
          stack: _splitComma(stack.text),
        ),
      );
    },
  );
}

Future<void> _editExperience(
  BuildContext context,
  EditablePortfolioStore content,
  int? index,
  ExperienceItem? item,
) async {
  final role = TextEditingController(text: item?.role ?? '');
  final company = TextEditingController(text: item?.company ?? '');
  final period = TextEditingController(text: item?.period ?? '');
  final location = TextEditingController(text: item?.location ?? '');
  final summary = TextEditingController(text: item?.summary ?? '');
  final highlights = TextEditingController(
    text: item?.highlights.join('\n') ?? '',
  );
  final url = TextEditingController(text: item?.url ?? '');

  await _showEditor(
    context,
    titleText: index == null ? 'Add Experience' : 'Edit Experience',
    fields: [
      _AdminField(controller: role, label: 'Role'),
      _AdminField(controller: company, label: 'Company'),
      _AdminField(controller: period, label: 'Period'),
      _AdminField(controller: location, label: 'Location'),
      _AdminField(
        controller: summary,
        label: 'Summary',
        minLines: 3,
        maxLines: 5,
      ),
      _AdminField(
        controller: highlights,
        label: 'Highlights, one per line',
        minLines: 4,
        maxLines: 6,
      ),
      _AdminField(controller: url, label: 'Company URL'),
    ],
    onSave: () {
      content.upsertExperience(
        index,
        ExperienceItem(
          role: role.text.trim(),
          company: company.text.trim(),
          period: period.text.trim(),
          location: location.text.trim(),
          summary: summary.text.trim(),
          highlights: _splitLines(highlights.text),
          url: url.text.trim().isEmpty ? null : url.text.trim(),
        ),
      );
    },
  );
}

Future<void> _editSkill(
  BuildContext context,
  EditablePortfolioStore content,
  int? index,
  SkillCategory? item,
) async {
  final title = TextEditingController(text: item?.title ?? '');
  final summary = TextEditingController(text: item?.summary ?? '');
  final skills = TextEditingController(text: item?.items.join(', ') ?? '');

  await _showEditor(
    context,
    titleText: index == null ? 'Add Skill Category' : 'Edit Skill Category',
    fields: [
      _AdminField(controller: title, label: 'Title'),
      _AdminField(
        controller: summary,
        label: 'Summary',
        minLines: 2,
        maxLines: 4,
      ),
      _AdminField(controller: skills, label: 'Skills comma separated'),
    ],
    onSave: () {
      content.upsertSkillCategory(
        index,
        SkillCategory(
          title: title.text.trim(),
          summary: summary.text.trim(),
          items: _splitComma(skills.text),
        ),
      );
    },
  );
}

Future<void> _editStat(
  BuildContext context,
  EditablePortfolioStore content,
  int? index,
  PortfolioStat? item,
) async {
  final value = TextEditingController(text: item?.value ?? '');
  final label = TextEditingController(text: item?.label ?? '');
  final detail = TextEditingController(text: item?.detail ?? '');

  await _showEditor(
    context,
    titleText: index == null ? 'Add Stat' : 'Edit Stat',
    fields: [
      _AdminField(controller: value, label: 'Value'),
      _AdminField(controller: label, label: 'Label'),
      _AdminField(
        controller: detail,
        label: 'Detail',
        minLines: 2,
        maxLines: 4,
      ),
    ],
    onSave: () {
      content.upsertStat(
        index,
        PortfolioStat(
          value: value.text.trim(),
          label: label.text.trim(),
          detail: detail.text.trim(),
        ),
      );
    },
  );
}

Future<void> _editAchievement(
  BuildContext context,
  EditablePortfolioStore content,
  int? index,
  AchievementItem? item,
) async {
  final value = TextEditingController(text: item?.value ?? '');
  final label = TextEditingController(text: item?.label ?? '');

  await _showEditor(
    context,
    titleText: index == null ? 'Add Achievement' : 'Edit Achievement',
    fields: [
      _AdminField(controller: value, label: 'Value'),
      _AdminField(controller: label, label: 'Label'),
    ],
    onSave: () {
      content.upsertAchievement(
        index,
        AchievementItem(value: value.text.trim(), label: label.text.trim()),
      );
    },
  );
}

Future<void> _editContact(
  BuildContext context,
  EditablePortfolioStore content,
  int? index,
  ContactAction? item,
) async {
  final title = TextEditingController(text: item?.title ?? '');
  final subtitle = TextEditingController(text: item?.subtitle ?? '');
  final url = TextEditingController(text: item?.url ?? '');

  await _showEditor(
    context,
    titleText: index == null ? 'Add Contact Action' : 'Edit Contact Action',
    fields: [
      _AdminField(controller: title, label: 'Title'),
      _AdminField(controller: subtitle, label: 'Subtitle'),
      _AdminField(controller: url, label: 'URL / mailto / tel'),
    ],
    onSave: () {
      content.upsertContactAction(
        index,
        ContactAction(
          title: title.text.trim(),
          subtitle: subtitle.text.trim(),
          url: url.text.trim(),
          icon: item?.icon ?? Icons.link_rounded,
        ),
      );
    },
  );
}

Future<void> _showEditor(
  BuildContext context, {
  required String titleText,
  required List<Widget> fields,
  required VoidCallback onSave,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(titleText),
        content: SizedBox(
          width: 680,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final field in fields) ...[
                  field,
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onSave();
              Navigator.of(context).pop();
              _showSaved(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

List<String> _splitComma(String value) {
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> _splitLines(String value) {
  return value
      .split('\n')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _slug(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp('^-|-\$'), '');
  return normalized.isEmpty
      ? DateTime.now().microsecondsSinceEpoch.toString()
      : normalized;
}

void _showSaved(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Updated successfully'),
    ),
  );
}
