import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

enum AppStatus { idle, loading, success, error }

class AppState extends ChangeNotifier {
  // ── Form state ──
  String businessType = 'Cafe';
  List<String> selectedDemographics = [];
  int budgetRange = 200000;

  // ── Result state ──
  AppStatus status = AppStatus.idle;
  AnalyzeResponse? response;
  String? errorMessage;
  int selectedLocationIndex = 0;

  // ── Available options (matching new backend business types) ──
  static const List<String> businessTypes = [
    'Cafe',
    'Restaurant',
    'Retail Store',
    'Supermarket',
    'Salon & Beauty',
    'Hotel / Hospitality',
    'Souvenir / Gift Shop',
    'Gym / Fitness Centre',
    'Pharmacy',
    'Tech Office',
    'Medical Clinic',
    'Educational Institute',
  ];

  static const List<String> demographics = [
    'Students',
    'Working Professionals',
    'Families',
    'Senior Citizens',
    'Tourists',
  ];

  void setBusinessType(String value) {
    businessType = value;
    notifyListeners();
  }

  void toggleDemographic(String demo) {
    if (selectedDemographics.contains(demo)) {
      selectedDemographics.remove(demo);
    } else {
      selectedDemographics.add(demo);
    }
    notifyListeners();
  }

  void setBudgetRange(int value) {
    budgetRange = value;
    notifyListeners();
  }

  void selectLocation(int index) {
    selectedLocationIndex = index;
    notifyListeners();
  }

  /// Top 5 results.
  List<ScoredArea> get topResults {
    if (response == null) return [];
    final all = response!.results;
    return all.length > 5 ? all.sublist(0, 5) : all;
  }

  Future<void> analyzeLocations() async {
    if (selectedDemographics.isEmpty) {
      errorMessage = 'Please select at least one target demographic.';
      status = AppStatus.error;
      notifyListeners();
      return;
    }

    status = AppStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final request = AnalyzeRequest(
        businessType: businessType,
        targetDemographic: selectedDemographics,
        budgetRange: budgetRange,
      );

      response = await ApiService.analyze(request);
      status = AppStatus.success;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = AppStatus.error;
    } catch (e) {
      errorMessage = 'An unexpected error occurred:\n$e';
      status = AppStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    status = AppStatus.idle;
    response = null;
    errorMessage = null;
    selectedLocationIndex = 0;
    notifyListeners();
  }
}
