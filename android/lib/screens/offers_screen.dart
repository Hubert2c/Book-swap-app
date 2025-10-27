import 'package:flutter/material.dart';
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}
if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
return const Center(child: Text('No offers yet.'));
}


final offers = snapshot.data!.docs;


return ListView.builder(
itemCount: offers.length,
itemBuilder: (context, index) {
final offer = offers[index].data() as Map<String, dynamic>;
final offerId = offers[index].id;


return Card(
margin: const EdgeInsets.all(8.0),
elevation: 2,
child: ListTile(
leading: const Icon(Icons.swap_horiz, color: Colors.indigo),
title: Text(offer['message'] ?? 'No message'),
subtitle: Text('Status: ${offer['status'] ?? 'pending'}'),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
if (offer['status'] == 'pending') ...[
IconButton(
icon: const Icon(Icons.check, color: Colors.green),
onPressed: () => _updateOfferStatus(offerId, 'accepted'),
),
IconButton(
icon: const Icon(Icons.close, color: Colors.red),
onPressed: () => _updateOfferStatus(offerId, 'declined'),
),
] else
Text(offer['status'].toString().toUpperCase(),
style: TextStyle(
fontWeight: FontWeight.bold,
color: offer['status'] == 'accepted'
? Colors.green
: offer['status'] == 'declined'
? Colors.red
: Colors.grey,
)),
],
),
),
);
},
);
},
),
);
}


Future<void> _updateOfferStatus(String offerId, String newStatus) async {
await _db.collection('offers').doc(offerId).update({'status': newStatus});
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Offer $newStatus')),
);
}
}