# Flutter Design Patterns and Best Practices - LLM Reference Guide

## Overview
This document summarizes the key concepts, patterns, and best practices from "Flutter Design Patterns and Best Practices" by Daria Orlova, Esra Kadah, and Jaime Blasco (Packt, 2024). Use this as a reference when building scalable, maintainable Flutter applications.

---

# PART 1: BUILDING DELIGHTFUL USER INTERFACES

## Chapter 1: Best Practices for Building UIs with Flutter

### Declarative vs Imperative UI Design
- **Imperative**: Manually update UI elements step-by-step (traditional approach)
- **Declarative**: UI is a function of state (`UI = f(state)`) - Flutter's approach
- Flutter rebuilds the entire widget tree based on state changes rather than manually updating elements

### The Three Trees: Widget, Element, RenderObject
1. **Widget Tree**: Immutable configuration/blueprint objects
2. **Element Tree**: Mutable objects managing widget lifecycle and state
3. **RenderObject Tree**: Handles layout, painting, and hit-testing

```dart
// Widget.canUpdate determines if an element can be reused
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType 
      && oldWidget.key == newWidget.key;
}
```

### Performance Optimization Strategies

#### 1. Push Rebuilds Down the Tree
Extract stateful logic into smaller widgets to minimize rebuild scope:

```dart
// BAD: Entire page rebuilds on counter change
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() => setState(() { _counter++; });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('$_counter')); // Entire scaffold rebuilds
  }
}

// GOOD: Only CounterText rebuilds
class CounterText extends StatefulWidget { ... }
class _CounterTextState extends State<CounterText> {
  int _counter = 0;
  @override
  Widget build(BuildContext context) => Text('$_counter');
}
```

#### 2. Use const Constructors
Const widgets are cached and skip rebuilds:

```dart
// DO: Use const
return const ConstText(); 

// DON'T: Creates new instance each build
return ConstText();
```

#### 3. Cache Non-Const Widgets
Store widgets in final fields when const isn't possible:

```dart
class _MyState extends State<MyWidget> {
  final greenContainer = Container(color: Colors.green, height: 100, width: 100);
  
  @override
  Widget build(BuildContext context) => greenContainer; // Same instance
}
```

#### 4. Use Specific InheritedWidget Accessors
```dart
// Instead of subscribing to entire MediaQuery:
final size = MediaQuery.of(context).size; // Rebuilds on ANY change

// Subscribe to specific property:
final size = MediaQuery.sizeOf(context); // Only rebuilds on size change
```

#### 5. RepaintBoundary for Heavy Widgets
Prevents repainting of widget subtrees:
```dart
RepaintBoundary(child: ExpensiveWidget())
```

#### 6. ListView.builder for Large Lists
Only renders visible items:
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```
**Warning**: Avoid `shrinkWrap: true` as it defeats lazy loading.

---

## Chapter 2: Responsive UIs for All Devices

### Flutter Layout Algorithm
**Core Rule**: Constraints go down, sizes go up, parent sets position.

```dart
// Tight constraints - exact size enforced
BoxConstraints.tight(const Size(200, 100))

// Loose constraints - max defined, child chooses
BoxConstraints.loose(const Size(200, 100))
```

### Responsive Layout Tools

#### MediaQuery
```dart
final screenSize = MediaQuery.of(context).size;
final padding = MediaQuery.paddingOf(context);
final orientation = MediaQuery.orientationOf(context);
```

#### LayoutBuilder
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) return DesktopLayout();
    return MobileLayout();
  },
)
```

#### OrientationBuilder
```dart
OrientationBuilder(
  builder: (context, orientation) {
    if (orientation == Orientation.portrait) return PortraitLayout();
    return LandscapeLayout();
  },
)
```

### Flexible Layouts

#### Row and Column
- `mainAxisAlignment`: Position along main axis
- `crossAxisAlignment`: Position along cross axis

#### Flexible and Expanded
```dart
Row(children: [
  Expanded(flex: 1, child: Container()), // Takes 1/3
  Expanded(flex: 2, child: Container()), // Takes 2/3
])
```

#### Solving Overflow
1. **Wrap with Expanded/Flexible**
2. **Use SingleChildScrollView**
3. **Use Wrap widget** - automatically wraps to next line

