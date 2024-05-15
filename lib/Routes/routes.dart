// import 'package:api_dados/filter/model.dart';
// import 'package:api_dados/views/user_detail_page_view.dart';
// import 'package:api_dados/views/user_edit_page_view.dart';
// import 'package:flutter/material.dart';

// class Routes {
//   static const String userEditPage = '/userEditPage';
//   static const String userDetailPage = '/userDetailPage';

//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case userEditPage:
//         final user = settings.arguments as PersonModel; // Assumindo que você passa um modelo de usuário
//         return MaterialPageRoute(builder: (_) => UserEditPage(user: user));
//       case userDetailPage:
//         final user = settings.arguments as PersonModel;
//         return MaterialPageRoute(builder: (_) => UserDetailPage(user: user));
//       default:
//         return _errorRoute();
//     }
//   }

//   static Route<dynamic> _errorRoute() {
//     return MaterialPageRoute(builder: (_) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Error'),
//         ),
//         body: Center(
//           child: Text('Page not found!'),
//         ),
//       );
//     });
//   }
// }