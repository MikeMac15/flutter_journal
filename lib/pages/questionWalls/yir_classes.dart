
// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class YirItem {
  final String text;
  final List<String> memoryId;

  YirItem({
    required this.text,
    this.memoryId = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'memoryId': memoryId,
    };
  }

  factory YirItem.fromMap(Map<String, dynamic> map) {
    return YirItem(
      text: map['text'],
      memoryId: List<String>.from(map['memoryId'] ?? []),
    );
  }
}

class YirCategory {
  final String title;
  final List<YirItem> items;

  YirCategory({
    required this.title,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory YirCategory.fromMap(Map<String, dynamic> map) {
    return YirCategory(
      title: map['title'],
      items: (map['items'] as List)
          .map((item) => YirItem.fromMap(item))
          .toList(),
    );
  }
}

class YirRecap {
  final String date;
  final String recapText;

  YirRecap({
    required this.date,
    required this.recapText,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'recapText': recapText,
    };
  }

  factory YirRecap.fromMap(Map<String, dynamic> map) {
    return YirRecap(
      date: map['date'],
      recapText: map['recapText'],
    );
  }
}

class Yir {
  final String year;
  final List<YirCategory> categories;
  final List<YirRecap> recaps;

  Yir({
    required this.year,
    this.categories = const [],
    this.recaps = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'categories': categories.map((c) => c.toMap()).toList(),
      'recaps': recaps.map((r) => r.toMap()).toList(),
    };
  }

  factory Yir.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Yir(
      year: doc.id,
      categories: (data['categories'] as List<dynamic>? ?? [])
          .map((c) => YirCategory.fromMap(c as Map<String, dynamic>))
          .toList(),
      recaps: (data['recaps'] as List<dynamic>? ?? [])
          .map((r) => YirRecap.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