### Accessibility Best Practices
- Use `Semantics` widget for screen readers
- Ensure sufficient color contrast
- Support font scaling via `MediaQuery.textScaleFactorOf`

---

# PART 2: CONNECTING UI WITH BUSINESS LOGIC

## Chapter 3: Vanilla State Management

### State Types
- **Ephemeral State**: Local to widget (use `setState`)
- **App State**: Shared across widgets (use state management patterns)

### Observer Pattern Implementation

#### ValueNotifier (Single Value)
```dart
class CartNotifier extends ValueNotifier<int> {
  CartNotifier() : super(0);
  void increment() => value++;
}

// In widget
ValueListenableBuilder<int>(
  valueListenable: cartNotifier,
  builder: (context, count, child) => Text('$count'),
)
```

#### ChangeNotifier (Multiple Values)
```dart
class CartNotifier extends ChangeNotifier {
  final List<Item> _items = [];
  List<Item> get items => _items;
  
  void addItem(Item item) {
    _items.add(item);
    notifyListeners(); // Notify all listeners
  }
}

// In widget
ListenableBuilder(
  listenable: cartNotifier,
  builder: (context, child) => ItemList(cartNotifier.items),
)
```

### InheritedWidget Pattern
Provides dependencies down the widget tree:

```dart
class CartProvider extends InheritedWidget {
  final CartNotifier cartNotifier;
  
  const CartProvider({required this.cartNotifier, required Widget child}) 
    : super(child: child);
  
  static CartNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CartProvider>()!.cartNotifier;
  }
  
  @override
  bool updateShouldNotify(CartProvider old) => cartNotifier != old.cartNotifier;
}

// Usage
final cart = CartProvider.of(context);
```

### BuildContext Best Practices

#### Don't Access Context Too Early
```dart
// WRONG - called in initState
@override
void initState() {
  final size = MediaQuery.of(context).size; // ERROR!
}

// CORRECT - use didChangeDependencies or build
@override
void didChangeDependencies() {
  final size = MediaQuery.of(context).size; // OK
}
```

#### Don't Access Context After Async Gaps
```dart
onTap: () async {
  await Future.delayed(Duration(seconds: 2));
  if (context.mounted) { // Check if still mounted
    Navigator.of(context).pop();
  }
}
```

---

## Chapter 4: State Management Patterns

### MVX Patterns Overview
- **M (Model)**: Data and business logic
- **V (View)**: UI representation
- **X (varies)**: Controller, ViewModel, Intent, etc.

### MVVM Pattern (Model-View-ViewModel)
- **Data binding**: Changes in ViewModel automatically reflect in View
- ViewModel exposes state; View observes and displays it

### MVI Pattern (Model-View-Intent)
- **Unidirectional data flow**
- View sends Intents → ViewModel processes → Emits new State → View renders

### flutter_bloc Implementation

#### Cubit (Simpler, Method-Based)
```dart
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial());
  
  Future<void> addToCart(Product item) async {
    emit(state.copyWith(isLoading: true));
    await _repository.addToCart(item);
    emit(state.copyWith(isLoading: false, items: [...state.items, item]));
  }
}
```

#### Bloc (Event-Driven)
```dart
// Events
sealed class CartEvent {}
class AddItem extends CartEvent { final Product item; AddItem(this.item); }
class RemoveItem extends CartEvent { final Product item; RemoveItem(this.item); }

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState.initial()) {
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
  }
  
  Future<void> _onAddItem(AddItem event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _repository.addToCart(event.item);
    emit(state.copyWith(isLoading: false));
  }
}
```

### BlocProvider and BlocConsumer
```dart
// Provide
BlocProvider<CartBloc>(
  create: (context) => CartBloc(),
  child: CartPage(),
)

// Consume
BlocConsumer<CartBloc, CartState>(
  listener: (context, state) {
    if (state.error != null) showError(state.error);
  },
  builder: (context, state) {
    if (state.isLoading) return LoadingIndicator();
    return CartList(state.items);
  },
)
```

### Segmented State Pattern (Triple Pattern)
Encapsulate loading/error/success states:

```dart
class DelayedResult<T> {
  final T? value;
  final Exception? error;
  final bool isInProgress;
  
  const DelayedResult.inProgress() : value = null, error = null, isInProgress = true;
  const DelayedResult.fromValue(T result) : value = result, error = null, isInProgress = false;
  const DelayedResult.fromError(Exception e) : value = null, error = e, isInProgress = false;
  const DelayedResult.idle() : value = null, error = null, isInProgress = false;
  
  bool get isSuccessful => value != null;
  bool get isError => error != null;
}
```

