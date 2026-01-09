import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../controllers/recipe_controller.dart';
import 'recipe_list_page.dart';
import 'add_recipe_page.dart';
import 'recipe_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeController>().loadRecipes();
    });
  }

  // Tambahkan ini untuk auto-refresh saat kembali ke page
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali page muncul
    context.read<RecipeController>().loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: Consumer<RecipeController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading && controller.recipes.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (controller.errorMessage != null && controller.recipes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Text(
                              'Gagal memuat data',
                              style: AppTypography.section,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                              child: Text(
                                controller.errorMessage!,
                                style: AppTypography.caption,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xl),
                            ElevatedButton(
                              onPressed: () => controller.loadRecipes(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await controller.loadRecipes();
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: AppSpacing.xl),
                            
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Resep Masakan', style: AppTypography.title),
                                InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecipeListPage(),
                                      ),
                                    );
                                    // Refresh setelah kembali dari daftar resep
                                    controller.loadRecipes();
                                  },
                                  child: Text(
                                    'Daftar Resep',
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.lg),
                            
                            // Stats Cards Grid (2x2)
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCardCompact(
                                    label: 'Total Resep',
                                    value: controller.totalRecipes.toString(),
                                  ),
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _StatCardCompact(
                                    label: 'Sarapan',
                                    value: controller.getCategoryCount('Sarapan').toString(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCardCompact(
                                    label: 'Makan Siang & Malam',
                                    value: (controller.getCategoryCount('Makan Siang') + 
                                            controller.getCategoryCount('Makan Malam')).toString(),
                                  ),
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _StatCardCompact(
                                    label: 'Dessert',
                                    value: controller.getCategoryCount('Dessert').toString(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.xl),
                            
                            // Recent Recipes
                            Text('Resep Terbaru', style: AppTypography.title),
                            SizedBox(height: AppSpacing.lg),
                            
                            controller.recipes.isEmpty
                                ? Container(
                                    padding: EdgeInsets.all(AppSpacing.xl),
                                    child: Center(
                                      child: Text(
                                        'Belum ada resep',
                                        style: AppTypography.body.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: controller.getRecentRecipes(limit: 3).length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: AppSpacing.md),
                                    itemBuilder: (context, index) {
                                      final recipe = controller.getRecentRecipes(limit: 3)[index];
                                      return _RecipeCardWithImage(
                                        title: recipe.title,
                                        category: recipe.category,
                                        duration: '${20 + (index * 10)} Menit',
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
                                  ),
                            SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Fixed Button
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: AppSize.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRecipePage(),
                        ),
                      );
                      
                      // Reload data setelah tambah resep
                      if (result == true) {
                        context.read<RecipeController>().loadRecipes();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.standard),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Tambah Resep Baru', style: AppTypography.button),
                  ),
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

// Widget classes tetap sama...
class _StatCardCompact extends StatelessWidget {
  final String label;
  final String value;

  const _StatCardCompact({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.standard),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

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
