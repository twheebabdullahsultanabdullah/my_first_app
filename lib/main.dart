
import 'package:flutter/material.dart';

void main() => runApp(const SchoolApp());

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صِلة التعليمي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
      ),
      home: const LoginPage(),
    );
  }
}

class Student {
  final String name;
  final String grade;
  Student(this.name, this.grade);
}

class SchoolData {
  static final students = <Student>[
    Student('أحمد محمد', 'الصف الأول'),
    Student('محمد علي', 'الصف الثاني'),
    Student('خالد عبدالله', 'الصف الثالث'),
  ];
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 90,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'صِلة التعليمي',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'منصة التواصل المدرسي',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'اختر نوع الحساب للتجربة',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  roleButton(context, 'المعلم', Icons.person),
                  roleButton(
                    context,
                    'ولي الأمر',
                    Icons.family_restroom,
                  ),
                  roleButton(
                    context,
                    'الإدارة',
                    Icons.admin_panel_settings,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget roleButton(
    BuildContext context,
    String role,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Text(role),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(role: role),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String role;
  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;

  final titles = [
    'الرئيسية',
    'الطلاب',
    'الدرجات',
    'الحضور',
    'الواجبات',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          title: Text(titles[selected]),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: selected,
          children: [
            dashboard(),
            studentsPage(),
            simplePage(
              'الدرجات',
              Icons.grade,
              'سيتم إضافة نظام تقييم الطلاب هنا',
            ),
            simplePage(
              'الحضور',
              Icons.fact_check,
              'سيتم إضافة تسجيل الحضور والغياب هنا',
            ),
            simplePage(
              'الواجبات',
              Icons.menu_book,
              'سيتم إضافة الواجبات المدرسية هنا',
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: (index) {
            setState(() => selected = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              label: 'الطلاب',
            ),
            NavigationDestination(
              icon: Icon(Icons.grade_outlined),
              label: 'الدرجات',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              label: 'الحضور',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              label: 'الواجبات',
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboard() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'مرحباً بك - ${widget.role}',
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text('لوحة متابعة العملية التعليمية'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: statCard(
                'الطلاب',
                '${SchoolData.students.length}',
                Icons.people,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: statCard(
                'الفصول',
                '3',
                Icons.class_,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: statCard(
                'الواجبات',
                '0',
                Icons.assignment,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: statCard(
                'التنبيهات',
                '0',
                Icons.notifications,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        const Text(
          'الوصول السريع',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('إدارة الطلاب'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => setState(() => selected = 1),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.grade),
                title: const Text('إدارة الدرجات'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => setState(() => selected = 2),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.fact_check),
                title: const Text('تسجيل الحضور'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => setState(() => selected = 3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget studentsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('إضافة طالب'),
              onPressed: addStudent,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: SchoolData.students.length,
            itemBuilder: (context, index) {
              final student = SchoolData.students[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(student.name),
                  subtitle: Text(student.grade),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void addStudent() {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة طالب جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الطالب',
              ),
            ),
            TextField(
              controller: gradeController,
              decoration: const InputDecoration(
                labelText: 'الصف الدراسي',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  gradeController.text.trim().isEmpty) {
                return;
              }
              setState(() {
                SchoolData.students.add(
                  Student(
                    nameController.text.trim(),
                    gradeController.text.trim(),
                  ),
                );
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Widget simplePage(
    String title,
    IconData icon,
    String description,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 75,
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
