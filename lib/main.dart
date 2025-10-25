import 'package:flutter/material.dart';

import 'data_models.dart';
import 'home_page.dart';
import 'courses_page.dart';
import 'tasks_due_page.dart';
import 'weekly_calendar_page.dart';
import 'ai_assistant_page.dart';
import 'gemini_chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const StudentOrganizerApp());
}

class StudentOrganizerApp extends StatelessWidget {
  const StudentOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Organizer',
      theme: ThemeData(
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
      pinnedMessages.insert(0, 'NEW TASK ADDED: ${task.description}');
    });
  }
  
  void toggleTaskCompletion(Task task) {
    setState(() => task.isCompleted = !task.isCompleted);
  }

  void addReminder(Reminder reminder) {
    setState(() => reminders.add(reminder));
  }
  
  void addPinnedMessage(String message) {
    setState(() {
      pinnedMessages.insert(0, message);
    });
  }
  
  void removePinnedMessage(String message) {
    setState(() {
      pinnedMessages.remove(message);
    });
  }

  void insertPinnedMessageAt(int index, String message) {
    setState(() {
      pinnedMessages.insert(index, message);
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      HomePage(
        pinnedMessages: pinnedMessages,
        tasks: tasks, 
        addPinnedMessage: addPinnedMessage, 
        removePinnedMessage: removePinnedMessage,
        insertPinnedMessageAt: insertPinnedMessageAt
      ),
      CoursesPage(
        courses: courses,
        addCourse: addCourse,
        removeCourse: removeCourse
      ),
      WeeklyCalendarPage(
        reminders: reminders,
        addReminder: addReminder,
        removeReminder: removeReminder
      ),
      TasksDuePage(
        tasks: tasks, 
        addTask: addTask,
        toggleTaskCompletion: toggleTaskCompletion,
        removeTask: removeTask
      ),
      const AIAssistantPage(),
      const GeminiChatPage()    
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Home', 'Courses', 'Weekly Calendar', 'Tasks Due', 'AI Assistant', 'Gemini Chat'][_selectedIndex],
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
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFD6B59D)),
              child: Text(''), 
            ),
            _buildDrawerItem(title: 'Home', index: 0, context: context),
            _buildDrawerItem(title: 'Courses', index: 1, context: context),
            _buildDrawerItem(title: 'Weekly Calendar', index: 2, context: context),
            _buildDrawerItem(title: 'Tasks Due', index: 3, context: context),
            _buildDrawerItem(title: 'AI Assistant', index: 4, context: context),
            _buildDrawerItem(title: 'Gemini Chat', index: 5, context: context),
          ],
        ),
      ),
      body: pages[_selectedIndex],
    );
  }

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