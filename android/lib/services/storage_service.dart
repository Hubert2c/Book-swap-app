import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';


class StorageService {
final FirebaseStorage _storage = FirebaseStorage.instance;
final Uuid _uuid = Uuid();


Future<String> uploadBookImage(File file, String ownerId) async {
final id = _uuid.v4();
final ref = _storage.ref().child('books').child(ownerId).child('$id.jpg');
final task = await ref.putFile(file);
return await task.ref.getDownloadURL();
}
}