import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbshop/service_AI/preprocess_service.dart';
import 'package:tbshop/service_AI/recommender_service.dart';
import 'package:tbshop/viewmodels/auth_viewmodel.dart';
import 'package:tbshop/viewmodels/cart_viewmodel.dart';
import 'package:tbshop/viewmodels/category_viewmodel.dart';
import 'package:tbshop/viewmodels/product_viewmodel.dart';
import 'package:tbshop/viewmodels/rating_viewmodel.dart';
import 'View/Admin/HomePageAdmin.dart';
import 'View/User/HomePage.dart';
import 'View/Login/login.dart';
import 'firebase_options.dart';
import 'chat_screen.dart';
import 'service_AI/firebase_service.dart';  // Assuming FirebaseService is used to fetch data

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => CategoryViewModel()..fetchCategories()),
        ChangeNotifierProvider(create: (context) => ProductViewModel()),
       // ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (context) => CartViewModel()),
        ChangeNotifierProvider(create: (context) => RatingViewModel()),

        // Provide HybridRecommender by passing the required dependencies (PreprocessingService)
      Provider<HybridRecommender>(
        create: (context) => HybridRecommender(
          PreprocessingService(), // Pass as a positional argument
        ),
      ),

        // Firebase Service to handle all Firebase operations (data fetching)
        Provider<FirebaseService>(create: (context) => FirebaseService()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return FutureBuilder<bool>(
            future: authViewModel.loadUserFromLocal(),  // Check if user is logged in
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              // Based on the authentication state, navigate to the correct page
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: snapshot.hasData && snapshot.data == true
                    ? (authViewModel.isAdmin
                    ? const HomePageAdmin()  // If admin, show admin homepage
                    : const HomePage())      // If user, show user homepage
                    : const HomePage(),           // If not logged in, show login screen
              );
            },
          );
        },
      ),
    );
  }
}

