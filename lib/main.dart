
import 'package:flutter/material.dart';

void main() {
  runApp(const SchoolApp());
}

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// نموذج بيانات الطالب
class Student {
  final String id;
  String name;
  String grade;
  String section;
  String parentName;
  String parentPhone;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    required this.parentName,
    required this.parentPhone,
  });
}

// بيانات تجريبية مشتركة بين الصفحات
class SchoolData {
  static final List<Student> students = [
    Student(
      id: '1001',
      name: 'أحمد محمد',
      grade: 'الأول',
      section: 'أ',
      parentName: 'محمد أحمد',
      parentPhone: '',
    ),
    Student(
      id: '1002',
      name: 'محمد علي',
      grade: 'الثاني',
      section: 'أ',
      parentName: 'علي محمد',
      parentPhone: '',
    ),
    Student(
      id: '1003',
      name: 'خالد عبدالله',
      grade: 'الثالث',
      section: 'ب',
      parentName: 'عبدالله خالد',
      parentPhone: '',
    ),
  ];
}

// شاشة اختيار الحساب
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
                  const SizedBox(height: 8),
                  const Text(
                    'منصة التواصل المدرسي',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 45),
                  const Text(
                    'اختر نوع الحساب للتجربة',
                    style: TextStyle(fontSize: 19),
                  ),
                  const SizedBox(height: 22),
                  roleButton(
                    context,
                    'المعلم',
                    Icons.person,
                  ),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Text(
            role,
            style: const TextStyle(fontSize: 18),
          ),
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

// الصفحة الرئيسية
class HomePage extends StatefulWidget {
  final String role;

