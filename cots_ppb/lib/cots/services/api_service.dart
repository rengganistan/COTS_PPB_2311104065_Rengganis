import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../config/api_config.dart';

class ApiService {
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/recipes?select=*&order=created_at.desc'),
        headers: ApiConfig.headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/recipes?select=*&category=eq.$category&order=created_at.desc'),
        headers: ApiConfig.headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Recipe> createRecipe(Map<String, dynamic> recipeData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/recipes'),
        headers: {
          ...ApiConfig.headers,
          'Prefer': 'return=representation',
        },
        body: json.encode(recipeData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return Recipe.fromJson(data.first);
      } else {
        throw Exception('Failed to create recipe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating recipe: $e');
    }
  }

  Future<Recipe> updateRecipe(int id, Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/recipes?id=eq.$id'),
        headers: {
          ...ApiConfig.headers,
          'Prefer': 'return=representation',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return Recipe.fromJson(data.first);
      } else {
        throw Exception('Failed to update recipe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteRecipe(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/recipes?id=eq.$id'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete recipe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
