
import 'package:flutter/material.dart';

void main() {
  runApp(const StockApp());
}

const primary = Color(0xFF2563EB);

class Product {
  final int id;
  String name;
  String category;
  String barcode;
  int quantity;
  int minimum;
  double cost;
  double price;
  DateTime? expiry;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.barcode,
    required this.quantity,
    required this.minimum,
    required this.cost,
    required this.price,
    this.expiry,
  });
}

class StockMove {
  final String productName;
  final String type;
  final int quantity;
  final double amount;
  final double costAmount;
  final DateTime date;

  StockMove({
    required this.productName,
    required this.type,
    required this.quantity,
    required this.amount,
    required this.costAmount,
    required this.date,
  });
}

class StockApp extends StatelessWidget {
  const StockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'المخزون الذكي',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primary,
        scaffoldBackgroundColor:
            const Color(0xFFF4F7FC),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: StockHome(),
      ),
    );
  }
}

class StockHome extends StatefulWidget {
  const StockHome({super.key});

  @override
  State<StockHome> createState() => _StockHomeState();
}

class _StockHomeState extends State<StockHome> {
  final List<Product> products = [];
  final List<StockMove> movements = [];

  int tab = 0;
  int nextId = 1;
  String search = '';

  final titles = [
    'الرئيسية',
    'المنتجات',
    'الحركات',
    'التنبيهات',
    'التقارير',
  ];

  String money(num value) {
    return value.toStringAsFixed(2);
  }

