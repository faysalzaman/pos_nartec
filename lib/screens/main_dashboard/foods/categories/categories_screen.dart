// ignore_for_file: deprecated_member_use

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pos/cubit/category/category_cubit.dart';
import 'package:pos/cubit/category/category_state.dart';
import 'package:pos/model/category/category_model.dart';
import 'package:pos/utils/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  CategoryModel? categories;
  CategoryModel? filteredCategories;

  TextEditingController searchController = TextEditingController();

  // Pagination
  int _currentPage = 1;
  final int _rowsPerPage = 10;

  List<Category> allCategories = [];

  final TextEditingController _categoryNameController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _showFormPanel = false;
  bool _isEditing = false;
  Category? _editingCategory;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() {
    context.read<CategoryCubit>().getCategories(
          page: _currentPage,
          limit: _rowsPerPage,
        );
  }

  void _deleteCategory(String id) {
    context.read<CategoryCubit>().deleteCategory(id);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showCategoryForm({Category? category}) {
    setState(() {
      _showFormPanel = true;
      _isEditing = category != null;
      _editingCategory = category;
      if (category != null) {
        _categoryNameController.text = category.name;
        _existingImageUrl = category.image;
        _selectedImage = null;
      } else {
        _categoryNameController.clear();
        _existingImageUrl = null;
        _selectedImage = null;
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _categoryNameController.dispose();
    _selectedImage = null;
    _existingImageUrl = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategorySuccess) {
            setState(() {
              if (_currentPage == 1) {
                allCategories = state.response.categories;
                categories = state.response;
                filteredCategories = state.response;
              } else {
                allCategories.addAll(state.response.categories);
                categories = state.response;
                filteredCategories = state.response;
              }
            });
          } else if (state is CategoryDeleteSuccess) {
            _fetchCategories();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Success!',
                  message: 'Category deleted successfully',
                  contentType: ContentType.success,
                ),
              ),
            );
          } else if (state is CategoryDeleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error!',
                  message: state.message,
                  contentType: ContentType.failure,
                ),
              ),
            );
          } else if (state is CreateCategorySuccess) {
            setState(() {
              _showFormPanel = false;
              _isEditing = false;
              _categoryNameController.clear();
              _selectedImage = null;
            });
            // Refresh the categories list
            _currentPage = 1; // Reset to first page
            _fetchCategories();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Success!',
                  message: 'Category added successfully',
                  contentType: ContentType.success,
                ),
              ),
            );
          } else if (state is CreateCategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is UpdateCategorySuccess) {
            setState(() {
              _showFormPanel = false;
              _isEditing = false;
              _categoryNameController.clear();
              _selectedImage = null;
            });
            // Refresh the categories list
            _fetchCategories();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Success!',
                  message: 'Category updated successfully',
                  contentType: ContentType.success,
                ),
              ),
            );
          } else if (state is UpdateCategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const SpinKitFadingCircle(
              color: AppColors.primary,
              size: 24.0,
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _currentPage = 1; // Reset to first page
                  });
                  _fetchCategories();
                },
                child: Column(
                  children: [
                    // Add New Category and Search Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  // Reset to original orders when search is cleared
                                  setState(() {
                                    filteredCategories = categories;
                                  });
                                } else {
                                  // Search by order no
                                  var filtered = categories?.categories
                                          .where((category) => category.name
                                              .toString()
                                              .toLowerCase()
                                              .contains(value.toLowerCase()))
                                          .toList() ??
                                      [];
                                  setState(() {
                                    filteredCategories = CategoryModel(
                                      categories: filtered,
                                      totalPages: categories?.totalPages ?? 0,
                                      currentPage:
                                          categories?.currentPage ?? '',
                                    );
                                  });
                                }
                              },
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _showCategoryForm,
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Category'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF0B4C59), // Dark teal color
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            showCheckboxColumn: false,
                            headingRowColor:
                                WidgetStateProperty.all(AppColors.primary),
                            dataRowHeight: 80,
                            headingTextStyle:
                                const TextStyle(color: Colors.white),
                            columns: const [
                              DataColumn(label: Text('Image')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Category Id')),
                              DataColumn(label: Text('Created At')),
                              DataColumn(label: Text('Updated At')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: filteredCategories?.categories
                                    .map(
                                      (category) => DataRow(
                                        onSelectChanged: (_) {},
                                        cells: [
                                          DataCell(
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                category.image,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        color:
                                                            AppColors.primary,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(category.name),
                                          ),
                                          DataCell(
                                              Text(category.id.toString())),
                                          DataCell(Text(
                                              category.createdAt.toString())),
                                          DataCell(Text(
                                              category.updatedAt.toString())),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: AppColors.primary),
                                                  onPressed: () =>
                                                      _showCategoryForm(
                                                          category: category),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    _deleteCategory(
                                                        category.id);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList() ??
                                [],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredCategories?.categories.length ?? 0} / ${filteredCategories?.totalPages ?? 0}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Page $_currentPage of ${filteredCategories?.totalPages ?? 1}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _currentPage > 1
                                    ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                        _fetchCategories();
                                      }
                                    : null,
                                child: const Text('Previous',
                                    style: TextStyle(color: AppColors.primary)),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: (_currentPage <
                                        (filteredCategories?.totalPages ?? 1))
                                    ? () {
                                        setState(() {
                                          _currentPage++;
                                        });
                                        _fetchCategories();
                                      }
                                    : null,
                                child: const Text('Next',
                                    style: TextStyle(color: AppColors.primary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Add the form panel
              if (_showFormPanel) _buildCategoryFormPanel(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFormPanel() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: 400,
      child: Material(
        elevation: 8,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Category' : 'Add New Category',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _showFormPanel = false),
                  ),
                ],
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text('Category Name'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _categoryNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter category name',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Category Image'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedImage != null
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.white),
                                        onPressed: () => setState(
                                            () => _selectedImage = null),
                                      ),
                                    ),
                                  ],
                                )
                              : (_isEditing && _existingImageUrl != null)
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.network(
                                          _existingImageUrl!,
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 200,
                                          color: Colors.black.withOpacity(0.3),
                                          child: const Center(
                                            child: Text(
                                              'Click to change image',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.file_upload_outlined),
                                          Text('Click to upload image'),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () => setState(() => _showFormPanel = false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (_categoryNameController.text.isNotEmpty) {
                        if (_isEditing && _editingCategory != null) {
                          context.read<CategoryCubit>().updateCategory(
                                _editingCategory!.id,
                                _categoryNameController.text,
                                _selectedImage?.path ?? '',
                              );
                        } else {
                          if (_selectedImage != null) {
                            context.read<CategoryCubit>().createCategory(
                                  _categoryNameController.text,
                                  _selectedImage!.path,
                                );
                          }
                        }
                      }
                    },
                    child:
                        Text(_isEditing ? 'Update Category' : 'Add Category'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
