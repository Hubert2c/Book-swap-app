// lib/screens/listing_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';

class ListingDetailScreen extends StatefulWidget {
  final Book book;

  const ListingDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isOwner = user != null && user.uid == widget.book.ownerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.book.images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.book.images.first,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.menu_book, size: 60, color: Colors.grey),
                ),
              const SizedBox(height: 20),
              Text(
                widget.book.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Author(s): ${widget.book.authors.join(', ')}'),
              Text('Edition: ${widget.book.edition}'),
              Text('Condition: ${widget.book.condition}'),
              const Divider(height: 30),
              Text(widget.book.description),
              const SizedBox(height: 20),
              if (!isOwner)
                _offerSection(context)
              else
                const Text(
                  'This is your listing.',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _offerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Make an Offer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            hintText: 'Write a short message or propose a swap...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 10),
        _isSending
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Send Offer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _sendOffer,
              ),
      ],
    );
  }

  Future<void> _sendOffer() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to make an offer.')),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot be empty.')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await _firestore.createOffer({
        'bookId': widget.book.id,
        'fromUserId': user.uid,
        'toUserId': widget.book.ownerId,
        'message': _messageController.text.trim(),
      });

      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending offer: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }
}
