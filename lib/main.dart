import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthGate(),
  ));
}

const String myDbUrl =
    'https://loginwithdatabase-fe7ef-default-rtdb.asia-southeast1.firebasedatabase.app';

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

    if (emailText.isEmpty || passwordText.isEmpty || (!_isLogin && usernameText.isEmpty)) {
      _showMessage("Please fill all fields");
      return;
    }

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailText,
          password: passwordText,
        );
      } else {
        UserCredential cred =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailText,
          password: passwordText,
        );

        DatabaseReference dbRef = FirebaseDatabase.instanceFor(
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
        });

        _showMessage("Registration successful! Please login.");
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "An error occurred");
    } catch (e) {
      _showMessage("An unexpected error occurred: $e");
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Login" : "Register")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!_isLogin)
                TextField(
                    controller: _username,
                    decoration: const InputDecoration(labelText: "Username")),
              TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: "Email")),
              TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white),
                  onPressed: _submit,
                  child: Text(_isLogin ? "Login" : "Register")),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin
                    ? "Create a new account"
                    : "I already have an account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final userRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(), databaseURL: myDbUrl)
        .ref("users/${user?.uid}");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF42A5F5),
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: userRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map data = snapshot.data!.snapshot.value as Map;

              String name = data['username'] ?? "No Name";
              String email = data['email'] ?? "No Email";
              String pass = data['password'] ?? "No Password";

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Welcome, $name!",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[500])),
                  const SizedBox(height: 10),
                  Text("Your Email: $email"),
                  Text("Your Password: $pass"),
                ],
              );
            }

            return const Text("No user data found.");
          },
        ),
      ),
    );
  }
}
