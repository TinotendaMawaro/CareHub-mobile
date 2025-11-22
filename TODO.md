# TODO: Display Shifts and Clients Info from Firestore in ParentDashboard

## Tasks
- [x] Update `lib/models/shift_model.dart` to handle inconsistent date/time formats in `fromFirestore` method (combine date + time if separate, parse strings if needed).
- [x] Add `getAllShifts` method in `lib/services/shift_service.dart` to fetch all shifts from Firestore.
- [x] Update `lib/screens/parent_dashboard.dart` to add "Clients" and "Shifts" tabs in the BottomNavigationBar.
- [x] Implement `_buildClientList` method in ParentDashboard to display list of clients from Firestore.
- [x] Implement `_buildShiftList` method in ParentDashboard to display list of shifts with caregiverId, clientId, date, startTime, endTime, notes, status.
- [x] Test the new tabs to ensure shifts and clients info is displayed correctly from Firestore.
- [x] Handle any data inconsistencies (e.g., notes as list vs string) in the model or display logic.
- [x] Add `getAllClients` method in `lib/services/client_service.dart` to fetch all clients from Firestore.
- [x] Update models to handle timestamp parsing for different formats.