### State Equality with Equatable
```dart
class CartState extends Equatable {
  final List<Item> items;
  final double totalPrice;
  
  const CartState({required this.items, required this.totalPrice});
  
  @override
  List<Object?> get props => [items, totalPrice];
  
  CartState copyWith({List<Item>? items, double? totalPrice}) {
    return CartState(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
```

### Immutability Warning
Always create new collections, not references:
```dart
// WRONG - same reference
emit(state.copyWith(items: _items));

// CORRECT - new copy
emit(state.copyWith(items: Map.unmodifiable(_items)));
```

---

## Chapter 5: Navigation

### Navigator 1.0 (Imperative)
```dart
// Push
Navigator.of(context).push(MaterialPageRoute(builder: (_) => NextPage()));

// Push named
Navigator.of(context).pushNamed('/cart');

// Pop
Navigator.of(context).pop();
```

### Navigator 2.0 (Declarative)
For complex navigation, deep linking, and web URLs.

#### Key Components
- **RouterDelegate**: Manages navigation state and builds Navigator
- **RouteInformationParser**: Parses URLs into route configuration
- **Page**: Immutable object representing a screen

```dart
// Route path representation
class AppRoutePath {
  final int? productId;
  final bool isUnknown;
  
  AppRoutePath.home() : productId = null, isUnknown = false;
  AppRoutePath.product(this.productId) : isUnknown = false;
  AppRoutePath.unknown() : productId = null, isUnknown = true;
}

// Router delegate
class AppRouterDelegate extends RouterDelegate<AppRoutePath> 
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(child: HomePage()),
        if (_selectedProduct != null)
          MaterialPage(child: ProductPage(product: _selectedProduct!)),
        if (_show404)
          MaterialPage(child: NotFoundPage()),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        _selectedProduct = null;
        notifyListeners();
        return true;
      },
    );
  }
}
```

---

# PART 3: ARCHITECTURE AND DESIGN PATTERNS

## Chapter 6: Repository Pattern

### Purpose
- Separates business logic from data access
- Provides consistent interface for data operations
- Enables easy swapping of data sources

### Repository Interface
```dart
abstract interface class ProductRepository {
  Future<List<Product>> fetchProducts();
  Future<Product> fetchProductById(String id);
  Future<void> updateProduct(Product product);
}
```

### Repository Implementation
```dart
class AppProductRepository implements ProductRepository {
  final NetworkProductRepository _remoteDataSource;
  final LocalProductRepository _localDataSource;
  
  AppProductRepository({
    required NetworkProductRepository remoteDataSource,
    required LocalProductRepository localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;
  
  @override
  Future<List<Product>> fetchProducts() async {
    final localProducts = await _localDataSource.fetchProducts();
    if (localProducts.isNotEmpty) return localProducts;
    
    final remoteProducts = await _remoteDataSource.fetchProducts();
    await _localDataSource.cacheProducts(remoteProducts);
    return remoteProducts;
  }
}
```

### Data Sources

#### Remote Data Source
```dart
class ApiService {
  final String _baseUrl = 'https://api.example.com';
  
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }
}
```

#### Local Data Source (Hive)
```dart
class LocalProductRepository implements ProductRepository {
  final Box<Product> _productBox;
  
  LocalProductRepository(this._productBox);
  
  @override
  Future<List<Product>> fetchProducts() async {
    return _productBox.values.toList();
  }
  
  Future<void> cacheProducts(List<Product> products) async {
    for (final product in products) {
      await _productBox.put(product.id, product);
    }
  }
}
```

---

## Chapter 7: Inversion of Control (IoC)

### Why Avoid Singletons with Static Access?
- Global state leads to inconsistency
- Tight coupling makes testing difficult
- Implementation details leak to consumers

### Dependency Injection via Constructor
```dart
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;
  
  CartBloc({required CartRepository cartRepository})
    : _cartRepository = cartRepository,
      super(CartState.initial());
}
```

