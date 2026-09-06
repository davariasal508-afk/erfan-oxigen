import '../models/formula_model.dart';
import 'storage_service.dart';

class FormulaService {
  static final List<FormulaModel> items = [];
  static const _key = 'erfan_oxygen_formulas_v1';

  static Future<void> initialize() async {
    final raw = await StorageService.loadGenericList(_key);
    items
      ..clear()
      ..addAll(raw.map(FormulaModel.fromJson));
  }

  static Future<void> save(FormulaModel formula) async {
    items.insert(0, formula);
    await StorageService.saveGenericList(_key, items.map((e) => e.toJson()).toList());
  }

  static Future<void> remove(String id) async {
    items.removeWhere((e) => e.id == id);
    await StorageService.saveGenericList(_key, items.map((e) => e.toJson()).toList());
  }
}
