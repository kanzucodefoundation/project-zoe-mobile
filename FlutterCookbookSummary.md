# Flutter Cookbook (2nd Edition) - Comprehensive Summary for LLM Reference

**Source:** Flutter Cookbook, Second Edition by Simone Alessandria (Packt, May 2023)
**Coverage:** Flutter 3.10.x and Dart 3.x - 100+ step-by-step recipes for cross-platform app development

---

## Part 1: Dart Language Fundamentals (Chapter 3)

### Variables: var vs final vs const
```dart
// var - mutable, type-inferred
var name = 'Flutter';
name = 'Dart';  // OK

// final - runtime constant, set once
final timestamp = DateTime.now();

// const - compile-time constant
const pi = 3.14159;
const list = [1, 2, 3];  // Immutable list
```

### String Interpolation
```dart
String name = 'Alice';
int age = 30;
print('$name is $age years old');
print('Next year: ${age + 1}');

// StringBuffer for efficient concatenation
StringBuffer buffer = StringBuffer();
for (String item in items) {
  buffer.write(item);
  buffer.write(' ');
}
String result = buffer.toString();
```

### Functions: Named & Optional Parameters
```dart
// Positional parameters
int add(int a, int b) => a + b;

// Optional positional parameters (with defaults)
void greet([String? name, int? age]) {
  final actualName = name ?? 'Unknown';
  final actualAge = age ?? 0;
  print('$actualName is $actualAge years old');
}

// Named parameters (Flutter style)
Widget buildContainer({
  required String text,
  Color color = Colors.blue,
  double? width,
}) {
  return Container(color: color, width: width, child: Text(text));
}

// Arrow syntax for single-line functions
int square(int n) => n * n;
```

### Closures (First-Class Functions)
```dart
// Function as variable
typedef NumberGetter = int Function();

int powerOfTwo(NumberGetter getter) {
  return getter() * getter();
}

// Callback pattern
void fetchData(void Function(String result) onComplete) {
  // async work...
  onComplete('data loaded');
}
```

### Switch Expressions (Dart 3)
```dart
// Traditional switch statement
String getDay(int day) {
  switch (day) {
    case 1: return 'Monday';
    case 2: return 'Tuesday';
    // ...
    default: return 'Invalid';
  }
}

// Switch expression (Dart 3 - more concise)
var dayName = switch (day) {
  1 => 'Monday',
  2 => 'Tuesday',
  3 => 'Wednesday',
  _ => 'Invalid'  // default case
};
```

### Records and Patterns (Dart 3)
```dart
// Record expression
var person = (name: 'Clark', age: 42);
print(person.name);  // Clark

// Record type annotation
({String name, int age}) person = (name: 'Clark', age: 42);

// Pattern destructuring
var (String name, int age) = getPerson({'name': 'Clark', 'age': 42});
print('$name is $age years old');

// Function returning record
(String, int) getPerson(Map<String, dynamic> json) {
  return (json['name'] as String, json['age'] as int);
}
```

### Classes and Constructor Shorthand
```dart
class Name {
  final String first;
  final String last;
  
  // Constructor shorthand - auto-assigns parameters
  Name(this.first, this.last);
  
  @override
  String toString() => '$first $last';
}

// Inheritance
class OfficialName extends Name {
  final String _title;
  
  OfficialName(this._title, String first, String last) : super(first, last);
  
  @override
  String toString() => '$_title. ${super.toString()}';
}
```

### Class Relationships Keywords
| Keyword | Purpose | Use Case |
|---------|---------|----------|
| `extends` | Inheritance | Extend superclass functionality (single inheritance) |
| `implements` | Interface conformance | Implement all methods from interface |
| `with` | Mixin application | Reuse code across class hierarchies |

### Collections
```dart
// List (ordered, allows duplicates)
List<int> numbers = [1, 2, 3, 5, 7];
numbers.add(11);
numbers[1] = 15;

// Map (key-value pairs)
Map<String, int> ages = {
  'Clark': 26,
  'Peter': 35,
};
ages['Steve'] = 48;
ages.remove('Peter');

// Set (unique values, unordered)
Set<String> names = {'Justin', 'Stephen', 'Paul'};
bool exists = names.contains('Justin');

// Collection-if and collection-for
final items = [
  'fixed item',
  if (condition) 'conditional item',
  for (var i in list) 'item $i',
];

// Spread operator
final combined = [...list1, ...list2];
```

