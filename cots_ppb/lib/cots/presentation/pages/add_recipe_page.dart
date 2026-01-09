import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../controllers/recipe_controller.dart';

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  String? selectedCategory;
  bool isSubmitting = false;
  
  final List<String> categories = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Dessert',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final recipeData = {
        'title': _titleController.text,
        'category': selectedCategory,
        'ingredients': _ingredientsController.text,
        'steps': _stepsController.text,
        'note': _noteController.text.isEmpty ? null : _noteController.text,
      };

      final controller = context.read<RecipeController>();
      final success = await controller.createRecipe(recipeData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resep berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Gagal menambahkan resep');
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Tambah Resep', style: AppTypography.title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
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
                            'Judul Resep',
                            style: AppTypography.section.copyWith(fontSize: 15),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _titleController,
                            enabled: !isSubmitting,
                            decoration: InputDecoration(
                              hintText: 'Judul Resep',
                              hintStyle: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              helperText: 'Judul resep wajib diisi',
                              helperStyle: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.standard),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: 14,
                              ),
                            ),
                            style: AppTypography.body,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Judul resep wajib diisi';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          
                          // Category Dropdown
                          Text(
                            'Kategori',
                            style: AppTypography.section.copyWith(fontSize: 15),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.standard),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: 14,
                              ),
                            ),
                            hint: Text(
                              'Pilih kategori',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textSecondary,
                            ),
                            isExpanded: true,
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: AppTypography.body,
                                ),
                              );
                            }).toList(),
                            onChanged: isSubmitting
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      selectedCategory = newValue;
                                    });
                                  },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih kategori terlebih dahulu';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          
                          // Ingredients
                          Text(
                            'Bahan-bahan',
                            style: AppTypography.section.copyWith(fontSize: 15),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _ingredientsController,
                            maxLines: 4,
                            enabled: !isSubmitting,
                            decoration: InputDecoration(
                              hintText: 'Masukkan bahan, pisahkan dengan koma',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bahan-bahan wajib diisi';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          
                          // Steps
                          Text(
                            'Langkah-langkah',
                            style: AppTypography.section.copyWith(fontSize: 15),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _stepsController,
                            maxLines: 4,
                            enabled: !isSubmitting,
                            decoration: InputDecoration(
                              hintText: 'Masukkan langkah, pisahkan dengan koma',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Langkah-langkah wajib diisi';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          
                          // Note
                          Text(
                            'Catatan',
                            style: AppTypography.section.copyWith(fontSize: 15),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            enabled: !isSubmitting,
                            decoration: InputDecoration(
                              hintText: 'Catatan tambahan (opsional)',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Buttons
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
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: AppSize.buttonHeight,
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : () => Navigator.pop(context),
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
                          onPressed: isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.standard),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.surface,
                                  ),
                                )
                              : Text('Simpan', style: AppTypography.button),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
