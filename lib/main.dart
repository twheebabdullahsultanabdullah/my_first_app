import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const StockApp());

const blue = Color(0xFF2357C6);
const bg = Color(0xFFF4F7FB);

class Product {
  String id, name, category, barcode, expiry;
  double cost, price;
  int quantity, minimum;
  Product({required this.id, required this.name, required this.category,
    required this.barcode, required this.expiry, required this.cost,
    required this.price, required this.quantity, required this.minimum});
  Map<String, dynamic> toJson() => {'id':id,'name':name,'category':category,
    'barcode':barcode,'expiry':expiry,'cost':cost,'price':price,
    'quantity':quantity,'minimum':minimum};
  factory Product.fromJson(Map<String,dynamic> m) => Product(
    id:'${m['id']}', name:'${m['name']}', category:'${m['category']}',
    barcode:'${m['barcode']}', expiry:'${m['expiry']}',
    cost:(m['cost'] as num).toDouble(), price:(m['price'] as num).toDouble(),
    quantity:(m['quantity'] as num).toInt(), minimum:(m['minimum'] as num).toInt());
}

class Movement {
  String id, productId, productName, type, date, note;
  int quantity;
  double unitPrice, unitCost;
  Movement({required this.id, required this.productId, required this.productName,
    required this.type, required this.date, required this.note,
    required this.quantity, required this.unitPrice, required this.unitCost});
  Map<String,dynamic> toJson() => {'id':id,'productId':productId,
    'productName':productName,'type':type,'date':date,'note':note,
    'quantity':quantity,'unitPrice':unitPrice,'unitCost':unitCost};
  factory Movement.fromJson(Map<String,dynamic> m) => Movement(
    id:'${m['id']}',productId:'${m['productId']}',productName:'${m['productName']}',
    type:'${m['type']}',date:'${m['date']}',note:'${m['note']}',
    quantity:(m['quantity'] as num).toInt(),
    unitPrice:(m['unitPrice'] as num).toDouble(),
    unitCost:(m['unitCost'] as num).toDouble());
}

class StockApp extends StatelessWidget {
  const StockApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner:false, title:'المخزون الذكي',
    theme:ThemeData(useMaterial3:true,colorSchemeSeed:blue,
      scaffoldBackgroundColor:bg,
      inputDecorationTheme:InputDecorationTheme(
        border:OutlineInputBorder(borderRadius:BorderRadius.circular(12)))),
    home:const Directionality(textDirection:TextDirection.rtl,child:StockHome()));
}

class StockHome extends StatefulWidget {
  const StockHome({super.key});
  @override State<StockHome> createState()=>_StockHomeState();
}

class _StockHomeState extends State<StockHome> {
  final List<Product> products=[];
  final List<Movement> movements=[];
  int tab=0;
  bool loading=true;
  String search='';
  final titles=['الرئيسية','المنتجات','الحركات','التنبيهات','التقارير'];