### Higher-Order Functions
```dart
// map - transform elements
List<Name> names = data.map<Name>((raw) => Name.fromMap(raw)).toList();

// sort - in-place ordering
names.sort((a, b) => a.last.compareTo(b.last));

// where - filter elements
var filtered = names.where((n) => n.last.startsWith('M'));

// fold - reduce to single value
int total = numbers.fold(0, (sum, n) => sum + n);

// expand - flatten nested lists
var flat = nested.expand((list) => list).toList();
```

### Cascade Operator
```dart
// Without cascade
var button = Button();
button.text = 'Click';
button.color = Colors.blue;
button.onPressed = () {};

// With cascade (..)
var button = Button()
  ..text = 'Click'
  ..color = Colors.blue
  ..onPressed = () {};
```

### Null Safety
```dart
// Nullable type (can be null)
String? name;

// Non-nullable (cannot be null)
String name = 'Flutter';

// Null-aware operators
String displayName = name ?? 'Unknown';  // null coalescing
int? length = name?.length;              // null-aware access
name!.toUpperCase();                     // null assertion (use with caution)

// Late initialization
late String description;  // Will be initialized before use

// Null safety in classes
class User {
  String name;           // Must be set in constructor
  String? nickname;      // Optional
  late String computed;  // Initialized lazily
  
  User({required this.name, this.nickname});
}
```

---

## Part 2: Widget Fundamentals (Chapter 4)

### Widget Types
- **StatelessWidget**: Immutable, no internal state changes
- **StatefulWidget**: Mutable, can rebuild when state changes

```dart
// Stateless widget
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Stateful widget
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});
  
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int counter = 0;
  
  @override
  Widget build(BuildContext context) {
    return Text('Count: $counter');
  }
}
```

### Scaffold Structure
```dart
Scaffold(
  appBar: AppBar(
    title: Text('My App'),
    actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {})],
  ),
  body: Center(child: Text('Content')),
  drawer: Drawer(child: ListView(...)),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
  bottomNavigationBar: BottomNavigationBar(...),
)
```

### Container Widget
```dart
Container(
  width: 200,
  height: 100,
  margin: EdgeInsets.all(10),
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  transform: Matrix4.rotationZ(0.1),
  child: Text('Hello'),
)
```

### Text and RichText
```dart
// Simple text
Text(
  'Hello World',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)

// Rich text with multiple styles
RichText(
  text: TextSpan(
    text: 'Flutter is ',
    style: TextStyle(fontSize: 22, color: Colors.black),
    children: [
      TextSpan(
        text: 'amazing',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
    ],
  ),
)

// Theme-based text style
Text(
  'Themed Text',
  style: Theme.of(context).textTheme.headlineSmall,
)
```

### Assets: Fonts and Images
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/
    - assets/images/
  
dependencies:
  google_fonts: ^3.0.1
```

```dart
// Image from assets
Image.asset('assets/images/photo.jpg', fit: BoxFit.cover)

// Network image
Image.network('https://example.com/image.jpg')

// Google Fonts
Text('Hello', style: GoogleFonts.roboto(fontSize: 20))

// Accessibility with Semantics
Semantics(
  image: true,
  label: 'Description of the image',
  child: Image.asset('assets/beach.jpg'),
)
```

---

## Part 3: Layout System (Chapter 5)

### Column and Row
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,      // Vertical alignment
  crossAxisAlignment: CrossAxisAlignment.start,    // Horizontal alignment
  mainAxisSize: MainAxisSize.min,                  // Shrink to fit
  children: [
    Text('Item 1'),
    Text('Item 2'),
    Text('Item 3'),
  ],
)

Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Icon(Icons.star),
    Icon(Icons.favorite),
    Icon(Icons.share),
  ],
)
```

