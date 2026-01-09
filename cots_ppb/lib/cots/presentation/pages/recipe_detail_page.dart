import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../models/recipe_model.dart';
import '../../controllers/recipe_controller.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late TextEditingController _noteController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.recipe.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (widget.recipe.id == null) return;

    final controller = context.read<RecipeController>();
    final success = await controller.updateRecipe(
      widget.recipe.id!,
      {'note': _noteController.text},
    );

    if (success) {
      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan berhasil diperbarui'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui catatan'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
          onPressed: () => Navigator.pop(context, true),
        ),
        centerTitle: true,
        title: Text('Detail Resep', style: AppTypography.title),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                setState(() {
                  isEditing = !isEditing;
                });
              },
              child: Text(
                'Edit',
                style: AppTypography.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
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
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.standard),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textSecondary.withOpacity(0.08),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.recipe.title,
                          style: AppTypography.title.copyWith(fontSize: 22),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        
                        // Category
                        Text(
                          'Kategori: ${widget.recipe.category}',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),
                        
                        // Ingredients Section
                        Text(
                          'Bahan-bahan',
                          style: AppTypography.section.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _buildIngredientsList(widget.recipe.ingredients),
                        SizedBox(height: AppSpacing.xl),
                        
                        // Steps Section
                        Text(
                          'Langkah-langkah',
                          style: AppTypography.section.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _buildStepsList(widget.recipe.steps),
                        SizedBox(height: AppSpacing.xl),
                        
                        // Notes Section
                        Text(
                          'Catatan',
                          style: AppTypography.section.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        
                        isEditing
                            ? TextFormField(
                                controller: _noteController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Tambahkan catatan...',
                                  hintStyle: AppTypography.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.standard),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.all(AppSpacing.md),
                                ),
                                style: AppTypography.body.copyWith(height: 1.5),
                              )
                            : Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(AppRadius.standard),
                                ),
                                child: Text(
                                  widget.recipe.note?.isEmpty ?? true
                                      ? 'Tambahkan kerupuk untuk pelengkap.'
                                      : widget.recipe.note!,
                                  style: AppTypography.body.copyWith(
                                    height: 1.6,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Fixed Bottom Button
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
                child: isEditing
                    ? Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: AppSize.buttonHeight,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _noteController.text = widget.recipe.note ?? '';
                                    isEditing = false;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.standard),
                                  ),
                                ),
                                child: Text(
                                  'Batal',
                                  style: AppTypography.button.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: SizedBox(
                              height: AppSize.buttonHeight,
                              child: ElevatedButton(
                                onPressed: _saveNote,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.standard),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text('Simpan', style: AppTypography.button),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: AppSize.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Simpan ke Favorit (future feature)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fitur Favorit akan segera hadir!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.standard),
                            ),
                            elevation: 0,
                          ),
                          child: Text('Simpan ke Favorit', style: AppTypography.button),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsList(String ingredients) {
    final items = ingredients.split('\n').where((item) => item.trim().isNotEmpty).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(
            item.trim(),
            style: AppTypography.body.copyWith(
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepsList(String steps) {
    final items = steps.split('\n').where((item) => item.trim().isNotEmpty).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(
            item.trim(),
            style: AppTypography.body.copyWith(
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
