import 'package:flutter/material.dart';
import '../../domain/entities/lounge.dart';
import '../../domain/usecases/get_all_lounges.dart';

class RoleSelectionProvider extends ChangeNotifier {
  final GetAllLounges getAllLoungesUseCase;

  RoleSelectionProvider({required this.getAllLoungesUseCase});

  bool _isLoading = false;
  String? _error;
  List<Lounge> _lounges = [];
  Lounge? _selectedLounge;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Lounge> get lounges => _lounges;
  Lounge? get selectedLounge => _selectedLounge;

  /// Fetch all registered lounges for staff member selection
  Future<void> fetchAllLounges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getAllLoungesUseCase();

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (lounges) {
        _lounges = lounges;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Set the selected lounge for staff member registration
  void selectLounge(Lounge? lounge) {
    _selectedLounge = lounge;
    notifyListeners();
  }

  /// Reset the provider state
  void reset() {
    _isLoading = false;
    _error = null;
    _lounges = [];
    _selectedLounge = null;
    notifyListeners();
  }
}