### MainAxisAlignment Options
| Value | Effect |
|-------|--------|
| `start` | Align to start (top/left) |
| `end` | Align to end (bottom/right) |
| `center` | Center along main axis |
| `spaceBetween` | Equal space between, none at edges |
| `spaceAround` | Equal space around each child |
| `spaceEvenly` | Equal space between and at edges |

### Flexible and Expanded
```dart
Row(
  children: [
    Container(width: 100, color: Colors.red),  // Fixed width
    
    // Expanded takes remaining space
    Expanded(
      child: Container(color: Colors.green),
    ),
    
    // Flexible with flex ratio
    Flexible(
      flex: 2,  // Takes 2x space of flex: 1
      child: Container(color: Colors.blue),
    ),
  ],
)

// Using Spacer for flexible gaps
Column(
  children: [
    Text('Top'),
    Spacer(),        // Expands to fill space
    Text('Bottom'),
  ],
)
```

### Stack Widget
```dart
Stack(
  alignment: Alignment.center,
  children: [
    // Background
    Image.asset('assets/background.jpg'),
    
    // Positioned overlay
    Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(onPressed: () {}),
    ),
    
    // Transform for custom positioning
    Transform.translate(
      offset: Offset(0, 100),
      child: Text('Shifted text'),
    ),
  ],
)
```

### SafeArea and LayoutBuilder
```dart
SafeArea(
  child: LayoutBuilder(
    builder: (context, constraints) {
      // constraints.maxWidth and constraints.maxHeight available
      return Container(
        width: constraints.maxWidth * 0.8,
        height: constraints.maxHeight * 0.5,
      );
    },
  ),
)
```

### CustomPaint for Shapes
```dart
CustomPaint(
  size: Size(200, 200),
  painter: MyPainter(),
)

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      50,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### Theming
```dart
MaterialApp(
  theme: ThemeData(
    primarySwatch: Colors.blue,
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  ),
  darkTheme: ThemeData.dark(),
  themeMode: ThemeMode.system,  // system, light, or dark
)

// Access theme
final primaryColor = Theme.of(context).primaryColor;
final textStyle = Theme.of(context).textTheme.bodyMedium;
```

---

## Part 4: Interactivity and Navigation (Chapter 6)

### StatefulWidget State Management
```dart
class Counter extends StatefulWidget {
  const Counter({super.key});
  
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;
  
  void increment() {
    setState(() {
      count++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(onPressed: increment, child: Text('+')),
      ],
    );
  }
}
```

### Buttons
```dart
// ElevatedButton (raised, primary action)
ElevatedButton(
  onPressed: () => print('Pressed'),
  onLongPress: () => print('Long press'),
  child: Text('Click Me'),
)

// TextButton (flat, secondary action)
TextButton(
  onPressed: () {},
  child: Text('Text Button'),
)

// IconButton
IconButton(
  icon: Icon(Icons.favorite),
  onPressed: () {},
  color: Colors.red,
)

// Button styling
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  onPressed: () {},
  child: Text('Styled Button'),
)
```

### ListView and Scrolling
```dart
// Simple ListView
ListView(
  children: [
    ListTile(title: Text('Item 1')),
    ListTile(title: Text('Item 2')),
    ListTile(title: Text('Item 3')),
  ],
)

// ListView.builder (efficient for large lists)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
      subtitle: Text(items[index].description),
      leading: Icon(Icons.star),
      trailing: Icon(Icons.arrow_forward),
      onTap: () => selectItem(items[index]),
    );
  },
)

// With ScrollController
final scrollController = ScrollController();

ListView.builder(
  controller: scrollController,
  itemExtent: 60.0,  // Fixed height for performance
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)

// Scroll to position
scrollController.animateTo(
  200.0,
  duration: Duration(milliseconds: 500),
  curve: Curves.easeInOut,
);

// Add Scrollbar
Scrollbar(
  controller: scrollController,
  child: ListView.builder(...),
)

// IMPORTANT: ListView in Column needs Expanded
Column(
  children: [
    Text('Header'),
    Expanded(  // Required!
      child: ListView.builder(...),
    ),
  ],
)
```

### TextField and Forms
```dart
// Basic TextField
final controller = TextEditingController();

