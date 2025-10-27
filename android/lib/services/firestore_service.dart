import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/offer.dart';


class FirestoreService {
final FirebaseFirestore _db = FirebaseFirestore.instance;


// Books
Stream<List<Book>> streamBooks() {
return _db.collection('books').orderBy('createdAt', descending: true).snapshots().map((snap) =>
snap.docs.map((d) => Book.fromDoc(d)).toList());
}


Future<DocumentReference> createBook(Map<String, dynamic> data) async {
data['createdAt'] = FieldValue.serverTimestamp();
return await _db.collection('books').add(data);
}


Future<void> updateBook(String id, Map<String, dynamic> data) async {
await _db.collection('books').doc(id).update(data);
}


Future<void> deleteBook(String id) async {
await _db.collection('books').doc(id).delete();
}


// Offers
Stream<List<Offer>> streamOffersForUser(String uid) {
return _db
.collection('offers')
.where('toUserId', isEqualTo: uid)
.orderBy('createdAt', descending: true)
.snapshots()
.map((s) => s.docs.map((d) => Offer.fromDoc(d)).toList());
}


Future<DocumentReference> createOffer(Map<String, dynamic> data) async {
data['createdAt'] = FieldValue.serverTimestamp();
data['status'] = 'pending';
return await _db.collection('offers').add(data);
}


Future<void> updateOfferStatus(String id, String status) async {
await _db.collection('offers').doc(id).update({'status': status});
}
}