import 'package:flutter/material.dart';
import '../providers/language_provider.dart';

class AIScreen extends StatelessWidget {
  final LanguageProvider languageProvider;

  const AIScreen({Key? key, required this.languageProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                languageProvider.translate('ai'),
                style: theme.textTheme.displayLarge,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                child: Column(
                  children: [
                    _AICard(
                      title: languageProvider.translate('textAssistant'),
                      description: languageProvider.translate('textAssistantDesc'),
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _AICard(
                      title: languageProvider.translate('imageAnalysis'),
                      description: languageProvider.translate('imageAnalysisDesc'),
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _AICard(
                      title: languageProvider.translate('smartSuggestions'),
                      description: languageProvider.translate('smartSuggestionsDesc'),
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AICard extends StatelessWidget {
  final String title;
  final String description;
  final ThemeData theme;

  const _AICard({
    required this.title,
    required this.description,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}