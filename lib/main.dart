import 'package:flutter/material.dart';
import 'package:oneapp/services/backend/chatgpt_api.dart';
import 'package:oneapp/ui/home_page.dart';
import 'package:oneapp/repositories/subapp_repository.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SubappRepository()),
        Provider.value(value: ChatgptApi()),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          title: 'OneTool',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              elevation: 0,
            ),
            scaffoldBackgroundColor: Colors.grey[200],
          ),
          home: const HomePage(),
        );
      }),
    );
  }
}