### RepositoryProvider (flutter_bloc)
```dart
// Providing
RepositoryProvider<CartRepository>(
  create: (_) => InMemoryCartRepository(),
  child: MaterialApp(home: MainPage()),
)

// Consuming
BlocProvider<CartBloc>(
  create: (context) => CartBloc(
    cartRepository: context.read<CartRepository>(),
  ),
  child: CartPage(),
)
```

### Service Locator with get_it
```dart
Future<void> setupDependencies() async {
  final getIt = GetIt.instance;
  
  getIt.registerLazySingleton<CartRepository>(() => InMemoryCartRepository());
  
  getIt.registerSingletonAsync<ProductRepository>(() async {
    final hiveService = HiveService();
    await hiveService.initialize();
    return AppProductRepository(
      remoteDataSource: NetworkProductRepository(ApiService()),
      localDataSource: LocalProductRepository(hiveService.productBox),
    );
  });
  
  await getIt.allReady();
}

// Usage
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository = GetIt.instance.get();
}
```

### When to Use Which?
- **RepositoryProvider**: Already using flutter_bloc, want widget-lifecycle-bound dependencies
- **get_it**: Need fine-grained control, async initialization, or context-free access

---

## Chapter 8: Layered Architecture

### Three Core Layers

#### 1. Presentation Layer
- Widgets, views, blocs/cubits
- Handles UI rendering and user input
- Only depends on Domain layer

#### 2. Domain Layer
- Business rules and logic
- Abstract interfaces (repositories, services)
- Domain models
- **No dependencies on other layers**

#### 3. Data Layer
- Implements domain interfaces
- API clients, database access
- Data models (DTOs)
- Only depends on Domain layer

### Data Flow
```
User Action → Presentation → Domain ← Data
     ↑______________|
         State Update
```

### File Organization

#### Layer-First Approach
```
lib/
├── presentation/
│   ├── cart/
│   └── product/
├── domain/
│   ├── cart/
│   └── product/
└── data/
    ├── cart/
    └── product/
```

#### Feature-First Approach
```
lib/
├── cart/
│   ├── presentation/
│   ├── domain/
│   └── data/
└── product/
    ├── presentation/
    ├── domain/
    └── data/
```

### Scoping Dependencies to Feature Lifecycle
```dart
class CheckoutFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CheckoutRepository>(
          create: (_) => StubCheckoutRepository(),
        ),
      ],
      child: CheckoutPage.withBloc(),
    );
  }
}
```

### SOLID Principles in Practice
- **S**ingle Responsibility: Each class has one reason to change
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable for base types
- **I**nterface Segregation: Many specific interfaces over one general
- **D**ependency Inversion: Depend on abstractions, not concretions

---

## Chapter 9: Concurrent Programming

### Dart's Event Loop
- Dart is single-threaded with an event loop
- Async operations don't block the main thread
- Events processed via FIFO queue

### Future API
```dart
// Basic async/await
Future<String> fetchData() async {
  final response = await http.get(Uri.parse(url));
  return response.body;
}

// Chaining
fetchData()
  .then((data) => processData(data))
  .catchError((error) => handleError(error));

// Parallel execution
final results = await Future.wait([
  fetchProducts(),
  fetchCategories(),
  fetchUser(),
]);
```

### Isolates for CPU-Intensive Work
```dart
// Simple compute function
final result = await compute(expensiveOperation, inputData);

// Custom isolate
final receivePort = ReceivePort();
await Isolate.spawn(heavyTask, receivePort.sendPort);
final result = await receivePort.first;
```

---

## Chapter 10: Platform Channels

### MethodChannel Basics
```dart
// Flutter side
const platform = MethodChannel('com.example.app/channel');

Future<List<String>> getFavorites() async {
  final result = await platform.invokeMethod<List>('getFaves');
  return result?.cast<String>() ?? [];
}

// Kotlin side
class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/channel")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getFaves" -> result.success(getFaves())
          else -> result.notImplemented()
        }
      }
  }
}
```

### Type-Safe Channels with Pigeon
```dart
// Define interface in pigeon file
@HostApi()
abstract class StorageApi {
  void addFavorite(String id);
  void removeFavorite(String id);
  bool isFavorite(String id);
  List<String> getFavorites();
}

// Generate with: flutter pub run pigeon --input pigeon/storage_api.dart
```

---

# PART 4: QUALITY AND TESTING

## Chapter 11: Testing

