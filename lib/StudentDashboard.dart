import 'dart:async';
import 'dart:html' as html;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class DashboardScreen extends StatefulWidget {
  final String enrollmentNumber; // Add this variable

  DashboardScreen(
      {required this.enrollmentNumber}); // Constructor to receive the enrollmentNumber

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String enrollmentNumber;

  @override
  void initState() {
    super.initState();
    enrollmentNumber = widget.enrollmentNumber;
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: Colors.black87,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          CreateProjectPage(enrollmentNumber: enrollmentNumber),
          ProgressPage(enrollmentNumber: enrollmentNumber),
          RemarksPage(enrollmentNumber: enrollmentNumber),
          LogoutPage(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                enrollmentNumber,
                style: TextStyle(
                  fontSize: 40, // Set the font size to 20
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Create Project'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Progress'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Milestoneas'),
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
            label: 'Create Project',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: 'Milestones',
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

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class CreateProjectPage extends StatefulWidget {
  final String enrollmentNumber;

  CreateProjectPage({required this.enrollmentNumber});

  @override
  _CreateProjectPageState createState() =>
      _CreateProjectPageState(enrollmentNumber: enrollmentNumber);
}

class _CreateProjectPageState extends State<CreateProjectPage> {
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

  final String enrollmentNumber;
  String ProjectFacultyname = '';
  String dropdownValue = 'CP-1';
  String projectTitle = '';
  String projectDescription = '';
  List<String> dropdownItems = ['CP-1', 'CP-2', 'CP-3'];

  _CreateProjectPageState({required this.enrollmentNumber});

  void _resetState() {
    setState(() {
      ProjectFacultyname = '';
      dropdownValue = 'CP-1';
      projectTitle = '';
      projectDescription = '';
    });
  }

  void _saveData() {
    if (ProjectFacultyname.isNotEmpty && projectTitle.isNotEmpty) {
      // Access Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Define references to the student document and the user project
      DocumentReference studentDocument =
          firestore.collection('ProjectInfo')
          .doc('year')
          .collection(year)
          .doc('Semester')
          .collection(Semester)
          .doc(enrollmentNumber);
      DocumentReference userProjects =
          studentDocument.collection('User Project').doc('Project');

      // Check if the user project document exists
      userProjects.get().then((querySnapshot) {
        if (querySnapshot.exists) {
          var userData = querySnapshot.data() as Map<String, dynamic>?;

          if (userData != null) {
            String? prevfacultyName = userData['Guide Name'] as String?;
            String? prevdropdownValue = userData['cp'] as String?;
            String? prevprojectTitle = userData['title'] as String?;
            String? prevprojectDescription =
                userData['Description'] as String?;

            if (prevfacultyName != "" &&
               prevdropdownValue != "" &&
                prevprojectTitle != "" &&
                prevprojectDescription != "") {
              // All required fields are present and not null, you can proceed
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('You have already submitted your project.'),
              ));
              print('You have already submitted your project.');
            } else {
              // Handle the case where one or more required fields are missing or null
              studentDocument.collection('User Project').doc('Project').set({
                'Guide Name': ProjectFacultyname,
                'cp': dropdownValue,
                'title': projectTitle,
                'Description': projectDescription,
              }).then((_) {
                // Data added successfully
                print('Document ID');
                _resetState();
              }).catchError((e) {
                // Handle errors
                print('Error: $e');
              });
            }
          }
        } 
      }).catchError((e) {
        // Handle errors when checking if the document exists
        print('Error: $e');
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: screenWidth > 600 ? 600 : screenWidth * 0.9,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Short Name of your Faculty:',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                onChanged: (value) {
                  setState(() {
                    ProjectFacultyname = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select a Value:',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: dropdownValue,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items:
                    dropdownItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Project Title:',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  setState(() {
                    projectTitle = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Project Description:',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 100,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      projectDescription = value;
                    });
                  },
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _saveData();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black87,
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



class ProgressPage extends StatefulWidget {
  final String enrollmentNumber;

  ProgressPage({required this.enrollmentNumber});

  @override
  _ProgressPageState createState() =>
      _ProgressPageState(enrollmentNumber: enrollmentNumber);
  // @override
  // _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
   final String enrollmentNumber;
    _ProgressPageState({required this.enrollmentNumber});
  String description = '';
  html.File? uploadedFile;
  html.File? filename;

  void _pickFile() async {
    final html.InputElement input = html.InputElement(type: 'file')
      ..accept = '.pdf,.doc,.zip';
    input.click();

    input.onChange.listen((e) {
      final fileList = input.files;
      if (fileList != null && fileList.isNotEmpty) {
        final file = fileList[0];
        setState(() {
          uploadedFile = file;
          filename = file;
        });
      }
    });
  }
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
   // fetchMilestones();
    fetchData(); // Fetch data when the widget initializes
  }


  Future<void> _uploadFile() async {
    if (uploadedFile != null) {
      try {
        final String storagePath = 'uploads/${filename!.name}';
        final Reference storageRef =
            FirebaseStorage.instance.ref().child(storagePath);

        final UploadTask uploadTask = storageRef.putBlob(uploadedFile!);

        await uploadTask.whenComplete(() {
          print('File uploaded successfully.');
        });
      } catch (error) {
        print('Error uploading file: $error');
      }
    }
  }

  void _saveData() async {
    if (description.isNotEmpty && uploadedFile != null) {
      try {
        await _uploadFile();

        final String downloadURL =
            await FirebaseStorage.instance.ref().child('uploads/${filename!.name}').getDownloadURL();

        await FirebaseFirestore.instance.collection('AllProject').doc('year')
        .collection(year)
        .doc('Semester')
        .collection(Semester)
        .doc(enrollmentNumber)
        .collection('Project')
        .add({
          'description': description,
          'file_name': filename!.name,
          'download_url': downloadURL,
        });

        setState(() {
          description = '';
          uploadedFile = null;
          filename = null;
        });

        print('Data saved successfully.');
      } catch (error) {
        print('Error saving data: $error');
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Description:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: Text('Upload File'),
                  ),
                  SizedBox(height: 20),
                  if (uploadedFile != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Uploaded File:',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        Text('File Name: ${filename!.name}'),
                        SizedBox(height: 10),
                        Text('Description: $description'),
                      ],
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class RemarksPage extends StatefulWidget {
  final String enrollmentNumber;

  RemarksPage({required this.enrollmentNumber});

  @override
  _RemarksPageState createState() => _RemarksPageState(enrollmentNumber: enrollmentNumber);
}

class _RemarksPageState extends State<RemarksPage> {
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
    fetchMilestones();
    fetchData(); // Fetch data when the widget initializes
  }

  final String enrollmentNumber;
  List<DocumentSnapshot> milestones = [];

  _RemarksPageState({required this.enrollmentNumber});


  Future<void> fetchMilestones() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Milestones')
        .doc('year')
        .collection(year)
        .doc('Semester')
        .collection(Semester)
        .doc(enrollmentNumber)
        .collection('Milestones')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        milestones = querySnapshot.docs;
      });
    }
  }

  Future<void> markMilestoneComplete(DocumentSnapshot milestone) async {
    // Mark the milestone as complete
    await milestone.reference.update({'status': 'complete'});

    // Refresh the milestone list
    fetchMilestones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Milestone Page'),
      ),
      body: ListView.builder(
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final milestone = milestones[index];
          final title = milestone['title'];
          final description = milestone['description'];
          final credit = milestone['credit'];
          final date = milestone['completionDate'];
          final status = milestone['status'];

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('title: $title'),
                  Text('Description: $description'),
                  Text('Credit: $credit'),
                  Text('Completion Date: $date'),
                  Text('Status: $status'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status != 'complete')
                    TextButton(
                      onPressed: () {
                        markMilestoneComplete(milestone);
                      },
                      child: Text('Mark as Complete'),
                    ),
                ],
              ),
            ),
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