TextField(
  controller: controller,
  decoration: InputDecoration(
    labelText: 'Username',
    hintText: 'Enter your username',
    prefixIcon: Icon(Icons.person),
  ),
  keyboardType: TextInputType.emailAddress,
  obscureText: false,  // true for passwords
)

// Form with validation
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an email';
          }
          if (!RegExp(r'[^@]+@[^.]+\..+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;  // null = valid
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Form is valid, process data
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)

// Dispose controller
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

### Navigation
```dart
// Push new screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => DetailScreen(item: selectedItem),
  ),
);

// Push and replace (can't go back)
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => HomeScreen()),
);

// Pop (go back)
Navigator.of(context).pop();

// Pop with result
Navigator.of(context).pop('result value');

// Named routes
MaterialApp(
  routes: {
    '/': (context) => HomeScreen(),
    '/detail': (context) => DetailScreen(),
  },
)

Navigator.pushNamed(context, '/detail');
```

### Dialogs
```dart
// Alert Dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirm'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('OK'),
      ),
    ],
  ),
);

// Get dialog result
final result = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(...),
);
if (result == true) {
  // User confirmed
}

// Cupertino (iOS-style) dialog
showCupertinoDialog(
  context: context,
  builder: (context) => CupertinoAlertDialog(
    title: Text('iOS Style'),
    content: Text('This is an iOS-style alert'),
    actions: [
      CupertinoButton(
        child: Text('OK'),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  ),
);
```

### Bottom Sheets
```dart
// Modal bottom sheet
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    height: 300,
    child: Column(
      children: [
        ListTile(title: Text('Option 1'), onTap: () {}),
        ListTile(title: Text('Option 2'), onTap: () {}),
      ],
    ),
  ),
);

// Persistent bottom sheet (scaffold)
Scaffold(
  body: ...,
  bottomSheet: Container(
    height: 50,
    child: Center(child: Text('Bottom Sheet')),
  ),
)
```

---

## Part 5: Basic State Management (Chapter 7)

### Model-View Separation
```dart
// Model
class Task {
  final String description;
  final bool complete;
  
  const Task({required this.description, this.complete = false});
  
  Task copyWith({String? description, bool? complete}) {
    return Task(
      description: description ?? this.description,
      complete: complete ?? this.complete,
    );
  }
}

class Plan {
  final String name;
  final List<Task> tasks;
  
  const Plan({required this.name, required this.tasks});
  
  String get completenessMessage {
    final complete = tasks.where((t) => t.complete).length;
    return '$complete/${tasks.length} complete';
  }
}
```

### InheritedWidget / InheritedNotifier
```dart
class PlanProvider extends InheritedNotifier<ValueNotifier<List<Plan>>> {
  const PlanProvider({
    super.key,
    required super.notifier,
    required super.child,
  });
  
  static ValueNotifier<List<Plan>> of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PlanProvider>()!
        .notifier!;
  }
}

// Usage at app root
PlanProvider(
  notifier: ValueNotifier<List<Plan>>([]),
  child: MaterialApp(home: HomeScreen()),
)

// Access from anywhere
final planNotifier = PlanProvider.of(context);
planNotifier.value = [...planNotifier.value, newPlan];
```

### State Across Multiple Screens
```dart
// Place provider ABOVE Navigator (MaterialApp)
// to persist state across screen changes

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlanProvider(
      notifier: ValueNotifier<List<Plan>>([]),
      child: MaterialApp(
        home: PlanCreatorScreen(),
      ),
    );
  }
}
```

---

## Part 6: Asynchronous Programming (Chapter 8)

### Future Basics
```dart
// Async function returning Future
Future<String> fetchData() async {
  final response = await http.get(Uri.parse('https://api.example.com/data'));
  return response.body;
}

// Using then callback
fetchData().then((value) {
  print('Received: $value');
}).catchError((error) {
  print('Error: $error');
}).whenComplete(() {
  print('Done');
});

// Using async/await (preferred)
Future<void> loadData() async {
  try {
    final data = await fetchData();
    setState(() {
      result = data;
    });
  } catch (error) {
    setState(() {
      result = 'Error: $error';
    });
  }
}
```

### Future.delayed
```dart
Future<int> delayedValue() async {
  await Future.delayed(Duration(seconds: 2));
  return 42;
}
```

### Multiple Futures (FutureGroup / Future.wait)
```dart
// FutureGroup
import 'package:async/async.dart';

void runParallel() {
  FutureGroup<int> group = FutureGroup<int>();
  group.add(fetchOne());
  group.add(fetchTwo());
  group.add(fetchThree());
  group.close();
  
  group.future.then((List<int> results) {
    int total = results.fold(0, (sum, val) => sum + val);
    print('Total: $total');
  });
}

// Future.wait (simpler alternative)
final results = await Future.wait<int>([
  fetchOne(),
  fetchTwo(),
  fetchThree(),
]);
```

### Completer
```dart
late Completer<int> completer;

Future<int> getNumber() {
  completer = Completer<int>();
  calculateAsync();
  return completer.future;
}

void calculateAsync() async {
  await Future.delayed(Duration(seconds: 2));
  completer.complete(42);  // or completer.completeError(error)
}
```

### StatefulWidget Lifecycle
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // Called once when widget is created
    loadInitialData();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Called when dependencies change (e.g., InheritedWidget)
  }
  
  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Called when parent rebuilds with new properties
  }
  
  @override
  void dispose() {
    // Clean up resources
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### FutureBuilder
```dart
FutureBuilder<List<Item>>(
  future: fetchItems(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    
    final items = snapshot.data!;
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(items[index].name),
      ),
    );
  },
)
```

### Navigation with Async Results
```dart
// Push and wait for result
final result = await Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (context) => SelectionScreen()),
);

if (result != null) {
  print('Selected: $result');
}

// Pop with result
Navigator.pop(context, selectedValue);
```

---

## Part 7: Data Persistence and Networking (Chapter 9)

### JSON Serialization
```dart
class Pizza {
  int id;
  String pizzaName;
  String description;
  double price;
  String imageUrl;
  
  Pizza({
    required this.id,
    required this.pizzaName,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
  
  // From JSON (defensive parsing)
  Pizza.fromJson(Map<String, dynamic> json)
      : id = int.tryParse(json['id'].toString()) ?? 0,
        pizzaName = json['pizzaName']?.toString() ?? 'No name',
        description = json['description']?.toString() ?? '',
        price = double.tryParse(json['price'].toString()) ?? 0,
        imageUrl = json['imageUrl']?.toString() ?? '';
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pizzaName': pizzaName,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}

// Parse list from JSON
List<Pizza> parsePizzas(String jsonString) {
  final jsonList = json.decode(jsonString) as List;
  return jsonList.map<Pizza>((item) => Pizza.fromJson(item)).toList();
}
```

### HTTP Requests
```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpHelper {
  final String authority = 'api.example.com';
  
  // GET request
  Future<List<Pizza>> getPizzaList() async {
    final url = Uri.https(authority, '/pizzas');
    final response = await http.get(url);
    
    if (response.statusCode == HttpStatus.ok) {
      final jsonList = json.decode(response.body) as List;
      return jsonList.map<Pizza>((item) => Pizza.fromJson(item)).toList();
    }
    return [];
  }
  
  // POST request
  Future<bool> addPizza(Pizza pizza) async {
    final url = Uri.https(authority, '/pizzas');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(pizza.toJson()),
    );
    return response.statusCode == HttpStatus.created;
  }
  
  // PUT request
  Future<bool> updatePizza(Pizza pizza) async {
    final url = Uri.https(authority, '/pizzas/${pizza.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(pizza.toJson()),
    );
    return response.statusCode == HttpStatus.ok;
  }
  
  // DELETE request
  Future<bool> deletePizza(int id) async {
    final url = Uri.https(authority, '/pizzas/$id');
    final response = await http.delete(url);
    return response.statusCode == HttpStatus.ok;
  }
}
```

### SharedPreferences
```dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  Future<void> saveCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', value);
  }
  
  Future<int> loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('counter') ?? 0;
  }
  
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// Available methods
// prefs.setString(key, value) / getString(key)
// prefs.setInt(key, value) / getInt(key)
// prefs.setDouble(key, value) / getDouble(key)
// prefs.setBool(key, value) / getBool(key)
// prefs.setStringList(key, list) / getStringList(key)
```

### File System Access
```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  Future<String> get _documentsPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
  
  Future<String> get _tempPath async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }
  
  Future<File> writeFile(String filename, String content) async {
    final path = await _documentsPath;
    final file = File('$path/$filename');
    return file.writeAsString(content);
  }
  
  Future<String> readFile(String filename) async {
    try {
      final path = await _documentsPath;
      final file = File('$path/$filename');
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }
}
```

### Secure Storage
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  final storage = FlutterSecureStorage();
  
  Future<void> savePassword(String password) async {
    await storage.write(key: 'password', value: password);
  }
  
  Future<String?> getPassword() async {
    return await storage.read(key: 'password');
  }
  
  Future<void> deleteAll() async {
    await storage.deleteAll();
  }
}
```

---

## Part 8: Streams (Chapter 10)

### Stream Basics
```dart
// Create stream
Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

