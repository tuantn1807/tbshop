
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../components/category_homepage.dart';
import '../components/header.dart';
import '../components/product_homepage.dart';
import '../components/responsive.dart';


class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Category_HomePage(),
                      SizedBox(height: defaultPadding),
                      ProductHomePageScreen(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                    //  if (Responsive.isMobile(context)) StorageDetails(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it

              ],
            )
          ],
        ),
      ),
    );
  }
}
