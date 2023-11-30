import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_login_signup/Milestone.dart';
import 'main.dart';

// void main() {
//   runApp(FacultyDashboardApp());
// }

// class FacultyDashboardApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Dashboard',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: FacultyDashboardScreen(),
//     );
//   }
// }

class FacultyDashboardScreen extends StatefulWidget {
  @override
  _FacultyDashboardScreenState createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AllStudents(),
    AddStudents(),
    Remarks(),
    LogoutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty Dashboard'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 40, // Set the font size to 20
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('All Students'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Add Student'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Milestones'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.black87,
            icon: Icon(Icons.business),
            label: 'All Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: 'Remarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'Logout',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}



class AllStudents extends StatefulWidget {
  @override
  _AllStudentsState createState() => _AllStudentsState();
}



class _AllStudentsState extends State<AllStudents> {
   String Semester = 'ODD'; // Default value
   String year = '2023';

  // Function to fetch data from Firebase and update the state
  Future<void> fetchData() async {
    try {
      // Replace 'your_admin_document_id' with the actual ID of the admin document
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('Admin')
          .get();

      if (adminSnapshot.exists) {
        setState(() {
          Semester = adminSnapshot['odd_collection'];
          year = adminSnapshot['year'];
        });
      }
    } catch (error) {
      print('Error fetching admin data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget initializes
  }
  Future<void> emptyFields(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('ProjectInfo')
          .doc('year')
          .collection(year)
          .doc('Semester')
          .collection(Semester)
          .doc(docId)
          .collection('User Project')
          .doc('Project')
          .update({
        'Description': '',
        'cp': '',
        'Guide Name': '',
        'title': '',
      });

      // After emptying fields, do nothing to remove the project from the list
    } catch (error) {
      print('Error emptying fields: $error');
      // Handle any error that may occur during the update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Students'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('ProjectInfo')
          .doc('year')
          .collection(year)
          .doc('Semester')
          .collection(Semester).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child:
                  CircularProgressIndicator(), // Center the CircularProgressIndicator
            );
          }

          final projects = snapshot.data!.docs;
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final projectId = project.id;
              final projectData = project.data() as Map<String, dynamic>;

              // Fetch additional data based on the student ID
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('ProjectInfo')
                    .doc('year')
                    .collection(year)
                    .doc('Semester')
                    .collection(Semester)
                    .doc(projectId)
                    .collection('User Project')
                    .get(),
                builder: (context, studentSnapshot) {
                  if (studentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child:
                          CircularProgressIndicator(), // Center the CircularProgressIndicator
                    );
                  }

                  if (studentSnapshot.hasError) {
                    return Text('Error: ${studentSnapshot.error}');
                  }

                  // Initialize an empty list to store subcollection data
                  final subcollectionData = [];

                  // Loop through the documents in the subcollection
                  for (final subDoc in studentSnapshot.data!.docs) {
                    // Access the data from the subdocument
                    final subDocData = subDoc.data() as Map<String, dynamic>;
                    // Add the subdocument data to the list
                    subcollectionData.add(subDocData);
                  }

                  // Check if subcollectionData is not empty before accessing its elements
                  if (subcollectionData[0]['cp']?.isNotEmpty == true &&
                      subcollectionData[0]['Guide Name']?.isNotEmpty == true) {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Project ID: $projectId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Use subcollectionData to display the data from the subcollection
                            Text(
                                'Field 1: ${subcollectionData[0]['cp']}'), // Replace 'field1' with the actual field name
                            Text(
                                'Field 2: ${subcollectionData[0]['Guide Name']}'), // Replace 'field2' with the actual field name
                            // Add more fields as needed
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            emptyFields(projectId);
                            setState(() {
                              // Remove the project from the list
                              projects.remove(project);
                            });
                            // Implement your delete logic here
                            // You can use projectId to identify the project to delete
                          },
                        ),
                      ),
                    );
                  } else {
                    return Container(); // Return an empty container if subcollectionData is empty
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}



class Remarks extends StatefulWidget {
  @override
  _RemarksState createState() => _RemarksState();
}

class _RemarksState extends State<Remarks> {
    String Semester = 'ODD'; // Default value
   String year = '2023';

  // Function to fetch data from Firebase and update the state
  Future<void> fetchData() async {
    try {
      // Replace 'your_admin_document_id' with the actual ID of the admin document
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('Admin')
          .get();

      if (adminSnapshot.exists) {
        setState(() {
          Semester = adminSnapshot['odd_collection'];
          year = adminSnapshot['year'];
        });
      }
    } catch (error) {
      print('Error fetching admin data: $error');
    }
  }
    @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget initializes
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remarks Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance .collection('Milestones')
        .doc('year')
        .collection(year)
        .doc('Semester')
        .collection(Semester).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final milestones = snapshot.data?.docs;

