import 'package:flutter/material.dart';
import 'data_models.dart';

class CoursesPage extends StatelessWidget {
  final List<Course> courses;
  final Function(Course) addCourse;
  final Function(Course) removeCourse;

  const CoursesPage
  (
    {
      super.key,
      required this.courses,
      required this.addCourse,
      required this.removeCourse,
    }
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Courses',
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          
          // Add More Courses Button/Link
          Align(
            alignment: Alignment.centerRight,
            child: _buildAddCourseButton(context),
          ),
          const SizedBox(height: 20),

          // Dynamic Course Buttons
          ...courses.map((course) => _CourseButton(
            course: course,
            onRemove: removeCourse,
            )).toList(),
          
          const SizedBox(height: 40),
          
          // Removed < Back text
        ],
      ),
    );
  }

  // Widget for the 'Add More Courses' functionality
  Widget _buildAddCourseButton(BuildContext context) {
    return TextButton(
      onPressed: () => _showAddCourseDialog(context),
      child: Text(
        '+ Add More Courses',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // Dialog to capture new course details
  void _showAddCourseDialog(BuildContext context) {
    String title = '';
    int creditHours = 3; // Default value

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => title = value,
                decoration: const InputDecoration(labelText: 'Course Title'),
              ),
              TextField(
                onChanged: (value) => creditHours = int.tryParse(value) ?? 3,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Credit Hours (e.g., 3)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  addCourse(Course(title, creditHours));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// Course button widget (unchanged visually)

class _CourseButton extends StatelessWidget {
  final Course course;
  final Function(Course) onRemove;

  const _CourseButton({
    required this.course,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        color: const Color(0xFFA2846A), 
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on ${course.title} (Detail Page)'))
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Credit Hours: ${course.creditHours}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                  onPressed: () => _showDeleteConfirmation(context),
                  padding: const EdgeInsets.all(8.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete "${course.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onRemove(course);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course deleted.'))
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

/*
class _CourseButton extends StatelessWidget {
  final Course course;

  const _CourseButton({required this.course});

  @override
  Widget build(BuildContext context) {
    // ... (Container and InkWell code remains the same)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        color: const Color(0xFFA2846A), 
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on ${course.title} (Detail Page)'))
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  'Credit Hours: ${course.creditHours}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/