// Listen to stream
countStream(5).listen(
  (value) => print('Value: $value'),
  onError: (error) => print('Error: $error'),
  onDone: () => print('Stream complete'),
);
```

### StreamController
```dart
class CounterBloc {
  final _counterController = StreamController<int>.broadcast();
  int _counter = 0;
  
  Stream<int> get counterStream => _counterController.stream;
  Sink<int> get counterSink => _counterController.sink;
  
  void increment() {
    _counter++;
    _counterController.sink.add(_counter);
  }
  
  void dispose() {
    _counterController.close();
  }
}

// Usage
final bloc = CounterBloc();
bloc.counterStream.listen((count) => print('Count: $count'));
bloc.increment();
```

### Stream Transformations
```dart
// Map
stream.map((value) => value * 2);

// Where (filter)
stream.where((value) => value > 5);

// Expand (flatMap)
stream.expand((value) => [value, value * 2]);

// Distinct
stream.distinct();

// Take / Skip
stream.take(5);  // First 5 items
stream.skip(2);  // Skip first 2

// Custom transformer
StreamTransformer<int, String> transformer = StreamTransformer.fromHandlers(
  handleData: (data, sink) {
    sink.add('Number: $data');
  },
);
stream.transform(transformer);
```

### StreamBuilder
```dart
StreamBuilder<int>(
  stream: bloc.counterStream,
  initialData: 0,
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return Text('Count: ${snapshot.data}');
  },
)
```

### BLoC Pattern (Basic)
```dart
class StopwatchBloc {
  final _timeController = StreamController<String>();
  final _buttonController = StreamController<StopwatchState>();
  
