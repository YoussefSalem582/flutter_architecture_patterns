# Quick Start Guide - Clean Architecture Counter Notes App

## 🚀 5-Minute Setup

### Step 1: Prerequisites Check
```bash
# Verify Flutter installation
flutter doctor

# Expected: Flutter SDK >=3.9.2
```

### Step 2: Install Dependencies
```bash
cd clean_architeture_pattern
flutter pub get
```

### Step 3: Run the App
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

---

## 📱 Using the App

### Home Screen
- **Counter Card**: Navigate to counter feature
- **Notes Card**: Navigate to notes feature

### Counter Feature
1. **Increment**: Tap the `+` button
2. **Decrement**: Tap the `-` button  
3. **Reset**: Tap the `Reset to 0` button
4. **Persistence**: Close and reopen the app - counter value is saved!

### Notes Feature
1. **Add Note**: 
   - Tap the floating action button (`+`)
   - Enter note content in the dialog
   - Tap "Add"
2. **Delete Note**: Tap the delete icon on any note
3. **Delete All**: Tap the trash icon in the app bar
4. **Persistence**: Notes are automatically saved

---

## 🔧 Development Workflow

### Adding a New Feature

**1. Create Feature Folder Structure**
```
lib/features/new_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bindings/
    ├── controllers/
    └── views/
```

**2. Domain Layer (Start Here)**
```dart
// 1. Create Entity
class MyEntity extends Equatable {
  final String id;
  final String name;
  
  const MyEntity({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}

// 2. Create Repository Interface
abstract class MyRepository {
  Future<Either<Failure, MyEntity>> getEntity();
  Future<Either<Failure, void>> saveEntity(MyEntity entity);
}

// 3. Create Use Case
class GetEntity extends UseCase<MyEntity, NoParams> {
  final MyRepository repository;
  GetEntity(this.repository);
  
  @override
  Future<Either<Failure, MyEntity>> call(NoParams params) {
    return repository.getEntity();
  }
}
```

**3. Data Layer**
```dart
// 1. Create Model
class MyModel extends MyEntity {
  const MyModel({required super.id, required super.name});
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// 2. Create Data Source
class MyLocalDataSource {
  final GetStorage storage;
  MyLocalDataSource(this.storage);
  
  Future<MyModel> getEntity() async {
    final data = storage.read('my_entity');
    return MyModel.fromJson(data);
  }
}

// 3. Implement Repository
class MyRepositoryImpl implements MyRepository {
  final MyLocalDataSource dataSource;
  MyRepositoryImpl(this.dataSource);
  
  @override
  Future<Either<Failure, MyEntity>> getEntity() async {
    try {
      final model = await dataSource.getEntity();
      return Right(model);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
}
```

**4. Presentation Layer**
```dart
// 1. Create Controller
class MyController extends GetxController {
  final GetEntity getEntityUseCase;
  MyController({required this.getEntityUseCase});
  
  final entity = Rx<MyEntity?>(null);
  
  @override
  void onInit() {
    super.onInit();
    loadEntity();
  }
  
  Future<void> loadEntity() async {
    final result = await getEntityUseCase(NoParams());
    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (data) => entity.value = data,
    );
  }
}

// 2. Create View
class MyView extends StatelessWidget {
  const MyView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyController>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: Obx(() {
        final data = controller.entity.value;
        if (data == null) return const CircularProgressIndicator();
        return Text(data.name);
      }),
    );
  }
}

// 3. Create Binding
class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyLocalDataSource(Get.find()));
    Get.lazyPut<MyRepository>(() => MyRepositoryImpl(Get.find()));
    Get.lazyPut(() => GetEntity(Get.find()));
    Get.lazyPut(() => MyController(getEntityUseCase: Get.find()));
  }
}
```

**5. Register Route**
```dart
// In lib/core/routes/app_routes.dart
static const myFeature = '/my-feature';

// In lib/core/routes/app_pages.dart
GetPage(
  name: AppRoutes.myFeature,
  page: () => const MyView(),
  binding: MyBinding(),
),
```

---

## 🧪 Testing

### Unit Test a Use Case
```dart
// test/features/my_feature/domain/usecases/get_entity_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMyRepository extends Mock implements MyRepository {}

void main() {
  late GetEntity useCase;
  late MockMyRepository mockRepository;

  setUp(() {
    mockRepository = MockMyRepository();
    useCase = GetEntity(mockRepository);
  });

  test('should return entity from repository', () async {
    // Arrange
    final testEntity = MyEntity(id: '1', name: 'Test');
    when(() => mockRepository.getEntity())
        .thenAnswer((_) async => Right(testEntity));

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, Right(testEntity));
    verify(() => mockRepository.getEntity()).called(1);
  });
}
```

