import 'package:flutter/material.dart';

void main() => runApp(const SilaApp());

class Student {
  final int id;
  String name, grade, section, parent, phone;
  Student(this.id, this.name, this.grade, this.section, this.parent, this.phone);
}

class Homework {
  String title, description, grade, due;
  Homework(this.title, this.description, this.grade, this.due);
}

class SilaApp extends StatelessWidget {
  const SilaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'صِلة التعليمي',
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xff2563eb),
      scaffoldBackgroundColor: const Color(0xfff4f7fc),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    home: const TeacherPage(),
  );
}

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});
  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  int tab = 0;
  int nextId = 1004;
  String teacher = 'المعلم', school = 'مدرستي', subject = 'الرياضيات';
  String filter = 'الكل', search = '';
  final grades = ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس', 'السابع', 'الثامن', 'التاسع'];
  final students = <Student>[
    Student(1001, 'أحمد محمد', 'الأول', 'أ', 'محمد أحمد', ''),
    Student(1002, 'محمد علي', 'الثاني', 'أ', 'علي محمد', ''),
    Student(1003, 'خالد عبدالله', 'الثالث', 'ب', 'عبدالله خالد', ''),
  ];
  final Map<int, Map<String, int>> scores = {};
  final Map<String, Map<int, String>> attendance = {};
  final homeworks = <Homework>[];
  final announcements = <String>[];
  final Map<String, int> weights = {'تحريري': 50, 'شفوي': 20, 'نشاط': 20, 'سلوك': 10};
  final tabs = ['الرئيسية', 'الطلاب', 'الدرجات', 'الحضور', 'الواجبات', 'المزيد'];
  final icons = [Icons.dashboard_outlined, Icons.people_outline, Icons.grade_outlined, Icons.fact_check_outlined, Icons.menu_book_outlined, Icons.more_horiz];

  String get today => DateTime.now().toIso8601String().substring(0, 10);
  void message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  InputDecoration field(String label) => InputDecoration(labelText: label);

  Future<void> editStudent([Student? s]) async {
    final id = TextEditingController(text: s?.id.toString() ?? nextId.toString());
    final name = TextEditingController(text: s?.name ?? '');
    final parent = TextEditingController(text: s?.parent ?? '');
    final phone = TextEditingController(text: s?.phone ?? '');
    String grade = s?.grade ?? grades.first;
    String section = s?.section ?? 'أ';
    final key = GlobalKey<FormState>();
    await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, change) => AlertDialog(
      title: Text(s == null ? 'إضافة طالب' : 'تعديل الطالب'),
      content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: id, enabled: s == null, keyboardType: TextInputType.number, decoration: field('الرقم المدرسي'), validator: (v) {
          final number = int.tryParse(v ?? '');
          if (number == null) return 'أدخل رقماً صحيحاً';
          if (s == null && students.any((x) => x.id == number)) return 'الرقم مستخدم';
          return null;
        }),
        const SizedBox(height: 10),
        TextFormField(controller: name, decoration: field('اسم الطالب'), validator: (v) => (v ?? '').trim().isEmpty ? 'الاسم مطلوب' : null),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: grade, decoration: field('الصف'), items: grades.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => change(() => grade = v ?? grade)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: section, decoration: field('الفصل'), items: ['أ','ب','ج','د'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => change(() => section = v ?? section)),
        const SizedBox(height: 10),
        TextFormField(controller: parent, decoration: field('اسم ولي الأمر')),
        const SizedBox(height: 10),
        TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: field('هاتف ولي الأمر')),
      ])))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () {
        if (!key.currentState!.validate()) return;
        setState(() {
          if (s == null) {
            final number = int.parse(id.text);
            students.add(Student(number, name.text.trim(), grade, section, parent.text.trim(), phone.text.trim()));
            if (number >= nextId) nextId = number + 1;
          } else {
            s.name = name.text.trim(); s.grade = grade; s.section = section;
            s.parent = parent.text.trim(); s.phone = phone.text.trim();
          }
        });
        Navigator.pop(ctx);
        message('تم حفظ بيانات الطالب');
      }, child: const Text('حفظ'))],
    )));
    id.dispose(); name.dispose(); parent.dispose(); phone.dispose();
  }

  void studentDetails(Student s) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(s.name, style: Theme.of(ctx).textTheme.headlineSmall),
      const SizedBox(height: 12),
      Text('الرقم: ${s.id}'), Text('الصف: ${s.grade} - الفصل: ${s.section}'),
      Text('ولي الأمر: ${s.parent.isEmpty ? "غير محدد" : s.parent}'),
      Text('الهاتف: ${s.phone.isEmpty ? "غير محدد" : s.phone}'),
      const SizedBox(height: 14),
      FilledButton.icon(onPressed: () { Navigator.pop(ctx); editStudent(s); }, icon: const Icon(Icons.edit), label: const Text('تعديل')),
      OutlinedButton.icon(onPressed: () async {
        Navigator.pop(ctx);
        final yes = await showDialog<bool>(context: context, builder: (d) => AlertDialog(title: const Text('حذف الطالب؟'), content: Text('سيتم حذف ${s.name} ودرجاته وحضوره التجريبي.'), actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('إلغاء')), TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('حذف'))]));
        if (yes == true) setState(() { students.remove(s); scores.remove(s.id); for (final day in attendance.values) { day.remove(s.id); } });
      }, icon: const Icon(Icons.delete_outline), label: const Text('حذف')),
    ]))));
  }

  Widget heading(String title, {Widget? action}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold))), if (action != null) action]));
  Widget stat(String label, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [Icon(icon, size: 30, color: const Color(0xff2563eb)), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), Text(label)])));
  Widget dashboard() {
    final sections = students.map((s) => '${s.grade}-${s.section}').toSet().length;
    final present = attendance[today]?.values.where((x) => x == 'حاضر').length ?? 0;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('مرحباً، $teacher', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      Text('$school • $subject', style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 18),
      Row(children: [Expanded(child: stat('الطلاب', '${students.length}', Icons.people)), Expanded(child: stat('الفصول', '$sections', Icons.class_outlined))]),
      Row(children: [Expanded(child: stat('حاضر اليوم', '$present', Icons.check_circle_outline)), Expanded(child: stat('الواجبات', '${homeworks.length}', Icons.assignment_outlined))]),
      const SizedBox(height: 22), heading('الوصول السريع'),
      Card(child: Column(children: [
        ListTile(leading: const Icon(Icons.person_add), title: const Text('إضافة طالب'), onTap: () => editStudent()),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.grade), title: const Text('إدخال الدرجات'), onTap: () => setState(() => tab = 2)),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.fact_check), title: const Text('تسجيل الحضور'), onTap: () => setState(() => tab = 3)),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.campaign), title: const Text('الإعلانات'), onTap: () => setState(() => tab = 5)),
      ])),
      const SizedBox(height: 16),
      heading('آخر الإعلانات'),
      if (announcements.isEmpty) const Text('لا توجد إعلانات بعد') else ...announcements.reversed.take(3).map((x) => Card(child: ListTile(leading: const Icon(Icons.campaign), title: Text(x)))),
    ]);
  }

  Widget studentPage() {
    final visible = students.where((s) => (filter == 'الكل' || s.grade == filter) && (s.name.contains(search) || s.id.toString().contains(search))).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => editStudent(), icon: const Icon(Icons.add), label: const Text('إضافة طالب'))),
        const SizedBox(height: 12),
        TextField(decoration: field('بحث بالاسم أو الرقم').copyWith(prefixIcon: const Icon(Icons.search)), onChanged: (v) => setState(() => search = v)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: filter, decoration: field('تصفية حسب الصف'), items: ['الكل', ...grades].map((x) => DropdownMenuItem(value: x, child: Text(x == 'الكل' ? 'جميع الصفوف' : 'الصف $x'))).toList(), onChanged: (v) => setState(() => filter = v ?? 'الكل')),
      ])),
      Expanded(child: visible.isEmpty ? const Center(child: Text('لا يوجد طلاب مطابقون')) : ListView.builder(itemCount: visible.length, itemBuilder: (_, i) {
        final s = visible[i];
        return Card(margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(s.name), subtitle: Text('الصف ${s.grade} • الفصل ${s.section} • ${s.id}'), trailing: const Icon(Icons.chevron_left), onTap: () => studentDetails(s)));
      })),
    ]);
  }

  Future<void> editWeights() async {
    final controllers = {for (final k in weights.keys) k: TextEditingController(text: weights[k].toString())};
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('توزيع الدرجة من 100'),
      content: Column(mainAxisSize: MainAxisSize.min, children: controllers.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: TextField(controller: e.value, keyboardType: TextInputType.number, decoration: field(e.key)))).toList()),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () {
        final values = controllers.map((k,v) => MapEntry(k, int.tryParse(v.text) ?? -1));
        if (values.values.any((x) => x < 0) || values.values.reduce((a,b) => a+b) != 100) { message('يجب أن يكون مجموع التوزيع 100'); return; }
        setState(() => weights.addAll(values)); Navigator.pop(ctx);
      }, child: const Text('حفظ'))],
    ));
    for (final c in controllers.values) { c.dispose(); }
  }

  Future<void> editScore(Student s) async {
    final old = scores[s.id] ?? {};
    final controllers = {for (final k in weights.keys) k: TextEditingController(text: (old[k] ?? 0).toString())};
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text('درجات ${s.name}'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: controllers.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: e.value, keyboardType: TextInputType.number, decoration: field('${e.key} / ${weights[e.key]}')))).toList())),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () {
        final values = controllers.map((k,v) => MapEntry(k, int.tryParse(v.text) ?? -1));
        if (values.entries.any((e) => e.value < 0 || e.value > weights[e.key]!)) { message('تأكد من أن كل درجة ضمن الحد المسموح'); return; }
        setState(() => scores[s.id] = values); Navigator.pop(ctx);
      }, child: const Text('حفظ'))],
    ));
    for (final c in controllers.values) { c.dispose(); }
  }

  Widget gradePage() => ListView(padding: const EdgeInsets.all(14), children: [
    heading('توزيع الدرجات', action: TextButton.icon(onPressed: editWeights, icon: const Icon(Icons.tune), label: const Text('تعديل'))),
    Card(child: Padding(padding: const EdgeInsets.all(14), child: Wrap(spacing: 14, runSpacing: 8, children: weights.entries.map((e) => Chip(label: Text('${e.key}: ${e.value}'))).toList()))),
    const SizedBox(height: 16), heading('درجات الطلاب'),
    if (students.isEmpty) const Text('أضف الطلاب أولاً'),
    ...students.map((s) {
      final total = scores[s.id]?.values.fold<int>(0, (a,b) => a+b);
      return Card(child: ListTile(leading: const Icon(Icons.grade_outlined), title: Text(s.name), subtitle: Text('الصف ${s.grade} • ${total == null ? "لم يتم التقييم" : "$total / 100"}'), trailing: const Icon(Icons.edit_outlined), onTap: () => editScore(s)));
    }),
    const Text('الدرجات تجريبية، ويمكن تعديل توزيعها لكل مادة لاحقاً.', style: TextStyle(color: Colors.grey)),
  ]);

  Widget attendancePage() {
    final day = attendance.putIfAbsent(today, () => {});
    return ListView(padding: const EdgeInsets.all(14), children: [
      heading('الحضور اليومي'),
      Card(child: ListTile(leading: const Icon(Icons.calendar_today), title: Text('التاريخ: $today'), subtitle: const Text('اختر حالة كل طالب'))),
      const SizedBox(height: 12),
      if (students.isEmpty) const Text('أضف الطلاب أولاً'),
      ...students.map((s) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, children: ['حاضر','غائب','متأخر'].map((status) => ChoiceChip(label: Text(status), selected: day[s.id] == status, onSelected: (_) => setState(() => day[s.id] = status))).toList()),
      ])))),
      const SizedBox(height: 10),
      Text('تم تسجيل ${day.length} من ${students.length} طلاب'),
    ]);
  }

  Future<void> addHomework() async {
    final title = TextEditingController();
    final desc = TextEditingController();
    final due = TextEditingController(text: today);
    String grade = grades.first;
    await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, change) => AlertDialog(
      title: const Text('واجب جديد'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: field('عنوان الواجب')),
        const SizedBox(height: 10), TextField(controller: desc, maxLines: 3, decoration: field('تفاصيل الواجب')),
        const SizedBox(height: 10), DropdownButtonFormField<String>(value: grade, decoration: field('الصف'), items: grades.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => change(() => grade = v ?? grade)),
        const SizedBox(height: 10), TextField(controller: due, readOnly: true, decoration: field('موعد التسليم').copyWith(suffixIcon: const Icon(Icons.calendar_today)), onTap: () async {
          final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
          if (d != null) change(() => due.text = d.toIso8601String().substring(0,10));
        }),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () {
        if (title.text.trim().isEmpty) { message('أدخل عنوان الواجب'); return; }
        setState(() => homeworks.add(Homework(title.text.trim(), desc.text.trim(), grade, due.text)));
        Navigator.pop(ctx);
      }, child: const Text('إضافة'))],
    )));
    title.dispose(); desc.dispose(); due.dispose();
  }

  Widget homeworkPage() => ListView(padding: const EdgeInsets.all(14), children: [
    heading('الواجبات', action: FilledButton.icon(onPressed: addHomework, icon: const Icon(Icons.add), label: const Text('جديد'))),
    if (homeworks.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('لا توجد واجبات بعد'))),
    ...homeworks.reversed.map((h) => Card(child: ListTile(leading: const Icon(Icons.assignment_outlined), title: Text(h.title), subtitle: Text('الصف ${h.grade} • التسليم ${h.due}\n${h.description}'), isThreeLine: h.description.isNotEmpty, trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => homeworks.remove(h)))))),
  ]);

  Future<void> addAnnouncement() async {
    final textController = TextEditingController();
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('إعلان جديد'), content: TextField(controller: textController, maxLines: 3, decoration: field('نص الإعلان')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () {
        if (textController.text.trim().isEmpty) return;
        setState(() => announcements.add(textController.text.trim())); Navigator.pop(ctx);
      }, child: const Text('نشر تجريبي'))],
    ));
    textController.dispose();
  }

  Future<void> editTeacher() async {
    final name = TextEditingController(text: teacher);
    final schoolName = TextEditingController(text: school);
    final subjectName = TextEditingController(text: subject);
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('بيانات المعلم'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: field('اسم المعلم')), const SizedBox(height: 10), TextField(controller: schoolName, decoration: field('المدرسة')), const SizedBox(height: 10), TextField(controller: subjectName, decoration: field('المادة'))]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () { setState(() { teacher = name.text.trim(); school = schoolName.text.trim(); subject = subjectName.text.trim(); }); Navigator.pop(ctx); }, child: const Text('حفظ'))],
    ));
    name.dispose(); schoolName.dispose(); subjectName.dispose();
  }

  Widget morePage() => ListView(padding: const EdgeInsets.all(14), children: [
    heading('المعلم والإعدادات'),
    Card(child: ListTile(leading: const Icon(Icons.account_circle_outlined), title: Text(teacher), subtitle: Text('$school • $subject'), trailing: const Icon(Icons.edit), onTap: editTeacher)),
    const SizedBox(height: 16), heading('الإعلانات'),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: addAnnouncement, icon: const Icon(Icons.campaign), label: const Text('إضافة إعلان'))),
    ...announcements.reversed.map((a) => Card(child: ListTile(title: Text(a), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => announcements.remove(a)))))),
    const SizedBox(height: 16),
    const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('نسخة تجريبية: البيانات محفوظة في الذاكرة فقط وتُفقد بعد إغلاق التطبيق. لا توجد مصادقة أو إرسال إشعارات حقيقية.'))),
  ]);

  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(
    appBar: AppBar(title: Text(tabs[tab]), backgroundColor: const Color(0xff2563eb), foregroundColor: Colors.white),
    body: IndexedStack(index: tab, children: [dashboard(), studentPage(), gradePage(), attendancePage(), homeworkPage(), morePage()]),
    bottomNavigationBar: NavigationBar(height: 72, selectedIndex: tab, labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, onDestinationSelected: (v) => setState(() => tab = v), destinations: List.generate(tabs.length, (i) => NavigationDestination(icon: Icon(icons[i]), label: tabs[i]))),
  ));
}
