import 'package:flutter/material.dart';

class Signal {
  final String title;
  final String body;
  final String category;
  final double frequency;
  final double frustration;
  final double payIntent;
  final String source;

  Signal({
    required this.title,
    required this.body,
    required this.category,
    required this.frequency,
    required this.frustration,
    required this.payIntent,
    required this.source,
  });

  String get verdict {
    if (frustration >= 0.7 && frequency >= 0.6) {
      return 'Build This';
    } else if (payIntent >= 0.7) {
      return 'Learn This';
    } else {
      return 'Skip';
    }
  }

  Color get verdictColor {
    switch (verdict) {
      case 'Build This':
        return Colors.purple;
      case 'Learn This':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      category: json['category'] ?? 'General',
      frequency: (json['frequency'] ?? 0.0).toDouble(),
      frustration: (json['frustration'] ?? 0.0).toDouble(),
      payIntent: (json['payIntent'] ?? 0.0).toDouble(),
      source: json['source'] ?? 'Reddit',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'category': category,
      'frequency': frequency,
      'frustration': frustration,
      'payIntent': payIntent,
      'source': source,
    };
  }
}
