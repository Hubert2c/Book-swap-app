import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthService extends ChangeNotifier {
final FirebaseAuth _auth = FirebaseAuth.instance;
User? get currentUser => _auth.currentUser;


AuthService() {
_auth.authStateChanges().listen((_) => notifyListeners());
}


Future<UserCredential> signIn(String email, String pass) async {
final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
notifyListeners();
return cred;
}


Future<UserCredential> signUp(String email, String pass) async {
final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
notifyListeners();
return cred;
}


Future<void> signOut() async {
await _auth.signOut();
notifyListeners();
}
}