// =============================================================================
// COUNTER NOTES APP - MVC PATTERN WITH GETX
// =============================================================================
// This file provides an overview of the complete project structure
// and how each component fits into the MVC architecture pattern.
// =============================================================================

/*

📁 PROJECT STRUCTURE
====================

mvc_architeture_pattern/
│
├── 📁 lib/                                    [Application Source Code]
│   │
│   ├── 📄 main.dart                          [App Entry Point]
│   │   • Initializes GetStorage (await GetStorage.init())
│   │   • Initializes GetX app
│   │   • Sets up navigation routes
│   │   • Configures themes
│   │   • Defines transitions
│   │
│   ├── 📁 models/                             [MODEL LAYER - Data]
│   │   │   ⚡ Pure Dart classes
│   │   │   ⚡ No dependencies on Flutter/GetX
│   │   │   ⚡ Contains only data and data operations
│   │   │
│   │   ├── 📄 counter_model.dart             [Counter Data Structure]
│   │   │   • class CounterModel
│   │   │   • int value
│   │   │   • increment(), decrement(), reset()
│   │   │
│   │   └── 📄 note_model.dart                [Note Data Structure]
│   │       • class NoteModel
│   │       • String id, content
│   │       • DateTime createdAt
│   │       • toJson(), fromJson()
│   │
│   ├── 📁 controllers/                        [CONTROLLER LAYER - Logic]
│   │   │   ⚡ Extends GetxController
│   │   │   ⚡ Contains business logic
│   │   │   ⚡ Manages reactive state with .obs
│   │   │   ⚡ Handles data persistence with GetStorage
│   │   │   ⚡ No UI code
│   │   │
│   │   ├── 📄 counter_controller.dart        [Counter Business Logic]
│   │   │   • class CounterController extends GetxController
│   │   │   • Manages counter state
│   │   │   • GetStorage instance for persistence
│   │   │   • Methods: increment(), decrement(), reset()
│   │   │   • _loadCounter() - Loads saved value on init
│   │   │   • _saveCounter() - Saves value to storage
│   │   │   • Shows snackbar notifications
│   │   │   • Updates UI reactively
│   │   │
│   │   ├── 📄 notes_controller.dart          [Notes Business Logic]
│   │   │   • class NotesController extends GetxController
│   │   │   • Manages notes list (CRUD operations)
│   │   │   • GetStorage instance for persistence
│   │   │   • Methods: addNote(), deleteNote(), clearAllNotes()
│   │   │   • _loadNotes() - Loads saved notes from storage (JSON)
│   │   │   • _saveNotes() - Saves notes to storage (JSON)
│   │   │   • Validates input
│   │   │   • Shows dialogs and snackbars
│   │   │
│   │   └── 📄 theme_controller.dart          [Theme Management]
│   │       • class ThemeController extends GetxController
│   │       • Manages light/dark theme
│   │       • Method: toggleTheme()
│   │       • Provides theme data
│   │       • Handles theme switching
│   │
│   └── 📁 views/                              [VIEW LAYER - UI]
│       │   ⚡ StatelessWidget (UI only)
│       │   ⚡ Observes controller state with Obx()
│       │   ⚡ Calls controller methods
│       │   ⚡ No business logic
│       │
│       ├── 📄 counter_view.dart              [Counter Screen UI]
│       │   • class CounterView extends StatelessWidget
│       │   • Displays counter value with Obx()
│       │   • Buttons: Increment, Decrement, Reset
│       │   • Theme toggle button
│       │   • Navigation to Notes screen
│       │   • Card-based layout
│       │
│       └── 📄 notes_view.dart                [Notes Screen UI]
│           • class NotesView extends StatelessWidget
│           • TextField for adding notes
│           • ListView of existing notes
│           • Delete buttons for each note
│           • Clear all button
│           • Empty state display
│           • Notes count display
│
├── 📁 test/                                   [Tests]
│   └── 📄 widget_test.dart                   [Widget Tests]
│       • Tests for Counter Notes App
│       • Verifies initial state
│
├── 📄 pubspec.yaml                            [Dependencies]
│   • get: ^4.6.6 (GetX for state management)
│   • get_storage: ^2.1.1 (Local persistence)
│   • cupertino_icons: ^1.0.8
│
├── 📄 README.md                               [Documentation]
│   • Complete app overview
│   • Features list
│   • Architecture explanation
│   • Getting started guide
│
├── 📄 ARCHITECTURE.md                         [Architecture Guide]
│   • Detailed MVC pattern explanation
│   • Data flow diagrams
│   • Best practices
│   • Code examples
│
└── 📄 QUICK_START.md                          [Quick Start]
    • How to run the app
    • Common commands
    • Troubleshooting
    • Customization ideas


================================================================================
MVC PATTERN FLOW
================================================================================

USER INTERACTION
       │
       ▼
┌──────────────────┐
│   VIEW LAYER     │  • CounterView / NotesView
│   (UI Only)      │  • Displays data with Obx()
│                  │  • Forwards user events to controller
└────────┬─────────┘
         │ Observes & Calls
         ▼
┌──────────────────┐
│ CONTROLLER LAYER │  • CounterController / NotesController
│ (Business Logic) │  • Processes user actions
│                  │  • Manages reactive state (.obs)
│                  │  • Shows notifications
└────────┬─────────┘
         │ Updates
         ▼
┌──────────────────┐
│   MODEL LAYER    │  • CounterModel / NoteModel
│   (Data)         │  • Pure data structures
│                  │  • Data manipulation methods
└──────────────────┘


================================================================================
KEY GETX FEATURES USED
================================================================================

1. REACTIVE STATE MANAGEMENT
   • .obs         → Makes variables observable
   • Obx()        → Widget that auto-rebuilds on state change
   • .refresh()   → Manually trigger UI update

2. DEPENDENCY INJECTION
   • Get.put()    → Initialize and register controller
   • Get.find()   → Retrieve existing controller

3. NAVIGATION
   • Get.toNamed()    → Navigate to route by name
   • Get.back()       → Go back to previous screen
   • GetPage          → Define routes with transitions

4. DIALOGS & SNACKBARS
   • Get.snackbar()      → Show notification
   • Get.defaultDialog() → Show dialog

5. THEME MANAGEMENT
   • Get.changeTheme()  → Switch theme dynamically
   • Get.theme          → Access current theme

6. DATA PERSISTENCE
   • GetStorage        → Local key-value storage
   • .write()          → Save data to storage
   • .read()           → Load data from storage
   • .init()           → Initialize storage (async)


================================================================================
DATA FLOW EXAMPLE: Adding a Note (with Persistence)
================================================================================

1. USER ACTION
   └─ User types "Buy milk" and taps Add button

2. VIEW (notes_view.dart)
   └─ Calls: notesController.addNote("Buy milk")

3. CONTROLLER (notes_controller.dart)
   ├─ Validates input (not empty)
   ├─ Creates new NoteModel with:
   │  • id: timestamp
   │  • content: "Buy milk"
   │  • createdAt: DateTime.now()
   ├─ Adds to _notes observable list
   ├─ Saves to storage: _saveNotes()
   │  └─ Converts notes to JSON
   │  └─ Writes to GetStorage('notes_list')
   └─ Shows Get.snackbar("Success", "Note added")

4. MODEL (note_model.dart)
   └─ NoteModel instance created with data
   └─ toJson() method converts to Map

5. VIEW AUTO-UPDATES
   └─ Obx() detects _notes change
   └─ ListView rebuilds with new note

6. USER SEES RESULT
   └─ New note appears in list
   └─ Success snackbar shows

7. DATA PERSISTS
   └─ Note saved to local storage
   └─ Survives app restart


================================================================================
BEST PRACTICES DEMONSTRATED
================================================================================

✅ DO's:
   • Keep views simple and stateless
   • Put all logic in controllers
   • Use reactive state (.obs) for auto-updates
   • Use GetX dependency injection
   • Show user feedback (snackbars/dialogs)
   • Comment your code
   • Follow consistent naming

❌ DON'Ts:
   • Don't put logic in build() methods
   • Don't use setState() with GetX
   • Don't let views directly modify models
   • Don't create tight coupling between layers
   • Don't ignore validation


================================================================================
FILE RELATIONSHIPS
================================================================================

main.dart
  │
  ├─→ Imports: counter_view, notes_view, theme_controller
  ├─→ Initializes: ThemeController with Get.put()
  └─→ Defines: Routes and transitions

counter_view.dart
  │
  ├─→ Imports: counter_controller, theme_controller
  ├─→ Uses: Get.put(CounterController())
  ├─→ Uses: Get.find<ThemeController>()
  └─→ Observes: counterController.counterValue with Obx()

counter_controller.dart
  │
  ├─→ Imports: counter_model
  ├─→ Uses: CounterModel wrapped in .obs
  └─→ Provides: increment(), decrement(), reset() methods

notes_view.dart
  │
  ├─→ Imports: notes_controller, theme_controller
  ├─→ Uses: Get.put(NotesController())
  └─→ Observes: notesController.notes with Obx()

notes_controller.dart
  │
  ├─→ Imports: note_model
  ├─→ Uses: List<NoteModel> wrapped in .obs
  └─→ Provides: addNote(), deleteNote(), clearAllNotes()


================================================================================
EXTENDING THE APP
================================================================================

To add a new feature (e.g., Todo List):

1. CREATE MODEL (lib/models/todo_model.dart)
   • Define TodoModel class
   • Add data fields (id, title, completed)
   • Add methods (toggle(), toJson())

2. CREATE CONTROLLER (lib/controllers/todo_controller.dart)
   • Extend GetxController
   • Create observable list: _todos.obs
   • Add methods: addTodo(), toggleTodo(), deleteTodo()

3. CREATE VIEW (lib/views/todo_view.dart)
   • Create StatelessWidget
   • Use Get.put(TodoController())
   • Display todos with Obx(() => ListView(...))
   • Add buttons calling controller methods

4. UPDATE MAIN (lib/main.dart)
   • Add new route in GetPage array
   • Add navigation button in existing views


================================================================================
TESTING APPROACH
================================================================================

UNIT TESTS (Controllers):
  • Test increment() increases counter
  • Test addNote() adds to list
  • Test validation logic

WIDGET TESTS (Views):
  • Test UI displays correct data
  • Test buttons trigger correct methods
  • Test navigation works

INTEGRATION TESTS:
  • Test complete user flows
  • Test counter increment flow
  • Test add/delete note flow


================================================================================
SUMMARY
================================================================================

This Counter Notes App demonstrates:
  ✓ Clean MVC architecture
  ✓ GetX state management
  ✓ Reactive programming
  ✓ Dependency injection
  ✓ Clean code practices
  ✓ Separation of concerns
  ✓ Scalable structure

Perfect for learning Flutter architecture patterns! 🚀

*/