  @override void initState(){super.initState();load();}
  Future<void> load() async {
    try {
      final prefs=await SharedPreferences.getInstance();
      final p=jsonDecode(prefs.getString('stock_products_v1')??'[]') as List;
      final m=jsonDecode(prefs.getString('stock_movements_v1')??'[]') as List;
      products.addAll(p.map((e)=>Product.fromJson(Map<String,dynamic>.from(e))));
      movements.addAll(m.map((e)=>Movement.fromJson(Map<String,dynamic>.from(e))));
    } catch (_) { message('تعذر قراءة بعض البيانات المحفوظة'); }
    if(mounted)setState(()=>loading=false);
  }
  Future<void> save() async {
    try {
      final prefs=await SharedPreferences.getInstance();
      final a=await prefs.setString('stock_products_v1',jsonEncode(products.map((e)=>e.toJson()).toList()));
      final b=await prefs.setString('stock_movements_v1',jsonEncode(movements.map((e)=>e.toJson()).toList()));
      if(!a||!b)message('تعذر حفظ البيانات');
    } catch (_) {message('حدث خطأ أثناء حفظ البيانات');}
  }
  void message(String s){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}
  String money(num n)=>n.toStringAsFixed(2);
  String date(DateTime d)=>'${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  String uniqueId()=>DateTime.now().microsecondsSinceEpoch.toString();
  double get stockValue=>products.fold(0.0,(v,p)=>v+p.cost*p.quantity);
  int get lowCount=>products.where((p)=>p.quantity<=p.minimum).length;
  DateTime? expiryOf(Product p)=>DateTime.tryParse(p.expiry);
  bool expired(Product p){final d=expiryOf(p);return d!=null&&d.isBefore(DateTime.now().copyWith(hour:0,minute:0,second:0,millisecond:0,microsecond:0));}
  bool expiring(Product p){final d=expiryOf(p);if(d==null)return false;final days=d.difference(DateTime.now()).inDays;return days>=0&&days<=30;}
  double get sales=>movements.where((m)=>m.type=='بيع').fold(0.0,(v,m)=>v+m.quantity*m.unitPrice);
  double get cogs=>movements.where((m)=>m.type=='بيع').fold(0.0,(v,m)=>v+m.quantity*m.unitCost);
  double get purchases=>movements.where((m)=>m.type=='شراء').fold(0.0,(v,m)=>v+m.quantity*m.unitPrice);

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(backgroundColor:blue,foregroundColor:Colors.white,
      title:Text(titles[tab]),actions:[IconButton(icon:const Icon(Icons.inventory_2_outlined),onPressed:()=>setState(()=>tab=1))]),
    body:loading?const Center(child:CircularProgressIndicator()):IndexedStack(index:tab,children:[dashboard(),productPage(),movementPage(),alertsPage(),reportPage()]),
    bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),
      labelBehavior:NavigationDestinationLabelBehavior.alwaysShow,
      destinations:const [
        NavigationDestination(icon:Icon(Icons.home_outlined),label:'الرئيسية'),
        NavigationDestination(icon:Icon(Icons.inventory_2_outlined),label:'المنتجات'),
        NavigationDestination(icon:Icon(Icons.swap_horiz),label:'الحركات'),
        NavigationDestination(icon:Icon(Icons.notifications_outlined),label:'التنبيهات'),
        NavigationDestination(icon:Icon(Icons.bar_chart_outlined),label:'التقارير')]),
  );

  Widget tileStat(String title,String value,IconData icon){return Card(child:Padding(padding:const EdgeInsets.all(15),child:Column(children:[Icon(icon,color:blue,size:30),const SizedBox(height:9),FittedBox(child:Text(value,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:22))),Text(title,textAlign:TextAlign.center)])));}
  Widget dashboard()=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('مرحبًا بك في المخزون الذكي',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),
    const SizedBox(height:6),const Text('ملخص نشاط المحل التجاري'),const SizedBox(height:20),
    Row(children:[Expanded(child:tileStat('المنتجات','${products.length}',Icons.inventory)),Expanded(child:tileStat('قيمة المخزون',money(stockValue),Icons.payments))]),
    Row(children:[Expanded(child:tileStat('نقص المخزون','$lowCount',Icons.warning_amber)),Expanded(child:tileStat('المبيعات',money(sales),Icons.point_of_sale))]),
    const SizedBox(height:20),FilledButton.icon(onPressed:()=>productForm(),icon:const Icon(Icons.add),label:const Text('إضافة منتج جديد')),
    const SizedBox(height:8),OutlinedButton.icon(onPressed:()=>setState(()=>tab=2),icon:const Icon(Icons.swap_horiz),label:const Text('تسجيل شراء أو بيع')),
    const SizedBox(height:18),const Text('آخر الحركات',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),
    ...movements.reversed.take(5).map(movementTile),
    if(movements.isEmpty)const Padding(padding:EdgeInsets.all(20),child:Text('لا توجد حركات بعد')),
  ]);

  Widget productPage(){final filtered=products.where((p)=>p.name.toLowerCase().contains(search.toLowerCase())||p.barcode.contains(search)||p.category.contains(search)).toList();
    return Column(children:[Padding(padding:const EdgeInsets.all(12),child:Column(children:[
      SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:()=>productForm(),icon:const Icon(Icons.add),label:const Text('إضافة منتج'))),
      const SizedBox(height:10),TextField(onChanged:(s)=>setState(()=>search=s),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'بحث بالاسم أو الباركود أو التصنيف')),
    ])),Expanded(child:filtered.isEmpty?const Center(child:Text('لا توجد منتجات مطابقة')):ListView.builder(itemCount:filtered.length,itemBuilder:(c,i){final p=filtered[i];return Card(margin:const EdgeInsets.symmetric(horizontal:12,vertical:5),child:ListTile(
      leading:CircleAvatar(child:Text('${p.quantity}')),
      title:Text(p.name,style:const TextStyle(fontWeight:FontWeight.bold)),
      subtitle:Text('${p.category} | شراء: ${money(p.cost)} | بيع: ${money(p.price)}\nالحد الأدنى: ${p.minimum}${p.expiry.isEmpty?'':' | الصلاحية: ${p.expiry}'}'),
      isThreeLine:true,trailing:PopupMenuButton<String>(onSelected:(v){if(v=='edit')productForm(product:p);if(v=='delete')deleteProduct(p);if(v=='move')movementForm(selected:p);},itemBuilder:(c)=>const [
        PopupMenuItem(value:'edit',child:Text('تعديل')),
        PopupMenuItem(value:'move',child:Text('شراء / بيع / تسوية')),
        PopupMenuItem(value:'delete',child:Text('حذف'))]),
    ));}))) ]);
  }

  Future<void> productForm({Product? product}) async {
    final name=TextEditingController(text:product?.name??'');
    final category=TextEditingController(text:product?.category??'عام');
    final barcode=TextEditingController(text:product?.barcode??'');
    final cost=TextEditingController(text:product==null?'':product.cost.toString());
    final price=TextEditingController(text:product==null?'':product.price.toString());
    final quantity=TextEditingController(text:product==null?'0':product.quantity.toString());
    final minimum=TextEditingController(text:product==null?'5':product.minimum.toString());
    final expiry=TextEditingController(text:product?.expiry??'');
    final key=GlobalKey<FormState>();
    await showDialog<void>(context:context,builder:(dc)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(
      title:Text(product==null?'إضافة منتج':'تعديل المنتج'),
      content:SizedBox(width:double.maxFinite,child:SingleChildScrollView(child:Form(key:key,child:Column(mainAxisSize:MainAxisSize.min,children:[
        field(name,'اسم المنتج',required:true),field(category,'التصنيف'),field(barcode,'الباركود (اختياري)'),
        field(cost,'سعر الشراء',numeric:true,required:true),field(price,'سعر البيع',numeric:true,required:true),
        if(product==null)field(quantity,'الكمية الابتدائية',numeric:true,required:true),
        field(minimum,'الحد الأدنى',numeric:true,required:true),
        TextFormField(controller:expiry,readOnly:true,decoration:InputDecoration(labelText:'تاريخ الانتهاء (اختياري)',suffixIcon:IconButton(icon:const Icon(Icons.calendar_month),onPressed:()async{
          final d=await showDatePicker(context:dc,initialDate:DateTime.tryParse(expiry.text)??DateTime.now(),firstDate:DateTime(2020),lastDate:DateTime(2100));if(d!=null)expiry.text=date(d);
        })),),
        TextButton(onPressed:()=>expiry.clear(),child:const Text('مسح تاريخ الصلاحية')),
      ])))),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('إلغاء')),
        FilledButton(onPressed:()async{
          if(!key.currentState!.validate())return;
          final c=double.tryParse(cost.text.trim()),pr=double.tryParse(price.text.trim());
          final q=int.tryParse(quantity.text.trim()),min=int.tryParse(minimum.text.trim());
          if(c==null||pr==null||min==null||c<0||pr<0||min<0||(product==null&&(q==null||q<0))){message('تحقق من القيم الرقمية');return;}
          setState((){
            if(product==null){products.add(Product(id:uniqueId(),name:name.text.trim(),category:category.text.trim(),barcode:barcode.text.trim(),expiry:expiry.text.trim(),cost:c,price:pr,quantity:q!,minimum:min));}
            else {product.name=name.text.trim();product.category=category.text.trim();product.barcode=barcode.text.trim();product.expiry=expiry.text.trim();product.cost=c;product.price=pr;product.minimum=min;}
          });
          await save();if(dc.mounted)Navigator.pop(dc);
        },child:const Text('حفظ'))],
    )));
    name.dispose();category.dispose();barcode.dispose();cost.dispose();price.dispose();quantity.dispose();minimum.dispose();expiry.dispose();
  }

  Widget field(TextEditingController c,String label,{bool numeric=false,bool required=false})=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextFormField(
    controller:c,keyboardType:numeric?const TextInputType.numberWithOptions(decimal:true):TextInputType.text,
    decoration:InputDecoration(labelText:label),validator:(s){if(required&&(s==null||s.trim().isEmpty))return 'هذا الحقل مطلوب';return null;}));

  Future<void> deleteProduct(Product p)async{
    final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('حذف المنتج'),content:Text('هل تريد حذف ${p.name}؟ سيبقى سجل الحركات محفوظًا.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('حذف'))]));
    if(yes==true){setState(()=>products.remove(p));await save();}
  }

  Widget movementPage()=>Column(children:[Padding(padding:const EdgeInsets.all(12),child:SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:()=>movementForm(),icon:const Icon(Icons.add),label:const Text('تسجيل حركة مخزون')))),
    Expanded(child:movements.isEmpty?const Center(child:Text('لا توجد حركات مسجلة')):ListView(children:movements.reversed.map(movementTile).toList()))]);
  Widget movementTile(Movement m)=>Card(margin:const EdgeInsets.symmetric(horizontal:12,vertical:5),child:ListTile(
    leading:Icon(m.type=='بيع'?Icons.trending_down:m.type=='شراء'?Icons.trending_up:Icons.tune,color:m.type=='بيع'?Colors.red:Colors.green),
    title:Text('${m.type} - ${m.productName}'),
    subtitle:Text('${m.date}\n${m.note.isEmpty?'بدون ملاحظات':m.note}'),isThreeLine:true,
    trailing:Text('${m.quantity}\n${money(m.quantity*m.unitPrice)}',textAlign:TextAlign.center)));

  Future<void> movementForm({Product? selected}) async {
    if(products.isEmpty){message('أضف منتجًا أولًا');return;}
    Product chosen=selected??products.first;
    String type='شراء';
    final quantity=TextEditingController(text:'1');
    final note=TextEditingController();
    final unit=TextEditingController(text:chosen.cost.toString());
    final key=GlobalKey<FormState>();
    await showDialog<void>(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,update)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(
      title:const Text('حركة مخزون جديدة'),content:SizedBox(width:double.maxFinite,child:SingleChildScrollView(child:Form(key:key,child:Column(mainAxisSize:MainAxisSize.min,children:[
        DropdownButtonFormField<String>(value:chosen.id,isExpanded:true,decoration:const InputDecoration(labelText:'المنتج'),items:products.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.name,overflow:TextOverflow.ellipsis))).toList(),onChanged:(v){if(v==null)return;update((){chosen=products.firstWhere((p)=>p.id==v);unit.text=(type=='بيع'?chosen.price:chosen.cost).toString();});}),
        const SizedBox(height:12),DropdownButtonFormField<String>(value:type,decoration:const InputDecoration(labelText:'نوع الحركة'),items:['شراء','بيع','تسوية زيادة','تسوية نقص'].map((t)=>DropdownMenuItem(value:t,child:Text(t))).toList(),onChanged:(v){if(v==null)return;update((){type=v;unit.text=(type=='بيع'?chosen.price:chosen.cost).toString();});}),
        const SizedBox(height:12),Text('الكمية الحالية: ${chosen.quantity}'),const SizedBox(height:12),field(quantity,'الكمية',numeric:true,required:true),
        field(unit,'سعر الوحدة',numeric:true,required:true),field(note,'ملاحظات'),
      ])))),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('إلغاء')),FilledButton(onPressed:()async{
        if(!key.currentState!.validate())return;
        final q=int.tryParse(quantity.text.trim()),u=double.tryParse(unit.text.trim());
        if(q==null||q<=0||u==null||u<0){message('أدخل كمية صحيحة وسعرًا غير سالب');return;}
        final isOut=type=='بيع'||type=='تسوية نقص';
        if(isOut&&q>chosen.quantity){message('الكمية غير كافية في المخزون');return;}
        setState((){
          chosen.quantity+=isOut?-q:q;
          movements.add(Movement(id:uniqueId(),productId:chosen.id,productName:chosen.name,type:type,date:DateTime.now().toIso8601String().substring(0,16).replaceFirst('T',' '),note:note.text.trim(),quantity:q,unitPrice:u,unitCost:chosen.cost));
        });
        await save();if(dc.mounted)Navigator.pop(dc);
      },child:const Text('تسجيل'))],
    ))));
    quantity.dispose();note.dispose();unit.dispose();
  }

  Widget alertsPage(){final low=products.where((p)=>p.quantity<=p.minimum).toList();final expiry=products.where((p)=>expired(p)||expiring(p)).toList();
    return ListView(padding:const EdgeInsets.all(14),children:[
      const Text('تنبيهات نقص المخزون',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      if(low.isEmpty)const ListTile(title:Text('لا توجد منتجات منخفضة المخزون')),
      ...low.map((p)=>Card(child:ListTile(leading:const Icon(Icons.warning_amber,color:Colors.orange),title:Text(p.name),subtitle:Text('المتاح: ${p.quantity} | الحد الأدنى: ${p.minimum}')))),
      const SizedBox(height:20),const Text('تنبيهات الصلاحية (30 يومًا)',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      if(expiry.isEmpty)const ListTile(title:Text('لا توجد منتجات منتهية أو قريبة الانتهاء')),
      ...expiry.map((p)=>Card(child:ListTile(leading:Icon(Icons.event_busy,color:expired(p)?Colors.red:Colors.orange),title:Text(p.name),subtitle:Text('${expired(p)?'منتهي الصلاحية':'قريب الانتهاء'} | ${p.expiry}')))),
    ]);
  }
  Widget reportPage()=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('التقارير المالية والمخزنية',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:16),
    reportRow('قيمة المخزون بسعر التكلفة',stockValue),reportRow('إجمالي المبيعات المسجلة',sales),
    reportRow('تكلفة البضاعة المباعة',cogs),reportRow('الربح الإجمالي التقديري',sales-cogs),
    reportRow('إجمالي المشتريات المسجلة',purchases),
    Card(child:Padding(padding:const EdgeInsets.all(14),child:Text('ملاحظة: الربح هنا = المبيعات - تكلفة البضاعة المباعة فقط. لا يشمل الإيجارات والرواتب والمصروفات والضرائب والمرتجعات. تسويات المخزون لا تدخل في المبيعات أو المشتريات.'))),
    const SizedBox(height:12),Text('عدد حركات المخزون: ${movements.length}'),Text('عدد الأصناف: ${products.length}'),
  ]);
  Widget reportRow(String title,double value)=>Card(child:ListTile(title:Text(title),trailing:Text(money(value),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17))));
}