  String dateText(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  double get stockValue {
    double total = 0;
    for (final p in products) {
      total += p.cost * p.quantity;
    }
    return total;
  }

  int get lowCount {
    return products
        .where((p) => p.quantity <= p.minimum)
        .length;
  }

  double get sales {
    double total = 0;
    for (final m in movements) {
      if (m.type == 'بيع') {
        total += m.amount;
      }
    }
    return total;
  }

  double get purchases {
    double total = 0;
    for (final m in movements) {
      if (m.type == 'شراء') {
        total += m.amount;
      }
    }
    return total;
  }

  double get soldCost {
    double total = 0;
    for (final m in movements) {
      if (m.type == 'بيع') {
        total += m.costAmount;
      }
    }
    return total;
  }

  void notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[tab]),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: tab,
        children: [
          dashboard(),
          productsPage(),
          movementsPage(),
          alertsPage(),
          reportsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) {
          setState(() => tab = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'المنتجات',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'الحركات',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            label: 'التنبيهات',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'التقارير',
          ),
        ],
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icon, color: primary, size: 30),
            const SizedBox(height: 10),
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'مرحباً بك في المخزون الذكي',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text('إدارة ومتابعة مخزون المحل التجاري'),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: statCard(
                'المنتجات',
                '${products.length}',
                Icons.inventory,
              ),
            ),
            Expanded(
              child: statCard(
                'قيمة المخزون',
                money(stockValue),
                Icons.account_balance_wallet,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: statCard(
                'نقص المخزون',
                '$lowCount',
                Icons.warning_amber,
              ),
            ),
            Expanded(
              child: statCard(
                'المبيعات',
                money(sales),
                Icons.point_of_sale,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: () => productForm(),
          icon: const Icon(Icons.add),
          label: const Text('إضافة منتج جديد'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => setState(() => tab = 2),
          icon: const Icon(Icons.swap_horiz),
          label: const Text('تسجيل شراء أو بيع'),
        ),
        const SizedBox(height: 24),
        const Text(
          'آخر الحركات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (movements.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('لا توجد حركات حتى الآن'),
            ),
          ),
        for (final m in movements.reversed.take(5))
          movementTile(m),
      ],
    );
  }

  Widget productsPage() {
    final filtered = products.where((p) {
      final q = search.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.barcode.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => productForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة منتج'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) {
                  setState(() => search = value);
                },
                decoration: const InputDecoration(
                  hintText: 'بحث بالاسم أو الباركود',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('لا توجد منتجات مطابقة'),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final p = filtered[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${p.quantity}'),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${p.category}\n'
                          'شراء: ${money(p.cost)} | '
                          'بيع: ${money(p.price)}\n'
                          'الحد الأدنى: ${p.minimum}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              productForm(product: p);
                            } else if (value == 'move') {
                              movementForm(selected: p);
                            } else if (value == 'delete') {
                              deleteProduct(p);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('تعديل'),
                            ),
                            PopupMenuItem(
                              value: 'move',
                              child: Text('شراء أو بيع'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('حذف'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget formField(
    TextEditingController controller,
    String label, {
    bool numeric = false,
    bool requiredField = false,
    bool integer = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(
                decimal: true,
              )
            : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (requiredField && text.isEmpty) {
            return 'هذا الحقل مطلوب';
          }

          if (numeric && text.isNotEmpty) {
            final number = double.tryParse(text);
            if (number == null ||
                !number.isFinite ||
                number < 0) {
              return 'أدخل رقماً صحيحاً غير سالب';
            }

            if (integer && int.tryParse(text) == null) {
              return 'أدخل عدداً صحيحاً';
            }
          }

          return null;
        },
      ),
    );
  }

  Future<void> productForm({Product? product}) async {
    final name = TextEditingController(
      text: product?.name ?? '',
    );
    final category = TextEditingController(
      text: product?.category ?? 'عام',
    );
    final barcode = TextEditingController(
      text: product?.barcode ?? '',
    );
    final cost = TextEditingController(
      text: product?.cost.toString() ?? '',
    );
    final price = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final quantity = TextEditingController(
      text: product?.quantity.toString() ?? '0',
    );
    final minimum = TextEditingController(
      text: product?.minimum.toString() ?? '5',
    );

    DateTime? expiry = product?.expiry;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, updateDialog) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(
                  product == null
                      ? 'إضافة منتج جديد'
                      : 'تعديل المنتج',
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          formField(
                            name,
                            'اسم المنتج',
                            requiredField: true,
                          ),
                          formField(category, 'التصنيف'),
                          formField(barcode, 'الباركود'),
                          formField(
                            cost,
                            'سعر الشراء',
                            numeric: true,
                            requiredField: true,
                          ),
                          formField(
                            price,
                            'سعر البيع',
                            numeric: true,
                            requiredField: true,
                          ),
                          if (product == null)
                            formField(
                              quantity,
                              'الكمية الابتدائية',
                              numeric: true,
                              integer: true,
                              requiredField: true,
                            ),
                          formField(
                            minimum,
                            'الحد الأدنى للمخزون',
                            numeric: true,
                            integer: true,
                            requiredField: true,
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(
                              Icons.calendar_month,
                            ),
                            label: Text(
                              expiry == null
                                  ? 'تاريخ الصلاحية (اختياري)'
                                  : dateText(expiry!),
                            ),
                            onPressed: () async {
                              final chosen =
                                  await showDatePicker(
                                context: dialogContext,
                                initialDate:
                                    expiry ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );

                              if (chosen != null) {
                                updateDialog(() {
                                  expiry = chosen;
                                });
                              }
                            },
                          ),
                          if (expiry != null)
                            TextButton(
                              onPressed: () {
                                updateDialog(() {
                                  expiry = null;
                                });
                              },
                              child: const Text(
                                'مسح تاريخ الصلاحية',
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

                      final newName = name.text.trim();
                      final newBarcode = barcode.text.trim();

                      final duplicate = products.any(
                        (p) =>
                            p.barcode == newBarcode &&
                            newBarcode.isNotEmpty &&
                            p.id != product?.id,
                      );

                      if (duplicate) {
                        notify('الباركود مستخدم مسبقاً');
                        return;
                      }

                      setState(() {
                        if (product == null) {
                          products.add(
                            Product(
                              id: nextId++,
                              name: newName,
                              category:
                                  category.text.trim(),
                              barcode: newBarcode,
                              cost: double.parse(cost.text),
                              price: double.parse(price.text),
                              quantity:
                                  int.parse(quantity.text),
                              minimum:
                                  int.parse(minimum.text),
                              expiry: expiry,
                            ),
                          );
                        } else {
                          product.name = newName;
                          product.category =
                              category.text.trim();
                          product.barcode = newBarcode;
                          product.cost =
                              double.parse(cost.text);
                          product.price =
                              double.parse(price.text);
                          product.minimum =
                              int.parse(minimum.text);
                          product.expiry = expiry;
                        }
                      });

                      Navigator.pop(dialogContext);
                      notify('تم حفظ المنتج بنجاح');
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

  Future<void> deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text(
            'هل تريد حذف ${product.name}؟',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        products.remove(product);
      });
      notify('تم حذف المنتج');
    }
  }

  Future<void> movementForm({Product? selected}) async {
    if (products.isEmpty) {
      notify('أضف منتجاً أولاً');
      return;
    }

    Product current = selected ?? products.first;
    String type = 'شراء';

    final quantity = TextEditingController(text: '1');
    final unitPrice = TextEditingController(
      text: current.cost.toString(),
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, updateDialog) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('حركة مخزون جديدة'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<int>(
                            key: ValueKey(current.id),
                            initialValue: current.id,
                            decoration: const InputDecoration(
                              labelText: 'المنتج',
                            ),
                            items: products.map((p) {
                              return DropdownMenuItem<int>(
                                value: p.id,
                                child: Text(p.name),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id == null) return;

                              updateDialog(() {
                                current = products.firstWhere(
                                  (p) => p.id == id,
                                );
                                unitPrice.text = type == 'شراء'
                                    ? current.cost.toString()
                                    : current.price.toString();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            key: ValueKey(type),
                            initialValue: type,
                            decoration: const InputDecoration(
                              labelText: 'نوع الحركة',
                            ),
                            items: ['شراء', 'بيع']
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;

                              updateDialog(() {
                                type = value;
                                unitPrice.text =
                                    type == 'شراء'
                                        ? current.cost.toString()
                                        : current.price.toString();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          formField(
                            quantity,
                            'الكمية',
                            numeric: true,
                            integer: true,
                            requiredField: true,
                          ),
                          formField(
                            unitPrice,
                            'سعر الوحدة',
                            numeric: true,
                            requiredField: true,
                          ),
                          Text(
                            'المتوفر حالياً: ${current.quantity}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext),
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      final qty = int.parse(quantity.text);
                      final price =
                          double.parse(unitPrice.text);

                      if (qty <= 0) {
                        notify('الكمية يجب أن تكون أكبر من صفر');
                        return;
                      }

                      if (type == 'بيع' &&
                          qty > current.quantity) {
                        notify('الكمية غير متوفرة في المخزون');
                        return;
                      }

                      setState(() {
                        final previousCost = current.cost;

                        if (type == 'شراء') {
                          final oldValue =
                              current.quantity * current.cost;
                          final newValue = qty * price;
                          final totalQty =
                              current.quantity + qty;

                          current.cost =
                              (oldValue + newValue) /
                                  totalQty;
                          current.quantity += qty;
                        } else {
                          current.quantity -= qty;
                        }

                        movements.add(
                          StockMove(
                            productName: current.name,
                            type: type,
                            quantity: qty,
                            amount: qty * price,
                            costAmount:
                                type == 'بيع'
                                    ? qty * previousCost
                                    : qty * price,
                            date: DateTime.now(),
                          ),
                        );
                      });

                      Navigator.pop(dialogContext);
                      notify('تم تسجيل الحركة بنجاح');
                    },
                    child: const Text('تسجيل'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget movementTile(StockMove movement) {
    final incoming = movement.type == 'شراء';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: incoming
              ? Colors.green.shade100
              : Colors.orange.shade100,
          child: Icon(
            incoming
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: incoming ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(movement.productName),
        subtitle: Text(
          '${movement.type} - '
          '${dateText(movement.date)}\n'
          'الكمية: ${movement.quantity}',
        ),
        isThreeLine: true,
        trailing: Text(
          money(movement.amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget movementsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => movementForm(),
              icon: const Icon(Icons.add),
              label: const Text('تسجيل شراء أو بيع'),
            ),
          ),
        ),
        Expanded(
          child: movements.isEmpty
              ? const Center(
                  child: Text('لا توجد حركات مسجلة'),
                )
              : ListView.builder(
                  itemCount: movements.length,
                  itemBuilder: (context, index) {
                    final movement = movements[
                        movements.length - 1 - index];
                    return movementTile(movement);
                  },
                ),
        ),
      ],
    );
  }

  Widget alertsPage() {
    final alerts = products.where((p) {
      final low = p.quantity <= p.minimum;
      final exp = p.expiry;

      if (exp == null) return low;

      final days = exp.difference(today()).inDays;
      return low || days <= 30;
    }).toList();

    return alerts.isEmpty
        ? const Center(
            child: Text('لا توجد تنبيهات حالياً'),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final p = alerts[index];
              final warnings = <String>[];

              if (p.quantity <= p.minimum) {
                warnings.add(
                  'المخزون منخفض: ${p.quantity}',
                );
              }

              if (p.expiry != null) {
                final days =
                    p.expiry!.difference(today()).inDays;

                if (days < 0) {
                  warnings.add('المنتج منتهي الصلاحية');
                } else if (days <= 30) {
                  warnings.add(
                    'الصلاحية تنتهي خلال $days يوم',
                  );
                }
              }

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                  ),
                  title: Text(p.name),
                  subtitle: Text(warnings.join('\n')),
                  isThreeLine: warnings.length > 1,
                ),
              );
            },
          );
  }

  Widget reportRow(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ),
    );
  }

  Widget reportsPage() {
    final profit = sales - soldCost;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'تقارير المخزون',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        reportRow(
          'عدد المنتجات',
          '${products.length}',
        ),
        reportRow(
          'إجمالي الوحدات',
          '${products.fold<int>(0, (v, p) => v + p.quantity)}',
        ),
        reportRow(
          'قيمة المخزون بالتكلفة',
          money(stockValue),
        ),
        reportRow(
          'إجمالي المشتريات المسجلة',
          money(purchases),
        ),
        reportRow(
          'إجمالي المبيعات',
          money(sales),
        ),
        reportRow(
          'تكلفة البضاعة المباعة',
          money(soldCost),
        ),
        reportRow(
          'الربح الإجمالي التقديري',
          money(profit),
        ),
        reportRow(
          'منتجات منخفضة المخزون',
          '$lowCount',
        ),
        reportRow(
          'عدد الحركات',
          '${movements.length}',
        ),
        const SizedBox(height: 20),
        const Text(
          'ملاحظة: الربح تقديري ولا يشمل المصروفات '
          'والضرائب والمرتجعات. تعتمد تكلفة البيع '
          'على متوسط تكلفة المخزون وقت تسجيل الحركة.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
