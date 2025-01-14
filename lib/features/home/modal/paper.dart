import 'package:cloud_firestore/cloud_firestore.dart';

class Paper {
  final DocumentReference ref;
  final String title;
  final String description;
  final String? thumbnail;
  final String? paperUrl;
  final String? lessonNumber;
  final DocumentReference chapter;
  final DocumentReference createdBy;
  final Timestamp createdAt;

  Paper({
    required this.ref,
    required this.title,
    required this.description,
    this.thumbnail,
    this.paperUrl,
    this.lessonNumber,
    required this.chapter,
    required this.createdBy,
    required this.createdAt,
  });

  factory Paper.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Paper(
      ref: snapshot.reference,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      thumbnail: data['thumbnail'],
      paperUrl: data['paper'],
      lessonNumber: data['paperNumber'],
      chapter: data['chapter'],
      createdBy: data['createdBy'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'paper': paperUrl,
      'paperNumber': lessonNumber,
      'chapter': chapter,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  Paper copyWith({
    String? title,
    String? description,
    String? thumbnail,
    String? paperUrl,
    String? lessonNumber,
    DocumentReference? chapter,
    String? createdBy,
    Timestamp? createdAt,
  }) {
    return Paper(
      ref: this.ref,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      paperUrl: paperUrl ?? this.paperUrl,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      chapter: chapter ?? this.chapter,
      createdBy: this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
