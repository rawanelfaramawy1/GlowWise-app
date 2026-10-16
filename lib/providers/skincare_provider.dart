import 'package:flutter/material.dart';
import '../models/skincare_routine.dart';

class SkincareProvider extends ChangeNotifier {
  final List<SkincareProduct> _products = [];
  final List<SkincareRoutine> _routines = [];
  final List<SkincareDailyLog> _dailyLogs = [];
  final List<SkincareAppointment> _appointments = [];

  // Getters
  List<SkincareProduct> get products => List.unmodifiable(_products);
  List<SkincareRoutine> get routines => List.unmodifiable(_routines);
  List<SkincareDailyLog> get dailyLogs => List.unmodifiable(_dailyLogs);
  List<SkincareAppointment> get appointments =>
      List.unmodifiable(_appointments);

  // Product Management
  void addProduct(SkincareProduct product) {
    _products.add(product);
    notifyListeners();
  }

  void removeProduct(SkincareProduct product) {
    _products.remove(product);
    notifyListeners();
  }

  // Routine Management
  void addRoutine(SkincareRoutine routine) {
    _routines.add(routine);
    notifyListeners();
  }

  void removeRoutine(SkincareRoutine routine) {
    _routines.remove(routine);
    notifyListeners();
  }

  void toggleRoutineCompletion(SkincareRoutine routine) {
    final index = _routines.indexOf(routine);
    if (index != -1) {
      _routines[index] = SkincareRoutine(
        name: routine.name,
        time: routine.time,
        products: routine.products,
        isCompleted: !routine.isCompleted,
        notes: routine.notes,
      );
      notifyListeners();
    }
  }

  // Daily Log Management
  void addDailyLog(SkincareDailyLog log) {
    _dailyLogs.add(log);
    notifyListeners();
  }

  void updateDailyLog(SkincareDailyLog oldLog, SkincareDailyLog newLog) {
    final index = _dailyLogs.indexOf(oldLog);
    if (index != -1) {
      _dailyLogs[index] = newLog;
      notifyListeners();
    }
  }

  // Appointment Management
  void addAppointment(SkincareAppointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  void removeAppointment(SkincareAppointment appointment) {
    _appointments.remove(appointment);
    notifyListeners();
  }

  // Utility Methods
  List<SkincareRoutine> getRoutinesForDay(DateTime date) {
    return _routines.where((routine) {
      final log = _dailyLogs.firstWhere(
        (log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day,
        orElse:
            () => SkincareDailyLog(
              date: date,
              skinCondition: '',
              notes: '',
              completedRoutines: [],
            ),
      );
      return !log.completedRoutines.contains(routine);
    }).toList();
  }

  List<SkincareAppointment> getAppointmentsForDay(DateTime date) {
    return _appointments
        .where(
          (appointment) =>
              appointment.dateTime.year == date.year &&
              appointment.dateTime.month == date.month &&
              appointment.dateTime.day == date.day,
        )
        .toList();
  }

  List<SkincareProduct> getExpiringProducts(int daysThreshold) {
    final now = DateTime.now();
    return _products.where((product) {
      final daysUntilExpiration = product.expirationDate.difference(now).inDays;
      return daysUntilExpiration <= daysThreshold && daysUntilExpiration >= 0;
    }).toList();
  }
}
