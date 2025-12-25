import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/signal.dart';

class SignalRepository {
  final List<String> _subreddits = ['startups', 'indiehackers'];

  // Hybrid Data Repository: Try live fetch, silently fallback to mock
  Future<List<Signal>> fetchSignals(List<String> userInterests) async {
    try {
      final signals = await _fetchFromReddit(userInterests);
      if (signals.isNotEmpty) return signals;
      return _getMockSignals(userInterests);
    } catch (_) {
      return _getMockSignals(userInterests);
    }
  }

  Future<List<Signal>> _fetchFromReddit(List<String> userInterests) async {
    final List<Signal> allSignals = [];

    for (final subreddit in _subreddits) {
      try {
        final response = await http.get(
          Uri.parse('https://www.reddit.com/r/$subreddit/new.json?limit=15'),
          headers: {'User-Agent': 'TrendForge_MVP_Student_v1'},
        ).timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final posts = data['data']['children'] as List;

          for (final post in posts) {
            final pd = post['data'];
            final title = (pd['title'] ?? '').toString();
            final body = (pd['selftext'] ?? '').toString();
            final text = '$title $body'.toLowerCase();

            final frustration = _calculateFrustration(text);
            final payIntent = _calculatePayIntent(text);
            final frequency = _calculateFrequency(text);
            final category = _categorize(text, userInterests);

            if (category != 'Other' && (frustration > 0.3 || payIntent > 0.3)) {
              allSignals.add(Signal(
                title: title,
                body: body.length > 200 ? '${body.substring(0, 200)}...' : body,
                category: category,
                frequency: frustration.clamp(0.0, 1.0),
                frustration: frustration.clamp(0.0, 1.0),
                payIntent: payIntent.clamp(0.0, 1.0),
                source: 'r/$subreddit',
              ));
            }
          }
        }
      } catch (_) {
        continue;
      }
    }

    allSignals.sort((a, b) => b.frustration.compareTo(a.frustration));
    return allSignals.take(20).toList();
  }

  double _calculateFrustration(String text) {
    const keywords = ['hate', 'stuck', 'annoying', 'fail'];
    int count = 0;
    for (final k in keywords) {
      if (text.contains(k)) count++;
    }
    return (count / keywords.length).clamp(0.0, 1.0);
  }

  double _calculatePayIntent(String text) {
    const keywords = ['pay', 'buy', 'pricing', 'worth it'];
    int count = 0;
    for (final k in keywords) {
      if (text.contains(k)) count++;
    }
    return (count / keywords.length).clamp(0.0, 1.0);
  }

  double _calculateFrequency(String text) {
    const keywords = [
      'always',
      'every',
      'daily',
      'constantly',
      'often',
      'frequently',
      'again',
      'repeatedly',
    ];
    int count = 0;
    for (final k in keywords) {
      if (text.contains(k)) count++;
    }
    return (count / 4).clamp(0.0, 1.0) + 0.3; // base lift
  }

  String _categorize(String text, List<String> userInterests) {
    final map = {
      'SaaS': ['saas', 'software', 'platform', 'app', 'tool', 'service'],
      'AI': ['ai', 'machine learning', 'gpt', 'automation', 'llm', 'chatbot'],
      'No-Code': ['no-code', 'nocode', 'low-code', 'bubble', 'webflow', 'zapier'],
      'DevTools': ['dev', 'developer', 'api', 'sdk', 'framework', 'library'],
      'Crypto': ['crypto', 'blockchain', 'web3', 'nft', 'defi', 'bitcoin'],
    };

    for (final interest in userInterests) {
      final ks = map[interest] ?? [];
      for (final k in ks) {
        if (text.contains(k)) return interest;
      }
    }
    return 'Other';
  }

  List<Signal> _getMockSignals(List<String> userInterests) {
    final all = [
      Signal(
        title: 'Stripe Connect is a nightmare to implement',
        body:
            'Spent 3 days trying to figure out the OAuth flow. The documentation is confusing and error messages are cryptic. Would pay for a simplified wrapper.',
        category: 'SaaS',
        frequency: 0.8,
        frustration: 0.95,
        payIntent: 0.85,
        source: 'Mock Data',
      ),
      Signal(
        title: 'Finding quality AI training data is impossible',
        body:
            'Every dataset I find is either too expensive or low quality. We need a marketplace for verified, domain-specific training data.',
        category: 'AI',
        frequency: 0.9,
        frustration: 0.88,
        payIntent: 0.92,
        source: 'Mock Data',
      ),
      Signal(
        title: 'No-code tools break at scale',
        body:
            'Built my MVP on Bubble, now it\'s too slow. Can\'t migrate easily. Stuck between rebuilding from scratch or dealing with poor performance.',
        category: 'No-Code',
        frequency: 0.75,
        frustration: 0.91,
        payIntent: 0.65,
        source: 'Mock Data',
      ),
      Signal(
        title: 'API documentation tools all suck',
        body:
            'Swagger is outdated, Postman is bloated. Need something that auto-generates docs from code and keeps them in sync.',
        category: 'DevTools',
        frequency: 0.85,
        frustration: 0.78,
        payIntent: 0.70,
        source: 'Mock Data',
      ),
      Signal(
        title: 'Crypto tax reporting is a full-time job',
        body:
            'Tracking transactions across 12 wallets and 8 exchanges. Existing tools miss half my trades. Would pay \$500/year for accurate reporting.',
        category: 'Crypto',
        frequency: 0.65,
        frustration: 0.93,
        payIntent: 0.95,
        source: 'Mock Data',
      ),
      Signal(
        title: 'Managing SaaS subscriptions is chaos',
        body:
            'We have 47 active subscriptions. No idea what half of them do. Need a tool to track usage and suggest cancellations.',
        category: 'SaaS',
        frequency: 0.80,
        frustration: 0.72,
        payIntent: 0.68,
        source: 'Mock Data',
      ),
      Signal(
        title: 'AI models keep hallucinating in production',
        body:
            'Our customer support AI makes up facts 15% of the time. Can\'t find a good solution to validate outputs before they reach users.',
        category: 'AI',
        frequency: 0.88,
        frustration: 0.89,
        payIntent: 0.87,
        source: 'Mock Data',
      ),
      Signal(
        title: 'Email deliverability is black magic',
        body:
            'Cold emails keep landing in spam. Tried everything: SPF, DKIM, warm-up services. Still 40% spam rate. This is killing our growth.',
        category: 'SaaS',
        frequency: 0.92,
        frustration: 0.86,
        payIntent: 0.80,
        source: 'Mock Data',
      ),
      Signal(
        title: 'Version control for no-code is non-existent',
        body:
            'Made a change in Webflow that broke everything. No way to rollback. Had to rebuild 6 hours of work. This is unacceptable.',
        category: 'No-Code',
        frequency: 0.70,
        frustration: 0.94,
        payIntent: 0.75,
        source: 'Mock Data',
      ),
      Signal(
        title: 'Developer onboarding takes forever',
        body:
            'New devs take 2 weeks to get productive. Need better docs, codebase walkthroughs, and environment setup automation.',
        category: 'DevTools',
        frequency: 0.78,
        frustration: 0.81,
        payIntent: 0.73,
        source: 'Mock Data',
      ),
    ];

    if (userInterests.isEmpty) return all;
    final filtered = all.where((s) => userInterests.contains(s.category)).toList();
    return filtered.isNotEmpty ? filtered : all;
  }
}