### Widget Test a View
```dart
// test/features/my_feature/presentation/views/my_view_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('should display entity name', (tester) async {
    // Arrange
    final controller = MyController(getEntityUseCase: mockUseCase);
    Get.put(controller);
    controller.entity.value = MyEntity(id: '1', name: 'Test Entity');

    // Act
    await tester.pumpWidget(GetMaterialApp(home: MyView()));

    // Assert
    expect(find.text('Test Entity'), findsOneWidget);
  });
}
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "GetX Controller not found"
**Solution**: Make sure the binding is registered in the route
```dart
GetPage(
  name: AppRoutes.myFeature,
  page: () => const MyView(),
  binding: MyBinding(),  // ← Don't forget this!
),
```

### Issue 2: "Obx not updating"
**Solution**: Use `.obs` for reactive variables
```dart
// ❌ Wrong
final counter = 0;

// ✅ Correct
final counter = 0.obs;
counter.value++;  // Triggers rebuild
```

### Issue 3: "Storage exception"
**Solution**: Initialize GetStorage before runApp
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();  // ← Essential
  runApp(const MyApp());
}
```

### Issue 4: "Import errors"
**Solution**: Check relative paths carefully
```dart
// From presentation layer
import '../../domain/entities/my_entity.dart';  // ✅ Domain
import '../../data/models/my_model.dart';       // ❌ Don't import Data!
```

### Issue 5: "Type mismatch in Either"
**Solution**: Ensure correct generic types
```dart
// ❌ Wrong
Future<Either<Failure, void>> saveEntity() {
  return Right(null);  // Type error!
}

// ✅ Correct
Future<Either<Failure, void>> saveEntity() async {
  await dataSource.save();
  return const Right(null);
}
```

---

## 📚 Code Snippets

### Create a NoParams Use Case
```dart
class MyUseCase extends UseCase<ReturnType, NoParams> {
  final MyRepository repository;
  MyUseCase(this.repository);
  
  @override
  Future<Either<Failure, ReturnType>> call(NoParams params) async {
    return await repository.doSomething();
  }
}
```

### Create a Parameterized Use Case
```dart
class MyParams extends Equatable {
  final String id;
  const MyParams(this.id);
  
  @override
  List<Object?> get props => [id];
}

class MyUseCase extends UseCase<ReturnType, MyParams> {
  final MyRepository repository;
  MyUseCase(this.repository);
  
  @override
  Future<Either<Failure, ReturnType>> call(MyParams params) async {
    return await repository.doSomething(params.id);
  }
}
```

### Handle Loading State
```dart
class MyController extends GetxController {
  final isLoading = false.obs;
  
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final result = await useCase(NoParams());
      result.fold(
        (failure) => _handleError(failure),
        (data) => _handleSuccess(data),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// In view
Obx(() {
  if (controller.isLoading.value) {
    return const CircularProgressIndicator();
  }
  return YourContent();
})
```

### Navigation with GetX
```dart
// Navigate to new route
Get.toNamed(AppRoutes.myFeature);

// Navigate with arguments
Get.toNamed(AppRoutes.myFeature, arguments: {'id': '123'});

// Receive arguments
class MyController extends GetxController {
  late String id;
  
  @override
  void onInit() {
    super.onInit();
    id = Get.arguments['id'] as String;
  }
}

// Go back
Get.back();

// Go back with result
Get.back(result: myData);
```

---

## 🎯 Best Practices Checklist

### Domain Layer
- [ ] Entities are immutable (final fields)
- [ ] Entities extend Equatable
- [ ] Repository interfaces are abstract
- [ ] Use cases have single responsibility
- [ ] No Flutter/package dependencies (except Dartz, Equatable)

### Data Layer
- [ ] Models extend entities
- [ ] Models have fromJson/toJson methods
- [ ] Data sources throw exceptions
- [ ] Repositories catch exceptions and return Either
- [ ] Models convert to entities

### Presentation Layer
- [ ] Controllers extend GetxController
- [ ] State variables use .obs
- [ ] Views are StatelessWidget
- [ ] Reactive widgets wrapped in Obx()
- [ ] Bindings register all dependencies

### General
- [ ] Each layer only imports from Domain
- [ ] Use cases called from controllers (not repositories)
- [ ] Error handling uses Either pattern
- [ ] Constants defined in separate files
- [ ] Code formatted with `dart format`

---

## 🚀 Next Steps

1. **Explore the Code**: Start with `main.dart`, then explore features
2. **Run Tests**: `flutter test` to see test examples
3. **Add a Feature**: Follow the workflow above
4. **Read ARCHITECTURE.md**: Deep dive into architecture details
5. **Customize**: Change theme, add more features, experiment!

---

## 📞 Getting Help

- **Architecture Questions**: See `ARCHITECTURE.md`
- **GetX Questions**: [GetX Documentation](https://pub.dev/packages/get)
- **Flutter Questions**: [Flutter Docs](https://docs.flutter.dev/)

---

**Happy Coding! 🎉**
