import 'package:cloud_firestore/cloud_firestore.dart';


class Book {
final String id;
final String ownerId;
final String title;
final List<String> authors;
final String edition;
final String condition;
final String description;
final List<String> images;
final bool swapOnly;
final Timestamp createdAt;


Book({
required this.id,
required this.ownerId,
required this.title,
required this.authors,
required this.edition,
required this.condition,
required this.description,
required this.images,
required this.swapOnly,
required this.createdAt,
});


factory Book.fromDoc(DocumentSnapshot doc) {
final d = doc.data() as Map<String, dynamic>;
return Book(
id: doc.id,
ownerId: d['ownerId'] ?? '',
title: d['title'] ?? '',
authors: List<String>.from(d['authors'] ?? []),
edition: d['edition'] ?? '',
condition: d['condition'] ?? '',
description: d['description'] ?? '',
images: List<String>.from(d['images'] ?? []),
swapOnly: d['swapOnly'] ?? false,
createdAt: d['createdAt'] ?? Timestamp.now(),
);
}


Map<String, dynamic> toMap() => {
'ownerId': ownerId,
'title': title,
'authors': authors,
'edition': edition,
'condition': condition,
'description': description,
'images': images,
'swapOnly': swapOnly,
'createdAt': createdAt,
};
}