import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// dotenv temporarily removed to avoid runtime init errors on some devices.
// To enable .env support again, re-add flutter_dotenv and load it safely.

import 'data_models.dart';
import 'home_page.dart';
import 'courses_page.dart';
import 'tasks_due_page.dart';
import 'weekly_calendar_page.dart';
import 'ai_assistant_page.dart';
import 'gemini_chat_page.dart';
import 'diagnostics_page.dart';
import 'auth_page.dart';

void main() async {
  // Run the whole bootstrap inside a guarded zone so the binding is created
  // in the same zone that `runApp` will use (avoids 'Zone mismatch').
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Install a global Flutter error handler so uncaught framework errors are
    // rendered as a visible UI instead of silently leaving a black screen.
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      _showFatalError(details.exceptionAsString(), details.stack?.toString() ?? '');
    };

    // Use inline Supabase credentials for now to avoid startup failures.
    // Replace with secure environment loading in a follow-up change.
    final supabaseUrl = 'https://xgecdpvziuvwyqmrejvn.supabase.co';
    final supabaseKey = 'sb_secret_TxZ-fYRTADGf4krwo716Cw_DpPXcfm8';

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
    } catch (e, st) {
      _showFatalError(e.toString(), st.toString());
      return;
    }

    runApp(const StudentOrganizerApp());
  }, (e, st) {
    _showFatalError(e.toString(), st.toString());
  });
}

// Replace the running app with a simple error display so users can see
// exceptions that would otherwise leave the screen blank.
void _showFatalError(String error, String stack) {
  // Ensure we replace the UI on the next microtask so any ongoing
  // widget work completes.
  scheduleMicrotask(() {
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Fatal Error')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('An unexpected error occurred', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(error),
                const SizedBox(height: 12),
                Text(stack),
              ],
            ),
          ),
        ),
      ),
    ));
  });
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
  home: const AuthGate(),
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
    Course('Differential Equations', 3,
      instructor: 'Sir. Muhammad Irfan',
      description: 'Study of differential equations and their applications in engineering',
      schedule: 'Mon, Wed 10:00 AM - 11:30 AM'),
    Course('Software Engineering', 2,
      instructor: 'Dr. Mahmood Qureshi',
      description: 'Principles and practices of software development and project management',
      schedule: 'Tue, Thu 2:00 PM - 3:30 PM'),
    Course('Object-Oriented Programming', 4,
      instructor: 'Dr. Syed Abdul Mannan Kirmani',
      description: 'Advanced programming concepts using object-oriented methodology',
      schedule: 'Mon, Wed, Fri 1:00 PM - 2:30 PM'),
    Course('Digital Logic Design', 4,
      instructor: 'Dr. Babar Mansoor',
      description: 'Design and analysis of digital circuits and systems',
      schedule: 'Tue, Thu 9:00 AM - 10:30 AM'),
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

  // Called when a course object is edited to trigger UI refresh
  void updateCourse(Course course) {
    setState(() {
      // Course objects are mutable; calling setState will refresh the UI
    });
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
        removeCourse: removeCourse,
        updateCourse: updateCourse,
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

  final user = Supabase.instance.client.auth.currentUser;
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
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
            // _buildDrawerItem(title: 'Gemini Chat', index: 5, context: context),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.white),
              title: const Text('Diagnostics', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticsPage()));
              },
            ),
          ],
        ),
      ),
        body: Column(
          children: [
            if (user == null) Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8.0),
              child: const Text('Warning: Not signed in (Supabase). Uploads may be rejected or signed URLs may not be available.', style: TextStyle(color: Colors.red)),
            ),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
    ),
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