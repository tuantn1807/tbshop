import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../viewmodels/category_viewmodel.dart';

import '../../constants.dart';
import '../category/add_category_screen.dart';
import '../product/product_category_screen.dart';
import 'responsive.dart';
class Category_HomePage extends StatelessWidget {
  const Category_HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Danh sách danh mục",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {

              },
              icon: IconButton(
    icon: Icon(Icons.add),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCategoryScreen(),
        ),
      );
    },
    ),
              label: Text(""),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        Consumer<CategoryViewModel>(
          builder: (context, categoryViewModel, child) {
            final categories = categoryViewModel.categories.take(4).toList(); // Limit to 4 categories
            if (categories.isEmpty) {
              return Center(child: Text("No categories available."));
            }
            return Responsive(
              mobile: CategoryGridView(
               categories: categories,
                childAspectRatio: _size.width < 650 ? (_size.width > 350 ? 1.5 : 1.2) : 1.3,
                crossAxisCount: _size.width < 650 ? 3 : 5,
              ),
              tablet: CategoryGridView(categories: categories),
              desktop: CategoryGridView(
                categories: categories,
                childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
              ),
            );
          },
        ),
      ],
    );
  }
}
class CategoryGridView extends StatelessWidget {
  const CategoryGridView({
    Key? key,
    required this.categories,
    this.crossAxisCount = 5, // Increased to display more items per row
    this.childAspectRatio = 0.8, // Adjusted to make items smaller
  }) : super(key: key);

  final List categories;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding / 2, // Reduced spacing
        mainAxisSpacing: defaultPadding / 2, // Reduced spacing
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductCategoryScreen(categoryId: category.id),
              ),
            );
          },
          child: Card(
            elevation: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}