  Stream<String> get timeStream => _timeController.stream;
  Stream<StopwatchState> get buttonStream => _buttonController.stream;
  Sink<String> get timeSink => _timeController.sink;
  
  Timer? _timer;
  int _milliseconds = 0;
  
  void startStopwatch() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      _milliseconds += 100;
      _timeController.sink.add(_formatTime(_milliseconds));
    });
    _buttonController.sink.add(StopwatchState.running);
  }
  
  void stopStopwatch() {
    _timer?.cancel();
    _buttonController.sink.add(StopwatchState.stopped);
  }
  
  String _formatTime(int ms) => '${(ms / 1000).toStringAsFixed(1)}s';
  
  void dispose() {
    _timer?.cancel();
    _timeController.close();
    _buttonController.close();
  }
}

enum StopwatchState { running, stopped }
```

---

## Part 9: Animations (Chapter 12)

### AnimationController Setup
```dart
class _MyAnimationState extends State<MyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    animation = Tween<double>(begin: 0, end: 200).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    
    controller.forward();
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: animation.value,
      top: animation.value,
      child: Container(width: 50, height: 50, color: Colors.blue),
    );
  }
}
```

### Curved Animations
```dart
animation = CurvedAnimation(
  parent: controller,
  curve: Curves.easeInOut,  // Many options available
);

