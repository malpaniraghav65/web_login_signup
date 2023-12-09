import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
       apiKey: "AIzaSyBDWL38k4MNXh2lRPCwFkiv7553JC7IkSE",
        appId: "1:281447264335:web:98b35028970d31b806ba3a",
       messagingSenderId: "281447264335",
       projectId: "cpiii-2408"
    ),
  );
  runApp(AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AddFaculty(),
    AllProjects(),
    SetSemester(),
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
        title: Text('Admin Dashboard'),
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
                  fontSize: 40,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Add Faculty'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('All Projects'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Set Semester'),
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
            label: 'Add Faculty',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'All Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            label: 'Set Semester',
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

class AddFaculty extends StatefulWidget {
  @override
  _AddFacultyState createState() => _AddFacultyState();
}

class _AddFacultyState extends State<AddFaculty> {
  Uint8List? _csvData;
  var Error  =  "";

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
        final facultyData = {
          'email': row[0],
          'password': row[1].toString(),
          'name': row[2],
          'short name': row[3],
          'phone number': row[4].toString(),
          'type': "faculty",
        };
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: facultyData['email'],
          password: facultyData['password'],
        );

        User user = userCredential.user!;

        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }
        await FirebaseFirestore.instance
            .collection('Faculty')
            .doc(facultyData['email'])
            .set({
          'name': facultyData['name'],
          'short name': facultyData['short name'],
          'phonenumber': facultyData['phone number'],
          'email': facultyData['email'],
          'password': facultyData['password'],
          'type': "faculty",
        });
        print(
            'Email: ${facultyData['email']}, Password: ${facultyData['password']}, Number : ${facultyData['short name']}');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Verification email sent. Please verify your email.'),
        ));
      } catch (error) {
        print('Error during signup: $error');
        Error = error.toString();
        
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
                    '$Error',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class AllProjects extends StatefulWidget {
  @override
  _AllProjectsState createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  String _selectedYear = '2023'; // Default year
  String _selectedSemester = 'ODD'; // Default semester

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Year selection dropdown
          DropdownButton<String>(
            value: _selectedYear,
            onChanged: (String? newValue) {
              setState(() {
                _selectedYear = newValue!;
              });
            },
            items: List.generate(
              14, // Number of years from 2010 to 2023
              (index) => DropdownMenuItem(
                value: (2010 + index).toString(),
                child: Text((2010 + index).toString()),
              ),
            ),
          ),

          // Semester selection dropdown
          DropdownButton<String>(
            value: _selectedSemester,
            onChanged: (String? newValue) {
              setState(() {
                _selectedSemester = newValue!;
              });
            },
            items: ['ODD', 'EVEN']
                .map((semester) => DropdownMenuItem(
                      value: semester,
                      child: Text(semester),
                    ))
                .toList(),
          ),

          // Display projects based on selected year and semester
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ProjectInfo')
                .doc('year')
                .collection(_selectedYear)
                .doc('Semester')
                .collection(_selectedSemester)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final projects = snapshot.data!.docs;

              return Expanded(
                child: ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    final projectId = project.id;
                    final projectData =
                        project.data() as Map<String, dynamic>;

  // Fetch additional data based on the student ID
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('ProjectInfo')
                    .doc('year')
                    .collection(_selectedYear)
                    .doc('Semester')
                    .collection(_selectedSemester)
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
                                'cp: ${subcollectionData[0]['cp']}'), // Replace 'field1' with the actual field name
                            Text(
                                'Guide Name: ${subcollectionData[0]['Guide Name']}'), // Replace 'field2' with the actual field name
                                  Text(
                                'title: ${subcollectionData[0]['title']}'), 
                            Text(
                                'Description: ${subcollectionData[0]['Description']}'), // Replace 'field4' with the actual field name
                            // Add more fields as needed
                          ],
                        ),
                       
                      ),
                    );
                  } else {
                    return Container(); // Return an empty container if subcollectionData is empty
                  }
                },
              );
                    // Display project details here
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SetSemester extends StatefulWidget {
  @override
  _SetSemesterState createState() => _SetSemesterState();
}

class _SetSemesterState extends State<SetSemester> {
  String _selectedSemester = '';
  String _selectedYear = '';

  final List<String> semesterOptions = ['ODD', 'EVEN'];
  List<String> yearOptions = [];

  @override
  void initState() {
    super.initState();
    _initializeYearOptions();
  }

  void _initializeYearOptions() {
    int currentYear = DateTime.now().year;
    for (int year = currentYear; year >= 2010; year--) {
      yearOptions.add(year.toString());
    }
    _selectedYear = currentYear.toString();
  }

  void _submitSemester() async {
    if (_selectedSemester.isNotEmpty && _selectedYear.isNotEmpty) {
      try {
        // Update the 'semester' and 'year' fields in the existing 'admin' document
        await FirebaseFirestore.instance.collection('Admin').doc('Admin').update({
          'odd_collection': _selectedSemester,
          'year': _selectedYear,
        });

        // Display a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semester and Year Updated Successfully.'),
          ),
        );

        // Clear the form after submission
        setState(() {
          _selectedSemester = '';
        });
      } catch (error) {
        print('Error updating semester and year: $error');
        // Handle error updating semester and year
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Select Semester:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedSemester.isEmpty ? null : _selectedSemester,
                onChanged: (value) {
                  setState(() {
                    _selectedSemester = value!;
                  });
                },
                items: semesterOptions.map((String semester) {
                  return DropdownMenuItem<String>(
                    value: semester,
                    child: Text(semester),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Select Year:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedYear,
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value!;
                  });
                },
                items: yearOptions.map((String year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitSemester,
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
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
