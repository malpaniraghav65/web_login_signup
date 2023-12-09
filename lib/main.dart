import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:web_login_signup/Facultydashboard.dart';
import 'StudentDashboard.dart';
import 'admindashboard.dart';

class ProviderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is the Provider Screen.',
              style: TextStyle(fontSize: 24),
            ),
            // Add your provider-related content here
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized;
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyBDWL38k4MNXh2lRPCwFkiv7553JC7IkSE",
    appId: "1:281447264335:web:98b35028970d31b806ba3a",
    messagingSenderId: "281447264335",
    projectId: "cpiii-2408",
    storageBucket: "cpiii-2408.appspot.com",
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login & Signup',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/auth', // Set the initial route
      routes: {
        '/auth': (context) => AuthScreen(), // Define the route for AuthScreen
        // Define other routes as needed
      },
    ); // home: AuthScreen());
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/background_home.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          const Align(
            alignment: AlignmentDirectional(
                0, -1), // Set your desired padding from the bottom
            child: Text(
              'College Project Managment system',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLogin
                    ? LoginForm(toggleAuthMode: _toggleAuthMode)
                    : SignupForm(toggleAuthMode: _toggleAuthMode),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final VoidCallback toggleAuthMode;
  TextEditingController _loginemail = TextEditingController();
  TextEditingController _loginpassword = TextEditingController();
  LoginForm({required this.toggleAuthMode})
      : _loginemail = TextEditingController(),
        _loginpassword = TextEditingController();

  Future<void> _login(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = userCredential.user!;

      if (user.emailVerified) {
        // Fetch user data from Firestore and perform further actions
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('Student')
            .doc('year')
            .collection('2023')
            .doc('Semester')
            .collection('ODD')
            .doc(email) // You might need to store the user's UID during signup
            .get();

        if (userData.exists) {
          String type = userData['type'];
          if (type == 'student') {
            String enrollmentNumber = userData['enrollmentNumber'];
            // CreateProjectPage(enrollmentNumber);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DashboardScreen(enrollmentNumber: enrollmentNumber),
                ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User data not found. '),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please verify your email before logging in.'),
        ));
      }
    } catch (error) {
      print('Error during login: $error');
      // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid email or password.'),
      ));
    }
  }

  Future<void> _resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset email sent. Check your inbox.'),
      ));
    } catch (error) {
      print('Error during password reset: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset failed. Please try again.'),
      ));
    }
  }

  Future<void> _loginAsFaculty(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = userCredential.user!;

      if (user.emailVerified) {
        // Fetch user data from Firestore and perform further actions
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('Faculty')
            .doc(email) // You might need to store the user's UID during signup
            .get();

        if (userData.exists) {
          String type = userData['type'];
          if (type == 'faculty') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FacultyDashboardScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Invalid user type.'),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User data not found.'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please verify your email before logging in.'),
        ));
      }
    } catch (error) {
      print('Error during login: $error');
      // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid email or password.'),
      ));
    }
  }

  Future<void> _loginAsAdmin(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = userCredential.user!;

      if (user.emailVerified) {
        // Fetch user data from Firestore and perform further actions
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(email) // You might need to store the user's UID during signup
            .get();

        if (userData.exists) {
          String type = userData['type'];
          if (type == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminDashboardScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Invalid user type.'),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User data not found.'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please verify your email before logging in.'),
        ));
      }
    } catch (error) {
      print('Error during login: $error');
      // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid email or password.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _loginemail,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _loginpassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _login(
              context,
              _loginemail.text,
              _loginpassword.text,
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            primary: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Login',
            style: TextStyle(fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () {
            _resetPassword(context, _loginemail.text);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            primary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Reset Password',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                // Add logic for faculty login
                //print('Login as Faculty');
                _loginAsFaculty(context, _loginemail.text, _loginpassword.text);
              },
              child: const Text('Login as Faculty'),
            ),
            TextButton(
              onPressed: () {
                // Add logic for admin login
                _loginAsAdmin(context, _loginemail.text, _loginpassword.text);
                print('Login as Admin');
              },
              child: const Text('Login as Admin'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: toggleAuthMode,
          child: const Text("Don't have an account? Signup"),
        ),
      ],
    );
  }
}

class SignupForm extends StatelessWidget {
  final VoidCallback toggleAuthMode;
  TextEditingController _signupemail = TextEditingController();
  TextEditingController _signuppassword = TextEditingController();
  TextEditingController _signupenrollmentnumber = TextEditingController();
  TextEditingController _signupphonenumber = TextEditingController();

  SignupForm({required this.toggleAuthMode});

  Future<void> _signup(BuildContext context, String email, String password,
      String enrollmentNumber, String phoneNumber) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = userCredential.user!;

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      } // Store user data in Firestore after email verification
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'enrollmentNumber': enrollmentNumber,
        'phoneNumber': phoneNumber,
        'email': email,
        'password': password,
        'type': "student",
        // Add more fields as needed
      });
      // Create a document reference for 'Project Info' with the user's enrollment number as the document ID
      DocumentReference projectInfoRef = FirebaseFirestore.instance
          .collection('Project Info')
          .doc(enrollmentNumber);
      // Set data in the 'Project Info' document
      await projectInfoRef.set({
        'enrollmentNumber': enrollmentNumber,
      });

      // Create a collection named 'User Project' under the 'Project Info' document
      await projectInfoRef.collection('User Project').doc('Project').set({
        'Description': "",
        'Guide Name': "",
        'title': "",
        'cp': "",
      });

      // Create 'Milestone' collection with the user's enrollment number as the document ID
      DocumentReference milestoneRef = FirebaseFirestore.instance
          .collection('Milestone')
          .doc(enrollmentNumber);

      // Set data in the 'Milestone' document
      await milestoneRef.set({
        'enrollmentNumber': enrollmentNumber,
      });

      // Create 'All Milestones' collection under the 'Milestone' document
      await milestoneRef.collection('All Milestones');
      // Display a message to verify email and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Verification email sent. Please verify your email.'),
      ));

      toggleAuthMode();
    } catch (error) {
      print('Error during signup: $error');
      // Handle signup error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Signup',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          keyboardType: TextInputType.number,
          controller: _signupenrollmentnumber,
          decoration: const InputDecoration(
            labelText: 'Enrollment Number',
            prefixIcon: Icon(Icons.account_circle_sharp),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _signupphonenumber,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _signupemail,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _signuppassword,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Add your signup logic here
            _signup(context, _signupemail.text, _signuppassword.text,
                _signupenrollmentnumber.text, _signupphonenumber.text);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            primary: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Signup',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: toggleAuthMode,
          child: const Text('Already have an account? Login'),
        ),
      ],
    );
  }
}