// Common curves:
// Curves.linear, Curves.easeIn, Curves.easeOut, Curves.easeInOut
// Curves.bounceIn, Curves.bounceOut, Curves.elastic
```

### AnimatedBuilder (Optimized)
```dart
AnimatedBuilder(
  animation: controller,
  child: Container(width: 50, height: 50, color: Colors.blue),  // Static part
  builder: (context, child) {
    return Transform.translate(
      offset: Offset(animation.value, 0),
      child: child,  // Reused, not rebuilt
    );
  },
)
```

### Pre-made Transitions
```dart
// FadeTransition
FadeTransition(
  opacity: animation,
  child: Container(...),
)

// SlideTransition
SlideTransition(
  position: Tween<Offset>(
    begin: Offset(-1, 0),
    end: Offset.zero,
  ).animate(controller),
  child: Container(...),
)

// ScaleTransition
ScaleTransition(
  scale: animation,
  child: Container(...),
)

// RotationTransition
RotationTransition(
  turns: animation,
  child: Container(...),
)
```

### Hero Animation
```dart
// Source screen
Hero(
  tag: 'item-$id',  // Must be unique
  child: Image.asset('assets/image.jpg'),
)

// Destination screen (same tag)
Hero(
  tag: 'item-$id',
  child: Image.asset('assets/image.jpg', width: 300),
)

// Navigate to trigger animation
Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(id)));
```

### AnimatedList
```dart
final listKey = GlobalKey<AnimatedListState>();
final items = <String>[];

AnimatedList(
  key: listKey,
  initialItemCount: items.length,
  itemBuilder: (context, index, animation) {
    return FadeTransition(
      opacity: animation,
      child: ListTile(title: Text(items[index])),
    );
  },
)

// Insert item
void addItem(String item) {
  items.add(item);
  listKey.currentState!.insertItem(
    items.length - 1,
    duration: Duration(milliseconds: 300),
  );
}

// Remove item
void removeItem(int index) {
  final removed = items.removeAt(index);
  listKey.currentState!.removeItem(
    index,
    (context, animation) => FadeTransition(
      opacity: animation,
      child: ListTile(title: Text(removed)),
    ),
    duration: Duration(milliseconds: 300),
  );
}
```

### Implicit Animations (Simple)
```dart
// AnimatedContainer - auto-animates property changes
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isExpanded ? 200 : 100,
  height: isExpanded ? 200 : 100,
  color: isSelected ? Colors.blue : Colors.grey,
  child: Text('Tap me'),
)

// AnimatedOpacity
AnimatedOpacity(
  duration: Duration(milliseconds: 300),
  opacity: isVisible ? 1.0 : 0.0,
  child: Text('Fade me'),
)

// AnimatedPositioned (inside Stack)
AnimatedPositioned(
  duration: Duration(milliseconds: 300),
  left: isLeft ? 0 : 100,
  top: isTop ? 0 : 100,
  child: Container(...),
)
```

---

## Part 10: Firebase Integration (Chapter 13)

### Firebase Setup
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_analytics: ^latest
  firebase_messaging: ^latest
  firebase_storage: ^latest
```

```dart
// Initialize Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

### Firebase Authentication
```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Email/Password registration
  Future<UserCredential?> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      return null;
    }
  }
  
  // Email/Password login
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      return null;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

### Cloud Firestore
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Add document
  Future<DocumentReference> addItem(Map<String, dynamic> data) {
    return _db.collection('items').add(data);
  }
  
  // Get document
  Future<DocumentSnapshot> getItem(String id) {
    return _db.collection('items').doc(id).get();
  }
  
  // Update document
  Future<void> updateItem(String id, Map<String, dynamic> data) {
    return _db.collection('items').doc(id).update(data);
  }
  
  // Delete document
  Future<void> deleteItem(String id) {
    return _db.collection('items').doc(id).delete();
  }
  
  // Get all documents
  Stream<QuerySnapshot> getItems() {
    return _db.collection('items').snapshots();
  }
  
  // Query with filter
  Stream<QuerySnapshot> getFilteredItems(String category) {
    return _db
        .collection('items')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

// Usage with StreamBuilder
StreamBuilder<QuerySnapshot>(
  stream: FirestoreService().getItems(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final docs = snapshot.data!.docs;
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        return ListTile(title: Text(data['name']));
      },
    );
  },
)
```

### Firebase Cloud Messaging (Push Notifications)
```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.notification?.title}');
    });
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }
  
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    print('Background message: ${message.notification?.title}');
  }
}
```

---

## Part 11: Flutter Web and Desktop (Chapter 15)

### Responsive Layout
```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return MobileLayout();
        } else if (constraints.maxWidth < 1200) {
          return TabletLayout();
        } else {
          return DesktopLayout();
        }
      },
    );
  }
}