          // Extract the titles (document IDs) of the Milestones
          final milestoneTitles =
              milestones?.map((milestone) => milestone.id).toList();

          return ListView.builder(
            itemCount: milestoneTitles?.length ?? 0,
            itemBuilder: (context, index) {
              final title = milestoneTitles?[index] ?? 'No Title';

              return Card(
                margin: EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    // Handle the click event for this item
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MilestoneScreen(enrollmentNumber: title),
                      ),
                    );
                    print('Clicked on $title');
                  },
                  child: ListTile(
                    title: Text(title),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LogoutPage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth',
        (route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Logout Page'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _signOut(context);
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}




class AddStudents extends StatefulWidget {
  @override
  _AddStudentsState createState() => _AddStudentsState();
}

// class _AddStudentsState extends State<AddStudents> {
//   Uint8List? _csvData;

//   void _handleFileUpload(html.File file) async {
//     final reader = html.FileReader();
//     reader.onLoadEnd.listen((event) {
//       final data = reader.result as Uint8List;
//       setState(() {
//         _csvData = data;
//       });

//       // Parse the CSV data and store it in Firebase Firestore
//       _parseAndStoreData(data);
//     });
//     reader.readAsArrayBuffer(file);
//   }

//   Future<void> _parseAndStoreData(Uint8List data) async {
//    // FirebaseFirestore firestore = FirebaseFirestore.instance;
//     final decodedData = utf8.decode(data);
//     final List<List<dynamic>> csvTable =
//         CsvToListConverter().convert(decodedData);

//     for (final row in csvTable) {
    
//       try {
//           final StudentData = {
//         'email': row[0], // Replace with your CSV column names
//         'enrollmentNumber': row[1].toString(),
//         'password': row[2].toString(),
//         'phone number': row[3].toString(),
//         'type': "student",
//         // Add more fields as needed
//       };
//         UserCredential userCredential =
//             await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: StudentData['email'],
//           password: StudentData['password'],
//         );

//         User user = userCredential.user!;

//         if (!user.emailVerified) {
//           await user.sendEmailVerification();
//         }
//         await FirebaseFirestore.instance
//             .collection('Student').doc('year').collection('2023').doc('Semester').collection('ODD')
//             .doc(StudentData['email'])
//             .set({
//           'enrollmentNumber': StudentData['enrollmentNumber'],
//           'phoneNumber': StudentData['phone number'],
//           'email': StudentData['email'],
//           'password': StudentData['password'],
//           'type': "student",
//           // Add more fields as needed
//         });
//             // Create a document reference for 'Project Info' with the user's enrollment number as the document ID
//       DocumentReference projectInfoRef = FirebaseFirestore.instance
//           .collection('Project Info')
//           .doc(StudentData['enrollmentNumber']);
//       // Set data in the 'Project Info' document
//       await projectInfoRef.set({
//         'enrollmentNumber': StudentData['enrollmentNumber'],
//       });

//       // Create a collection named 'User Project' under the 'Project Info' document
//       await projectInfoRef.collection('User Project').doc('Project').set({
//         'Description': "",
//         'Guide Name': "",
//         'title': "",
//         'cp': "",
//       });

//       // Create 'Milestone' collection with the user's enrollment number as the document ID
//       DocumentReference milestoneRef = FirebaseFirestore.instance
//           .collection('Milestone')
//           .doc(StudentData['enrollmentNumber']);

//       // Set data in the 'Milestone' document
//       await milestoneRef.set({
//         'enrollmentNumber': StudentData['enrollmentNumber'],
//       });

//       // Create 'All Milestones' collection under the 'Milestone' document
//       await milestoneRef.collection('All Milestones');
//              // Print CSV data to the console
//           print(
//           'Email: ${StudentData['email']}, Password: ${StudentData['password']}');
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('Verification email sent. Please verify your email.'),
//         ));
//       } catch (error) {
//         print('Error during signup: $error');
//         // Handle signup error
//       }

 
    
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 final html.InputElement input = html.InputElement(type: 'file')
//                   ..accept = '.csv';
//                 input.click();

//                 input.onChange.listen((e) {
//                   final fileList = input.files;
//                   if (fileList != null && fileList.isNotEmpty) {
//                     final file = fileList[0];
//                     _handleFileUpload(file);
//                   }
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.blue,
//               ),
//               child: Text('Upload CSV File'),
//             ),
//             if (_csvData != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Data Added',
//                     style: TextStyle(fontSize: 18),
//                   ), // Display the CSV data here
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _AddStudentsState extends State<AddStudents> {
  String Semester = 'ODD'; // Default value
   String year = '2023';

  // Function to fetch data from Firebase and update the state
  Future<void> fetchData() async {
    try {
      // Replace 'your_admin_document_id' with the actual ID of the admin document
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('Admin')
          .get();

      if (adminSnapshot.exists) {
        setState(() {
          Semester = adminSnapshot['odd_collection'];
          year = adminSnapshot['year'];
        });
      }
    } catch (error) {
      print('Error fetching admin data: $error');
    }
  }
    @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget initializes
  }

  Uint8List? _csvData;

  void _handleFileUpload(html.File file) async {
    final reader = html.FileReader();
    reader.onLoadEnd.listen((event) {
      final data = reader.result as Uint8List;
      setState(() {
        _csvData = data;
      });

      // Parse the CSV data and store it in Firebase Firestore
      _parseAndStoreData(data);
    });
    reader.readAsArrayBuffer(file);
  }

  Future<void> _parseAndStoreData(Uint8List data) async {
    final decodedData = utf8.decode(data);
    final List<List<dynamic>> csvTable =
        CsvToListConverter().convert(decodedData);

    for (final row in csvTable) {
      try {
        final StudentData = {
          'email': row[0], // Replace with your CSV column names
          'enrollmentNumber': row[1].toString(),
          'password': row[2].toString(),
          'phone number': row[3].toString(),
          'type': "student",
          // Add more fields as needed
        };
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: StudentData['email'],
          password: StudentData['password'],
        );

        User user = userCredential.user!;

        if (!user.emailVerified) {
          // Send email verification only if the user is not already verified
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Verification email sent. Please verify your email.'),
          ));
        }

        await FirebaseFirestore.instance
            .collection('Student')
            .doc('year')
            .collection(year)
            .doc('Semester')
            .collection(Semester)
            .doc(StudentData['email'])
            .set({
          'enrollmentNumber': StudentData['enrollmentNumber'],
          'phoneNumber': StudentData['phone number'],
          'email': StudentData['email'],
          'password': StudentData['password'],
          'type': "student",
          // Add more fields as needed
        });

        // Create a document reference for 'Project Info' with the user's enrollment number as the document ID
        DocumentReference projectInfoRef = FirebaseFirestore.instance
            .collection('ProjectInfo')
            .doc('year')
            .collection(year)
            .doc('Semester')
            .collection(Semester)
            .doc(StudentData['enrollmentNumber']);
        // Set data in the 'Project Info' document
        await projectInfoRef.set({
          'enrollmentNumber': StudentData['enrollmentNumber'],
        });
           // Create a collection named 'User Project' under the 'Project Info' document
        await projectInfoRef.collection('User Project').doc('Project').set({
          'Description': "",
          'Guide Name': "",
          'title': "",
          'cp': "",
        });

        // // Create a collection named 'User Project' under the 'Project Info' document
        // await projectInfoRef.collection('User Project').doc('Project').set({
        //   'Description': "",
        //   'Guide Name': "",
        //   'title': "",
        //   'cp': "",
        // });

        // Create 'Milestone' collection with the user's enrollment number as the document ID
        DocumentReference milestoneRef = FirebaseFirestore.instance
            .collection('Milestones')
            .doc('year')
            .collection(year)
            .doc('Semester')
            .collection(Semester)
            .doc(StudentData['enrollmentNumber']);

        // Set data in the 'Milestone' document
        await milestoneRef.set({
          'enrollmentNumber': StudentData['enrollmentNumber'],
        });

        // Create 'All Milestones' collection under the 'Milestone' document
        await milestoneRef.collection('All Milestones');

          // Create 'Milestone' collection with the user's enrollment number as the document ID
        DocumentReference projectRef = FirebaseFirestore.instance
            .collection('AllProject')
            .doc('year')
            .collection(year)
            .doc('Semester')
            .collection(Semester)
            .doc(StudentData['enrollmentNumber'])
            .collection('Project').doc('Project');

        // Set data in the 'Milestone' document
        await projectRef.set({
          'enrollmentNumber': StudentData['enrollmentNumber'],
        });

        // Create 'All Milestones' collection under the 'Milestone' document
        await projectRef.collection('Project');

        // Print CSV data to the console
        print(
            'Email: ${StudentData['email']}, Password: ${StudentData['password']}');
      } catch (error) {
        print('Error during signup: $error');
        // Handle signup error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                final html.InputElement input = html.InputElement(type: 'file')
                  ..accept = '.csv';
                input.click();

                input.onChange.listen((e) {
                  final fileList = input.files;
                  if (fileList != null && fileList.isNotEmpty) {
                    final file = fileList[0];
                    _handleFileUpload(file);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: Text('Upload CSV File'),
            ),
            if (_csvData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Data Added',
                    style: TextStyle(fontSize: 18),
                  ), // Display the CSV data here
                ],
              ),
          ],
        ),
      ),
    );
  }
}

