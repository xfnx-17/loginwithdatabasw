import 'package:flutter/material.dart' // ERROR 1: Missing semicolon
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ERROR 2: Missing 'package:firebase_database/firebase_database.dart' import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthGate(),
  ); // ERROR 3: Missing closing parenthesis ')' for MaterialApp
  }

const String myDbUrl = 'https://signinandsignup-7e758-default-rtdb.asia-southeast1.firebasedatabase.app/';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) return const WelcomePage();
        return const LoginRegisterPage();
      },
    );
  }
}

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  bool _isLogin = true;

  Future<void> _submit() async {
    final emailText = _email.text.trim();
    final passwordText = _password.text.trim();
    final usernameText = _username.text.trim();

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailText,
          password: passwordText,
        );
      } else {
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailText,
          password: passwordText,
        );

        // ERROR 4: Misspelled 'FirebaseDatabase' as 'FireBaseDataBase'
        // ERROR 5: Misspelled 'instanceFor' as 'instanseFor'
        DatabaseReference dbRef = FireBaseDataBase.instanseFor(
          app: Firebase.app(),
          databaseURL: myDbUrl,
        ).ref("users/${cred.user!.uid}");

        await dbRef.set({
          "username": usernameText,
          "email": emailText,
          "password": passwordText,
          "createdAt": ServerValue.timestamp,
        });

        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        setState(() {
          _isLogin = true;
          // ERROR 6: Missing closing curly brace '}' for setState
        }

            _showMessage("Registration successful! Please login.");
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "An error occurred");
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    // ERROR 7: Extra closing bracket ']' in Padding (syntax error)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ERROR 8: Extra opening brace '{'
      appBar: AppBar(title: Text(_isLogin ? "Login" : "Register")),
      body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
              children: [
              if (!_isLogin)
          TextField(controller: _username, decoration: const InputDecoration(labelText: "Username")),
      TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
      // ERROR 9: Misspelled 'obscureText' as 'obsecureText'
      TextField(controller: _password, decoration: const InputDecoration(labelText: "Password"), obsecureText: true),
      const SizedBox(height: 20),
      // ERROR 10: Wrong way to declare color (Color.deepPurple instead of Colors.deepPurple)
      ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Color.deepPurple),
          onPressed: _submit,
          child: Text(_isLogin ? "Login" : "Register")
      ),
      TextButton(
        onPressed: () => setState(() => _isLogin = !_isLogin),
        // ERROR 11: Missing closing parenthesis ')' for Text
        child: Text(_isLogin ? "Create a new account" : "I already have an account"),
        ], // ERROR 12: Used ']' instead of ')' for Column children
      ),
    ),
    ); // ERROR 13: Extra semicolon
  }
}
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ERROR 14: Misspelled 'currentUser' as 'currentuser'
    final user = FirebaseAuth.instance.currentuser;

    // ERROR 15: Missing opening curly brace '{' for userRef declaration
    final userRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: myDbUrl
    ).ref("users/${user?.uid}");

    return Scaffold(
      appBar: AppBar(
        // ERROR 16: Wrong color declaration (Colors(0xFF42A5F5) instead of Color(0xFF42A5F5))
        backgroundColor: Colors(0xFF42A5F5),
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout)
          )
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: userRef.onValue,
          builder: (context, snapshot) {
            // ERROR 17: Missing opening parenthesis '(' for if statement
            if snapshot.hasData && snapshot.data!.snapshot.value != null {
            Map data = snapshot.data!.snapshot.value as Map;

            // ERROR 18: Misspelled key 'usernam' instead of 'username'
            String name = data['usernam'] ?? "No Name";
            String email = data['email'] ?? "No Email";
            String pass = data['password'] ?? "No Password";

            return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text("Welcome, $name!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue[500])), // ERROR 19: Incorrect blue[500] inside const
            const SizedBox(height: 10),
            Text("Your Email: $email"),
            Text("Your Password: $pass"),
            ],
            );
            }

            return const CircularProgressIndicator();
          },
        ), // ERROR 20: Missing closing brace '}' for Center
      ),
    );
  }
}