import 'package:flutter/material.dart';
import '../../data/datasources/transport_location_remote_datasource.dart';
import '../../data/models/transport_location_model.dart';
import '../../core/error/exceptions.dart';

class TransportLocationProvider extends ChangeNotifier {
  final TransportLocationRemoteDataSource remoteDataSource;

  List<TransportLocationModel> _locations = [];
  bool _isLoading = false;
  String? _error;

  TransportLocationProvider({required this.remoteDataSource});

  List<TransportLocationModel> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get all transport locations for a lounge
  Future<void> loadTransportLocations(String loungeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _locations = await remoteDataSource.getTransportLocations(loungeId);
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new transport location
  Future<bool> addTransportLocation({
    required String loungeId,
    required String locationName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newLocation = await remoteDataSource.addTransportLocation(
        loungeId: loungeId,
        locationName: locationName,
      );

      _locations.add(newLocation);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update a transport location
  Future<bool> updateTransportLocation({
    required String loungeId,
    required String locationId,
    required String locationName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedLocation = await remoteDataSource.updateTransportLocation(
        loungeId: loungeId,
        locationId: locationId,
        locationName: locationName,
      );

      final index = _locations.indexWhere((loc) => loc.id == locationId);
      if (index != -1) {
        _locations[index] = updatedLocation;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a transport location
  Future<bool> deleteTransportLocation({
    required String loungeId,
    required String locationId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await remoteDataSource.deleteTransportLocation(
        loungeId: loungeId,
        locationId: locationId,
      );

      _locations.removeWhere((loc) => loc.id == locationId);

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get prices for a location
  Future<Map<String, double>?> getLocationPrices({
    required String loungeId,
    required String locationId,
  }) async {
    try {
      return await remoteDataSource.getLocationPrices(
        loungeId: loungeId,
        locationId: locationId,
      );
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      notifyListeners();
      return null;
    }
  }

  /// Set prices for a location
  Future<bool> setLocationPrices({
    required String loungeId,
    required String locationId,
    required Map<String, double> prices,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await remoteDataSource.setLocationPrices(
        loungeId: loungeId,
        locationId: locationId,
        prices: prices,
      );

      // Update local cache
      final index = _locations.indexWhere((loc) => loc.id == locationId);
      if (index != -1) {
        _locations[index] = TransportLocationModel(
          id: _locations[index].id,
          loungeId: _locations[index].loungeId,
          locationName: _locations[index].locationName,
          isActive: _locations[index].isActive,
          createdAt: _locations[index].createdAt,
          updatedAt: DateTime.now(),
          prices: prices,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
