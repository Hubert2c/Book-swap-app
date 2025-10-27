import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';


void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
runApp(BookSwapApp());
}


class BookSwapApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return ChangeNotifierProvider(
create: (_) => AuthService(),
child: Consumer<AuthService>(
builder: (context, auth, _) {
return MaterialApp(
title: 'BookSwap',
theme: ThemeData(primarySwatch: Colors.indigo),
home: auth.currentUser == null ? AuthScreen() : HomeScreen(),
);
},
),
);
}
}