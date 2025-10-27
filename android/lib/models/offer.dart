import 'package:cloud_firestore/cloud_firestore.dart';


class Offer {
final String id;
final String bookId;
final String fromUserId;
final String toUserId;
final String? offeredBookId;
final String message;
final String status; // pending, accepted, declined, cancelled
final Timestamp createdAt;


Offer({
required this.id,
required this.bookId,
required this.fromUserId,
required this.toUserId,
this.offeredBookId,
required this.message,
required this.status,
required this.createdAt,
});


factory Offer.fromDoc(DocumentSnapshot doc) {
final d = doc.data() as Map<String, dynamic>;
return Offer(
id: doc.id,
bookId: d['bookId'],
fromUserId: d['fromUserId'],
toUserId: d['toUserId'],
offeredBookId: d['offeredBookId'],
message: d['message'] ?? '',
status: d['status'] ?? 'pending',
createdAt: d['createdAt'] ?? Timestamp.now(),
);
}
}