### Unit Tests
```dart
test('Remove item from cart', () async {
  final repository = FakeCartRepository();
  final bloc = CartBloc(cartRepository: repository);
  
  await repository.addToCart(testProduct);
  bloc.add(const Load());
  await Future.delayed(Duration(milliseconds: 100));
  
  bloc.add(RemoveItem(cartItem));
  await Future.delayed(Duration(milliseconds: 100));
  
  expect(bloc.state.items.length, equals(0));
  expect(bloc.state.totalPrice, equals(0));
});
```

### Widget Tests
```dart
testWidgets('displays item in cart', (tester) async {
  final repository = FakeCartRepository();
  await repository.addToCart(testProduct);
  
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<CartBloc>(
        create: (_) => CartBloc(cartRepository: repository),
        child: CartPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  
  expect(find.text('Test Product'), findsOneWidget);
});
```

### Golden Tests
```dart
testWidgets('matches golden', (tester) async {
  await tester.pumpWidget(MaterialApp(home: DesignSystemPage()));
  await tester.pumpAndSettle();
  
  await expectLater(
    find.byType(DesignSystemPage),
    matchesGoldenFile('goldens/design_system.png'),
  );
});

// Update goldens: flutter test --update-goldens
```

### Mocking with Mockito
```dart
@GenerateMocks([CartRepository])
void main() {
  late MockCartRepository mockRepository;
  
  setUp(() {
    mockRepository = MockCartRepository();
    when(mockRepository.cartInfoStream).thenAnswer((_) => Stream.empty());
  });
  
  test('loads cart', () async {
    when(mockRepository.cartInfoFuture).thenAnswer(
      (_) async => CartInfo(items: {}, totalPrice: 0),
    );
    
    final bloc = CartBloc(cartRepository: mockRepository);
    bloc.add(Load());
    
    await Future.delayed(Duration(milliseconds: 100));
    verify(mockRepository.cartInfoFuture).called(1);
  });
}
```

---

## Chapter 12: Static Analysis and Debugging

### analysis_options.yaml Configuration
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
  exclude:
    - "**/*.g.dart"
  errors:
    dead_code: error
    use_build_context_synchronously: warning

linter:
  rules:
    prefer_const_constructors: true
    avoid_print: true
    prefer_final_locals: true
```

### Essential Lint Rules
- `use_build_context_synchronously`: Prevents async context access bugs
- `prefer_const_constructors`: Improves widget rebuild performance
- `avoid_print`: Use proper logging
- `prefer_final_locals`: Immutability
- `always_declare_return_types`: Type safety

### Debugging Tools
- **Logging**: Use structured logging, not `print()`
- **Assertions**: `assert(condition, 'Debug message')`
- **Breakpoints**: Step through code execution
- **Flutter DevTools**: Performance, memory, network inspection

### Flutter DevTools Features
| View | Purpose |
|------|---------|
| Widget Inspector | Examine widget tree |
| Performance | Identify jank and slow frames |
| CPU Profiler | Find expensive methods |
| Memory | Detect leaks |
| Network | Inspect HTTP traffic |
| App Size | Analyze bundle size |

---

# QUICK REFERENCE

## Common Patterns Decision Tree

```
Need to share state?
├─ Single widget → setState
├─ Few widgets (parent-child) → Lift state up
└─ Many widgets → State management
    ├─ Simple → ValueNotifier + ValueListenableBuilder
    ├─ Medium → Cubit (flutter_bloc)
    └─ Complex → Bloc with events (flutter_bloc)

Need data from API/DB?
└─ Create Repository interface → Implement with data sources

Need to provide dependencies?
├─ Using flutter_bloc → RepositoryProvider
└─ Need more control → get_it

Navigation complexity?
├─ Simple (few screens) → Navigator 1.0 with push/pop
└─ Complex (deep links, web) → Navigator 2.0 with RouterDelegate
```

## Code Quality Checklist
- [ ] Use `const` constructors where possible
- [ ] Extract stateful widgets to minimize rebuilds
- [ ] Use specific MediaQuery accessors
- [ ] Repository interfaces for data access
- [ ] Constructor injection for dependencies
- [ ] Immutable state classes with `copyWith`
- [ ] Equatable for state comparison
- [ ] Check `context.mounted` after async operations
- [ ] Enable strict analysis options
- [ ] Write unit tests for business logic
- [ ] Write widget tests for UI components