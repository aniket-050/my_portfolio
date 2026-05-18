import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_palette.dart';
import '../../portfolio/data/editable_portfolio_store.dart';
import '../../portfolio/data/portfolio_backend.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final messenger = ScaffoldMessenger.of(context);
    final launched = await launchUrl(
      uri,
      webOnlyWindowName: uri.scheme.startsWith('http') ? '_blank' : null,
    );
    if (!launched && context.mounted) {
      if (uri.scheme == 'mailto') {
        final subject = uri.queryParameters['subject'] ?? '';
        final body = uri.queryParameters['body'] ?? '';
        final fallback = 'To: ${uri.path}\nSubject: $subject\n\n$body'
            .trimRight();
        await Clipboard.setData(ClipboardData(text: fallback));
      }
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            uri.scheme == 'mailto'
                ? 'Could not open email app. Message copied to clipboard.'
                : 'Unable to open ${uri.toString()}',
          ),
        ),
      );
    }
  }

  Future<void> _submit(EditablePortfolioStore content) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final subject = _subjectController.text.trim().isEmpty
        ? 'Portfolio enquiry from ${_nameController.text.trim()}'
        : _subjectController.text.trim();
    final body =
        '''
Name: ${_nameController.text.trim()}
Email: ${_emailController.text.trim()}

Message:
${_messageController.text.trim()}
''';

    setState(() => _submitting = true);
    try {
      await content.backend?.submitInquiry(
        ContactInquiry(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          subject: subject,
          message: _messageController.text.trim(),
        ),
      );

      if (content.backend?.hasDirectEmailDelivery ?? false) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Message sent successfully.'),
          ),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
        return;
      }
    } on ContactSubmissionException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              _submissionErrorMessage(
                error: error,
                hasDirectDelivery:
                    content.backend?.hasDirectEmailDelivery ?? false,
              ),
            ),
          ),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not send message automatically: $error'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }

    final uri = Uri(
      scheme: 'mailto',
      path: content.email,
      queryParameters: {'subject': subject, 'body': body},
    );

    if (!mounted) {
      return;
    }
    await _launch(context, uri.toString());
  }

  String _submissionErrorMessage({
    required ContactSubmissionException error,
    required bool hasDirectDelivery,
  }) {
    final permissionDenied = error.toString().toLowerCase().contains(
      'permission-denied',
    );

    if (hasDirectDelivery) {
      return 'Auto submit failed. Opening email app as fallback.';
    }
    if (permissionDenied) {
      return 'Inbox delivery channel is not configured yet. Opening email app as fallback.';
    }
    return 'Could not save enquiry. Opening email app as fallback.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = PortfolioScope.of(context);

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
              constraints: const BoxConstraints(maxWidth: 1180),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Contact Us',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 900;
                        if (stacked) {
                          return Column(
                            children: [
                              _ContactIntro(
                                onLaunch: (url) => _launch(context, url),
                              ),
                              const SizedBox(height: 22),
                              _ContactFormCard(
                                formKey: _formKey,
                                nameController: _nameController,
                                emailController: _emailController,
                                subjectController: _subjectController,
                                messageController: _messageController,
                                submitting: _submitting,
                                onSubmit: () => _submit(content),
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _ContactIntro(
                                onLaunch: (url) => _launch(context, url),
                              ),
                            ),
                            const SizedBox(width: 22),
                            Expanded(
                              flex: 7,
                              child: _ContactFormCard(
                                formKey: _formKey,
                                nameController: _nameController,
                                emailController: _emailController,
                                subjectController: _subjectController,
                                messageController: _messageController,
                                submitting: _submitting,
                                onSubmit: () => _submit(content),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactIntro extends StatelessWidget {
  const _ContactIntro({required this.onLaunch});

  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = PortfolioScope.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppPalette.ink,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LET\'S CONNECT',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppPalette.sky,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Have a Flutter product, map workflow or app idea?',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Send the details and I will respond with a clear next step. For urgent work, call or email directly.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 26),
          for (final action in content.contactActions)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onLaunch(action.url),
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(action.icon, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              action.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.68),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.north_east_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ContactFormCard extends StatelessWidget {
  const _ContactFormCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.subjectController,
    required this.messageController,
    required this.submitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppPalette.line),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.06),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send Message', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 18),
            _ContactField(
              controller: nameController,
              label: 'Your name',
              validator: _required,
            ),
            const SizedBox(height: 14),
            _ContactField(
              controller: emailController,
              label: 'Email address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Email is required';
                }
                if (!text.contains('@') || !text.contains('.')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _ContactField(controller: subjectController, label: 'Subject'),
            const SizedBox(height: 14),
            _ContactField(
              controller: messageController,
              label: 'Project details',
              minLines: 6,
              maxLines: 8,
              validator: _required,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: submitting ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.ink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }

  static String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}

class _ContactField extends StatelessWidget {
  const _ContactField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppPalette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppPalette.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppPalette.line),
        ),
      ),
    );
  }
}
