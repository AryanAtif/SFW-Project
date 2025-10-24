import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Used for date formatting

import 'data_models.dart';
import 'home_page.dart';
import 'courses_page.dart';
import 'tasks_due_page.dart';
import 'weekly_calendar_page.dart'; 

// NOTE: Add 'intl' and 'table_calendar' to your pubspec.yaml file
// dependencies:
//   flutter:
//     sdk: flutter
//   intl: ^0.19.0 
//   table_calendar: ^3.0.9 


void main() {
  runApp(const StudentOrganizerApp());
}

class StudentOrganizerApp extends StatelessWidget {
  const StudentOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Organizer',
      theme: ThemeData(
        // Theming is kept the same
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF7EBE5), 
        appBarTheme: const AppBarTheme(
          color: Color(0xFFD6B59D), 
          elevation: 0,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.brown.shade800, fontSize: 36, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.brown.shade800, fontSize: 28),
          bodyMedium: TextStyle(color: Colors.brown.shade800, fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  
  // --- STATE DATA ---
  List<Course> courses = [
    Course('Differential Equations', 3),
    Course('Software Engineering', 2),
    Course('Object-Oriented Programming', 4),
    Course('Digital Logic Design', 4),
  ];

  List<Task> tasks = [
    Task('Finish the OOP Assignment', 'Today', isCompleted: false),
    Task('Prepare for the Software Engineering Quiz', 'Today'),
    Task('Practice the Differential Equations Problems', 'Today'),
    Task('Practice the Digital Logic Design Problems', 'This Week'),
    Task('Prepare for the Differential Equations Quiz', 'This Week'),
  ];
  
  List<Reminder> reminders = [
    Reminder('Software Engineering Quiz', DateTime.now().add(const Duration(days: 3))),
    Reminder('Midterm Fee Deadline', DateTime.now().add(const Duration(days: 14))),
  ];
  
  List<String> pinnedMessages = [
    'Remember to check the syllabus for all courses.',
    'Install Proteus on the PC.',
  ];

  // --- STATE MUTATION METHODS ---
  void addCourse(Course course) {
    setState(() => courses.add(course));
  }

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
      // Also add to pinned messages for visibility on home screen
      pinnedMessages.insert(0, 'NEW TASK ADDED: ${task.description}');
    });
  }
  
  void toggleTaskCompletion(Task task) {
    setState(() => task.isCompleted = !task.isCompleted);
  }

  void addReminder(Reminder reminder) {
    setState(() => reminders.add(reminder));
  }
   // NEW: Method to add a new pinned message
  void addPinnedMessage(String message) {
    setState(() {
      pinnedMessages.insert(0, message); // Add to the top of the list
    });
  }
    // NEW: Method to remove a pinned message
  void removePinnedMessage(String message) {
    setState(() {
      pinnedMessages.remove(message);
    });
  }
  void removeCourse(Course course) {
    setState(() => courses.remove(course));
  }

  void removeTask(Task task) {
    setState(() => tasks.remove(task));
  }

  void removeReminder(Reminder reminder) {
    setState(() => reminders.remove(reminder));
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer after selection
  }
 

  @override
  Widget build(BuildContext context) {
    // Pages now receive the state data and mutation callbacks
    final List<Widget> pages = <Widget>[
      HomePage
      (
        pinnedMessages: pinnedMessages,
        tasks: tasks, 
        addPinnedMessage: addPinnedMessage, 
        removePinnedMessage: removePinnedMessage
      ),


      CoursesPage
      (
        courses: courses,
        addCourse: addCourse
      ),

      WeeklyCalendarPage
      (
        reminders: reminders,
        addReminder: addReminder
      ),
      
      TasksDuePage
      (
        tasks: tasks, 
        addTask: addTask,
        toggleTaskCompletion: toggleTaskCompletion
      ),

      const Center(child: Text("AI Assistant Page (Future Feature)")), 
    ];

    return Scaffold(
      appBar: AppBar(
        // ... (AppBar content remains the same)
        title: Text(
          ['Home', 'Courses', 'Weekly Calendar', 'Tasks Due', 'AI Assistant'][_selectedIndex],
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.search, color: Colors.black, size: 30),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF5A443B), 
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Removed 'Blur' title and note text
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFD6B59D)),
              child: Text(''), 
            ),
            _buildDrawerItem(title: 'Home', index: 0, context: context),
            _buildDrawerItem(title: 'Courses', index: 1, context: context),
            _buildDrawerItem(title: 'Weekly Calendar', index: 2, context: context),
            _buildDrawerItem(title: 'Tasks Due', index: 3, context: context),
            _buildDrawerItem(title: 'AI Assistant', index: 4, context: context),
          ],
        ),
      ),
      body: pages[_selectedIndex], // Use the updated pages list
    );
  }

  // Helper function to build the interactive Drawer items (unchanged)
  Widget _buildDrawerItem({required String title, required int index, required BuildContext context}) {
    final isActive = _selectedIndex == index;
    final buttonColor = isActive ? const Color(0xFFD6B59D) : const Color(0xFFA2846A); 
    final textColor = isActive ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          onTap: () => _onItemTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}