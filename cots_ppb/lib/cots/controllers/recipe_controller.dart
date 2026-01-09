import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';

class RecipeController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _recipes = await _apiService.getAllRecipes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> loadRecipesByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      if (category == 'Semua') {
        _recipes = await _apiService.getAllRecipes();
      } else {
        _recipes = await _apiService.getRecipesByCategory(category);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<bool> createRecipe(Map<String, dynamic> recipeData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.createRecipe(recipeData);
      await loadRecipes();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateRecipe(int id, Map<String, dynamic> updates) async {
    try {
      await _apiService.updateRecipe(id, updates);
      
      final index = _recipes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _recipes[index] = _recipes[index].copyWith(
          note: updates['note'],
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteRecipe(int id) async {
    try {
      await _apiService.deleteRecipe(id);
      _recipes.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  int get totalRecipes => _recipes.length;
  
  int getCategoryCount(String category) {
    return _recipes.where((r) => r.category == category).length;
  }
  
  List<Recipe> getRecentRecipes({int limit = 5}) {
    // Data sudah sorted dari API (newest first)
    return _recipes.take(limit).toList();
  }
}
