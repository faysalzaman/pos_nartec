// ignore_for_file: deprecated_member_use

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pos/cubit/category/category_cubit.dart';
import 'package:pos/cubit/category/category_state.dart';
import 'package:pos/model/category/category_model.dart';
import 'package:pos/utils/app_colors.dart';

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

  @override
  void dispose() {
    searchController.dispose();
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
              Column(
                children: [
                  // Search and Filter Section
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
                                    currentPage: categories?.currentPage ?? '',
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
                        // ElevatedButton.icon(
                        //   onPressed: () {
                        //     setState(() {
                        //       _showFilterPanel = !_showFilterPanel;
                        //     });
                        //   },
                        //   icon: const Icon(Icons.filter_list),
                        //   label: const Text('Filters'),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: AppColors.primary,
                        //     foregroundColor: Colors.white,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
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
                                      onSelectChanged: (_) {
                                        // AppNavigator.push(
                                        //   context,
                                        //   SalesDetailScreen(
                                        //     id: category.id,
                                        //     orderType: category.name,
                                        //     rowPerPage: _rowsPerPage,
                                        //     currentRow: _currentPage,
                                        //   ),
                                        // );
                                      },
                                      cells: [
                                        DataCell(
                                          Image.network(
                                            category.image,
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                        DataCell(
                                          Text(category.name),
                                        ),
                                        DataCell(Text(category.id.toString())),
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
                                                onPressed: () {
                                                  // TODO: Implement edit functionality
                                                  print(
                                                      'Edit category: ${category.id}');
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  _deleteCategory(category.id);
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
              // // Filter Panel
              // if (_showFilterPanel)
              //   Positioned(
              //     right: 0,
              //     top: 0,
              //     bottom: 0,
              //     width: 300,
              //     child: Material(
              //       elevation: 8,
              //       child: Container(
              //         color: Colors.white,
              //         padding: const EdgeInsets.all(16),
              //         child: SingleChildScrollView(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   const Text('Filters',
              //                       style: TextStyle(
              //                           fontSize: 20,
              //                           fontWeight: FontWeight.bold)),
              //                   IconButton(
              //                     onPressed: () {
              //                       setState(() => _showFilterPanel = false);
              //                     },
              //                     icon: const Icon(Icons.close),
              //                   ),
              //                 ],
              //               ),
              //               const SizedBox(height: 16),
              //               _buildDropdown(
              //                   'By Order Type', orderType, byOrderType,
              //                   (value) {
              //                 setState(() => byOrderType = value!);
              //               }),
              //               _buildDropdown('By Taker', taker, takerBy, (value) {
              //                 setState(() => takerBy = value!);
              //               }),
              //               _buildDropdown('By Chef', chef, chefBy, (value) {
              //                 setState(() => chefBy = value!);
              //               }),
              //               _buildDropdown('By Cashier', cashier, checkoutBy,
              //                   (value) {
              //                 setState(() => checkoutBy = value!);
              //               }),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          );
        },
      ),
    );
  }
}
