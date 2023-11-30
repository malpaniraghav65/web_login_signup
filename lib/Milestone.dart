import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MilestoneScreen extends StatefulWidget {
  final String enrollmentNumber;

  MilestoneScreen({required this.enrollmentNumber});

  @override
  _MilestoneScreenState createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
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

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController completionDateController = TextEditingController();
  int credit = 1;
  String? status;
  String? editingMilestoneId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Milestones for ${widget.enrollmentNumber}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add a New Milestone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Milestone Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Credit: $credit'),
                IconButton(
                  onPressed: () {
                    if (credit < 10) {
                      setState(() {
                        credit++;
                      });
                    }
                  },
                  icon: Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () {
                    if (credit > 1) {
                      setState(() {
                        credit--;
                      });
                    }
                  },
                  icon: Icon(Icons.remove),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Completion Date: '),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: IgnorePointer(
                      child: TextField(
                        controller: completionDateController,
                        decoration: InputDecoration(
                          labelText: 'Select Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                  calculateAndStoreCreditScore(); // calculate and store credit score
                saveMilestone();
                //calculateAndStoreCreditScore(); // Calculate and store credit score
              },
              child: Text('Add Milestone'),
            ),
            Divider(),
            Text(
              'Existing Milestones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Milestones')
                    .doc('year')
                    .collection(year)
                    .doc('Semester')
                    .collection(Semester)
                    .doc(widget.enrollmentNumber)
                    .collection('Milestones')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final milestones = snapshot.data?.docs;

                  return ListView.builder(
                    itemCount: milestones?.length ?? 0,
                    itemBuilder: (context, index) {
                      final milestone =
                          milestones?[index].data() as Map<String, dynamic>;
                      final milestoneId = milestones?[index].id;
                      final title = milestone['title'];
                      final description = milestone['description'];
                      final existingCredit = milestone['credit'];
                      final completionDate = milestone['completionDate'];
                      status = milestone['status'];

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: (editingMilestoneId == milestoneId)
                              ? TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Milestone Title',
                                  ),
                                )
                              : Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (editingMilestoneId == milestoneId)
                                  ? TextField(
                                      controller: descriptionController,
                                      decoration: InputDecoration(
                                        labelText: 'Description',
                                      ),
                                    )
                                  : Text('Description: $description'),
                              (editingMilestoneId == milestoneId)
                                  ? Row(
                                      children: [
                                        Text('Credit: $credit'),
                                        IconButton(
                                          onPressed: () {
                                            if (credit < 10) {
                                              setState(() {
                                                credit++;
                                              });
                                            }
                                          },
                                          icon: Icon(Icons.add),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            if (credit > 1) {
                                              setState(() {
                                                credit--;
                                              });
                                            }
                                          },
                                          icon: Icon(Icons.remove),
                                        ),
                                      ],
                                    )
                                  : Text('Credit: $existingCredit'),
                              (editingMilestoneId == milestoneId)
                                  ? Row(
                                      children: [
                                        Text('Completion Date: '),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              _selectDate(context);
                                            },
                                            child: IgnorePointer(
                                              child: TextField(
                                                controller:
                                                    completionDateController,
                                                decoration: InputDecoration(
                                                  labelText: 'Select Date',
                                                  suffixIcon:
                                                      Icon(Icons.calendar_today),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text('Completion Date: $completionDate'),
                              Text('Status: $status'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (editingMilestoneId == milestoneId)
                                ElevatedButton(
                                  onPressed: () {
                                    // Save the updated milestone to Firebase Firestore
                                      calculateAndStoreCreditScore(); // Recalculate and store credit score
                                    updateMilestone(milestoneId!);
                                  },
                                  child: Text('Save'),
                                ),
                              if (editingMilestoneId != milestoneId)
                                TextButton(
                                  onPressed: () {
                                    // Enable editing for this milestone
                                    setState(() {
                                      editingMilestoneId = milestoneId;
                                      titleController.text = title;
                                      descriptionController.text = description;
                                      credit = existingCredit;
                                      completionDateController.text =
                                          completionDate;
                                    });
                                  },
                                  child: Text('Edit'),
                                ),
                              TextButton(
                                onPressed: () {
                                  // Delete the milestone from Firebase Firestore
                                    calculateAndStoreCreditScore(); // Recalculate and store credit score
                                  deleteMilestone(milestoneId!);
                                
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        final formattedDate = "${picked.day}/${picked.month}/${picked.year}";
        completionDateController.text = formattedDate;
      });
    }
  }

  Future<void> saveMilestone() async {
    final enrollmentNumber = widget.enrollmentNumber;
    final milestoneData = {
      'title': titleController.text,
      'description': descriptionController.text,
      'credit': credit,
      'completionDate': completionDateController.text,
      'status': 'pending', // Set status as 'pending' initially
    };

    // Check if the document with the enrollment number exists
    final enrollmentDoc = FirebaseFirestore.instance
        .collection('Milestones')
        .doc('year')
        .collection(year)
        .doc('Semester')
        .collection(Semester)
        .doc(enrollmentNumber);

    if (!(await enrollmentDoc.get()).exists) {
      await enrollmentDoc.set({});
    }

    // Save the new milestone under the enrollment number
    await enrollmentDoc.collection('Milestones').add(milestoneData);

    // Clear the form fields and reset the edit state
    titleController.clear();
    descriptionController.clear();
    completionDateController.clear();
    setState(() {
      credit = 1;
      editingMilestoneId = null;
    });

  }

  Future<void> updateMilestone(String milestoneId) async {
    final enrollmentNumber = widget.enrollmentNumber;
    final milestoneData = {
      'title': titleController.text,
      'description': descriptionController.text,
      'credit': credit,
      'completionDate': completionDateController.text,
    };

    // Update the existing milestone in Firebase Firestore
    await FirebaseFirestore.instance
        .collection('Milestones')
        .doc('year')
        .collection(year)
        .doc('Semester')
        .collection(Semester)
        .doc(enrollmentNumber)
        .collection('Milestones')
        .doc(milestoneId)
        .update(milestoneData);

    // Clear the form fields and reset the edit state
    titleController.clear();
    descriptionController.clear();
    completionDateController.clear();
    setState(() {
      credit = 1;
      editingMilestoneId = null;
    });
  }

  Future<void> deleteMilestone(String milestoneId) async {
    final enrollmentNumber = widget.enrollmentNumber;

    // Delete the milestone from Firebase Firestore
    await FirebaseFirestore.instance
        .collection('Milestones')
        .doc('year')
        .collection(year)
        .doc('Semester')
        .collection(Semester)
        .doc(enrollmentNumber)
        .collection('Milestones')
        .doc(milestoneId)
        .delete();
  }

  Future<void> calculateAndStoreCreditScore() async {
    final enrollmentNumber = widget.enrollmentNumber;

    // Calculate the Total Credit
    int totalCredit = 0;
    final totalMilestonesQuery = await FirebaseFirestore.instance
        .collection('Milestones')
        .doc('year')
        .collection(year)
        .doc('Semester')
        .collection(Semester)
        .doc(enrollmentNumber)
        .collection('Milestones')
        .get();

    totalMilestonesQuery.docs.forEach((milestone) {
      totalCredit += milestone['credit'] as int ;
    });

    // Calculate the Completed Credit
    int completedCredit = 0;
    final completedMilestonesQuery = await FirebaseFirestore.instance
        .collection('Milestones')
        .doc('year')
        .collection(year)
        .doc('Semester')
        .collection(Semester)
        .doc(enrollmentNumber)
        .collection('Milestones')
        .where('status', isEqualTo: 'complete')
        .get();

    completedMilestonesQuery.docs.forEach((milestone) {
      completedCredit += milestone['credit']as int;
    });

    // Store the Credit Score in Firestore
    final creditScoreData = {
      'totalCredit': totalCredit,
      'completedCredit': completedCredit,
    };

    await FirebaseFirestore.instance
        .collection('Milestones')
        .doc('year')
        .collection(year)
        .doc('Semester')
        .collection(Semester)
        .doc(enrollmentNumber)
        .collection('CreditScore')
        .doc('creditScoreDoc')
        .set(creditScoreData);
  }
}