// Using MediaQuery
final screenWidth = MediaQuery.of(context).size.width;
final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
```

### Desktop Mouse Events
```dart
MouseRegion(
  onEnter: (_) => setState(() => isHovered = true),
  onExit: (_) => setState(() => isHovered = false),
  child: GestureDetector(
    onSecondaryTap: () => showContextMenu(),  // Right-click
    child: Container(
      color: isHovered ? Colors.blue.shade100 : Colors.white,
      child: Text('Hover me'),
    ),
  ),
)

// Cursor customization
MouseRegion(
  cursor: SystemMouseCursors.click,
  child: Text('Clickable'),
)
```

### Desktop Menus
```dart
PlatformMenuBar(
  menus: [
    PlatformMenu(
      label: 'File',
      menus: [
        PlatformMenuItem(
          label: 'New',
          shortcut: SingleActivator(LogicalKeyboardKey.keyN, control: true),
          onSelected: () => createNew(),
        ),
        PlatformMenuItem(
          label: 'Open',
          shortcut: SingleActivator(LogicalKeyboardKey.keyO, control: true),
          onSelected: () => openFile(),
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: 'Exit',
              onSelected: () => exit(0),
            ),
          ],
        ),
      ],
    ),
  ],
)
```

---

## Part 12: App Distribution (Chapter 16)

### Android Release Build
```bash
# Generate keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

```groovy
// android/app/build.gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### iOS Release Build
```bash
# Build for iOS
flutter build ios --release

# Archive in Xcode
# Product > Archive > Distribute App
```

### Fastlane Automation
```ruby
# fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Play Store internal track"
  lane :internal do
    gradle(task: "bundle", build_type: "Release")
    upload_to_play_store(track: "internal")
  end
end

platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    build_app(scheme: "Runner")
    upload_to_testflight
  end
end
```

### App Icons
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^latest

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
```

```bash
flutter pub run flutter_launcher_icons:main
```

---

## Quick Reference: Common Patterns

### Provider Pattern (using provider package)
```dart
// Model with ChangeNotifier
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
}

// Provide at root
ChangeNotifierProvider(
  create: (_) => Counter(),
  child: MyApp(),
)

// Consume
Consumer<Counter>(
  builder: (context, counter, child) {
    return Text('Count: ${counter.count}');
  },
)

// Or with context
context.read<Counter>().increment();
final count = context.watch<Counter>().count;
```

### Decision Tree: Widget Selection

**For lists:**
- Few items → `ListView(children: [...])`
- Many items → `ListView.builder()`
- Grid layout → `GridView.builder()`
- Need animations → `AnimatedList`

**For layout:**
- Vertical stack → `Column`
- Horizontal stack → `Row`
- Overlapping → `Stack`
- Scrollable single child → `SingleChildScrollView`
- Responsive → `LayoutBuilder`

**For state:**
- Local UI state → `StatefulWidget` + `setState`
- Shared across few widgets → `InheritedWidget`
- Complex app state → Provider / Riverpod / BLoC

**For async:**
- One-time Future → `FutureBuilder`
- Continuous Stream → `StreamBuilder`

---

## Debugging and DevTools

```dart
// Debug print
debugPrint('Variable: $value');

// Assert (only in debug mode)
assert(value != null, 'Value should not be null');

// Performance overlay
MaterialApp(
  showPerformanceOverlay: true,
  // ...
)
```

### Flutter Inspector Commands
```bash
# Run with verbose logging
flutter run -v

# Analyze code
flutter analyze

# Run tests
flutter test

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade
```

---

