import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../controllers/recipe_controller.dart';
import 'recipe_detail_page.dart';
import 'add_recipe_page.dart';

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  String selectedCategory = 'Semua';
  TextEditingController _searchController = TextEditingController();
  
  final List<String> categories = [
    'Semua',
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Dessert',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Daftar Resep', style: AppTypography.title),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecipePage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tambah',
                    style: AppTypography.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.surface,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Search Bar
              Container(
                color: AppColors.surface,
                padding: EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari resep atau bahan...',
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 12,
                    ),
                  ),
                  style: AppTypography.body,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              
              // Category Filter
              Container(
                width: double.infinity,
                color: AppColors.surface,
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                              _searchController.clear();
                            });
                            context.read<RecipeController>().loadRecipesByCategory(category);
                          },
                          backgroundColor: AppColors.background,
                          selectedColor: AppColors.primary,
                          labelStyle: AppTypography.body.copyWith(
                            color: isSelected ? AppColors.surface : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: 8,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // Recipe List
              Expanded(
                child: Consumer<RecipeController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    // Filter berdasarkan search
                    final filteredRecipes = _searchController.text.isEmpty
                        ? controller.recipes
                        : controller.recipes.where((recipe) {
                            final searchLower = _searchController.text.toLowerCase();
                            return recipe.title.toLowerCase().contains(searchLower) ||
                                   recipe.ingredients.toLowerCase().contains(searchLower);
                          }).toList();

                    if (filteredRecipes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Belum ada resep'
                                  : 'Resep tidak ditemukan',
                              style: AppTypography.section,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Tambahkan resep pertama Anda'
                                  : 'Coba kata kunci lain',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      itemCount: filteredRecipes.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        return _RecipeCardWithImage(
                          title: recipe.title,
                          category: recipe.category,
                          duration: '${20 + (index * 5)} Menit',
                          imageUrl: _getImageByCategory(recipe.category),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailPage(recipe: recipe),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getImageByCategory(String category) {
    switch (category) {
      case 'Sarapan':
        return 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=200';
      case 'Makan Siang':
        return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200';
      case 'Makan Malam':
        return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200';
      case 'Dessert':
        return 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=200';
      default:
        return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200';
    }
  }
}

// Widget untuk Recipe Card dengan Image
class _RecipeCardWithImage extends StatelessWidget {
  final String title;
  final String category;
  final String duration;
  final String imageUrl;
  final VoidCallback onTap;

  const _RecipeCardWithImage({
    Key? key,
    required this.title,
    required this.category,
    required this.duration,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: _getCategoryColor(category),
                      size: 32,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12),
            
            // Recipe Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.section.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    category,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    duration,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Sarapan':
        return AppColors.warning;
      case 'Makan Siang':
        return AppColors.success;
      case 'Makan Malam':
        return AppColors.primary;
      case 'Dessert':
        return Color(0xFFEC4899);
      default:
        return AppColors.primary;
    }
  }
}