  const HomePage({
    super.key,
    required this.role,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  String search = '';
  String selectedGrade = 'الكل';

  final List<String> titles = [
    'الرئيسية',
    'الطلاب',
    'الدرجات',
    'الحضور',
    'الواجبات',
  ];

  final List<String> grades = [
    'الأول',
    'الثاني',
    'الثالث',
    'الرابع',
    'الخامس',
    'السادس',
    'السابع',
    'الثامن',
    'التاسع',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[selected]),
          actions: [
            IconButton(
              tooltip: 'تسجيل الخروج',
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
              'إدارة الدرجات',
              Icons.grade,
              'سيتم تطوير تسجيل درجات الطلاب هنا',
            ),
            simplePage(
              'الحضور والغياب',
              Icons.fact_check,
              'سيتم تطوير سجل الحضور هنا',
            ),
            simplePage(
              'الواجبات المدرسية',
              Icons.menu_book,
              'سيتم تطوير إدارة الواجبات هنا',
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
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'الطلاب',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_outline),
              selectedIcon: Icon(Icons.star),
              label: 'الدرجات',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle),
              label: 'الحضور',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: 'الواجبات',
            ),
          ],
        ),
      ),
    );
  }

  // لوحة التحكم
  Widget dashboard() {
    final sections = SchoolData.students
        .map((s) => '${s.grade}-${s.section}')
        .toSet()
        .length;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'مرحباً بك - ${widget.role}',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'لوحة متابعة العملية التعليمية',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 25),
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
                '$sections',
                Icons.class_,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 28),
        const Text(
          'الوصول السريع',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              quickAction(
                'إدارة الطلاب',
                Icons.people,
                1,
              ),
              const Divider(height: 1),
              quickAction(
                'إدارة الدرجات',
                Icons.grade,
                2,
              ),
              const Divider(height: 1),
              quickAction(
                'تسجيل الحضور',
                Icons.fact_check,
                3,
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
              size: 34,
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 12),
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

  Widget quickAction(
    String title,
    IconData icon,
    int index,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_left),
      onTap: () {
        setState(() => selected = index);
      },
    );
  }

  // صفحة الطلاب
  Widget studentsPage() {
    final filtered = SchoolData.students.where((student) {
      final matchSearch =
          student.name.toLowerCase().contains(
                search.toLowerCase(),
              ) ||
          student.id.contains(search);

      final matchGrade =
          selectedGrade == 'الكل' ||
          student.grade == selectedGrade;

      return matchSearch && matchGrade;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('إضافة طالب جديد'),
                  onPressed: () => studentForm(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: (value) {
                  setState(() => search = value);
                },
                decoration: const InputDecoration(
                  hintText: 'ابحث باسم الطالب أو رقمه',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(selectedGrade),
                initialValue: selectedGrade,
                decoration: const InputDecoration(
                  labelText: 'تصفية حسب الصف',
                ),
                items: ['الكل', ...grades].map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text(
                      grade == 'الكل'
                          ? 'جميع الصفوف'
                          : 'الصف $grade',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedGrade = value);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('لا توجد نتائج مطابقة'),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final student = filtered[index];

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
                        subtitle: Text(
                          'الصف ${student.grade} - '
                          'الفصل ${student.section}',
                        ),
                        trailing:
                            const Icon(Icons.chevron_left),
                        onTap: () => studentProfile(student),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // نموذج إضافة وتعديل الطالب
  void studentForm({Student? student}) {
    final editing = student != null;

    final idController = TextEditingController(
      text: student?.id ?? '',
    );
    final nameController = TextEditingController(
      text: student?.name ?? '',
    );
    final parentController = TextEditingController(
      text: student?.parentName ?? '',
    );
    final phoneController = TextEditingController(
      text: student?.parentPhone ?? '',
    );

    String grade = student?.grade ?? 'الأول';
    String section = student?.section ?? 'أ';
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(
                  editing
                      ? 'تعديل بيانات الطالب'
                      : 'إضافة طالب جديد',
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: idController,
                            enabled: !editing,
                            decoration: const InputDecoration(
                              labelText: 'الرقم المدرسي',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            validator: (value) {
                              final id = value?.trim() ?? '';
                              if (id.isEmpty) {
                                return 'أدخل الرقم المدرسي';
                              }
                              if (!editing &&
                                  SchoolData.students.any(
                                    (s) => s.id == id,
                                  )) {
                                return 'الرقم مستخدم مسبقاً';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم الطالب الكامل',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'أدخل اسم الطالب';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            key: ValueKey('grade-$grade'),
                            initialValue: grade,
                            decoration: const InputDecoration(
                              labelText: 'الصف الدراسي',
                            ),
                            items: grades.map((g) {
                              return DropdownMenuItem(
                                value: g,
                                child: Text('الصف $g'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  grade = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            key: ValueKey('section-$section'),
                            initialValue: section,
                            decoration: const InputDecoration(
                              labelText: 'الفصل',
                            ),
                            items: ['أ', 'ب', 'ج', 'د'].map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  section = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: parentController,
                            decoration: const InputDecoration(
                              labelText: 'اسم ولي الأمر',
                              prefixIcon:
                                  Icon(Icons.family_restroom),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'هاتف ولي الأمر',
                              prefixIcon: Icon(Icons.phone),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      setState(() {
                        if (editing) {
                          student.name =
                              nameController.text.trim();
                          student.grade = grade;
                          student.section = section;
                          student.parentName =
                              parentController.text.trim();
                          student.parentPhone =
                              phoneController.text.trim();
                        } else {
                          SchoolData.students.add(
                            Student(
                              id: idController.text.trim(),
                              name: nameController.text.trim(),
                              grade: grade,
                              section: section,
                              parentName:
                                  parentController.text.trim(),
                              parentPhone:
                                  phoneController.text.trim(),
                            ),
                          );
                        }
                      });

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            editing
                                ? 'تم تعديل الطالب بنجاح'
                                : 'تمت إضافة الطالب بنجاح',
                          ),
                        ),
                      );
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ملف الطالب
  void studentProfile(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (pageContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('ملف الطالب'),
              ),
              body: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 45),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    student.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  infoTile(
                    'الرقم المدرسي',
                    student.id,
                  ),
                  infoTile(
                    'الصف الدراسي',
                    student.grade,
                  ),
                  infoTile(
                    'الفصل',
                    student.section,
                  ),
                  infoTile(
                    'ولي الأمر',
                    student.parentName,
                  ),
                  infoTile(
                    'رقم الهاتف',
                    student.parentPhone,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل البيانات'),
                    onPressed: () {
                      Navigator.pop(pageContext);
                      studentForm(student: student);
                    },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('حذف الطالب'),
                    onPressed: () {
                      confirmDelete(student, pageContext);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget infoTile(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(
          value.isEmpty ? 'غير محدد' : value,
        ),
      ),
    );
  }

  // تأكيد الحذف
  void confirmDelete(
    Student student,
    BuildContext profileContext,
  ) {
    showDialog<void>(
      context: profileContext,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text(
              'هل تريد حذف الطالب ${student.name}؟',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    SchoolData.students.remove(student);
                  });
                  Navigator.pop(dialogContext);
                  Navigator.pop(profileContext);
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }

  // الصفحات التي سنطورها لاحقاً
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
