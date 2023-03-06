import 'package:flutter/material.dart';
import 'package:oneapp/services/backend/chatgpt_api.dart';
import 'package:oneapp/services/preference/app_preference.dart';
import 'package:oneapp/ui/home_page.dart';
import 'package:oneapp/repositories/subapp_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final appPref = AppPreference(prefs);

  runApp(
    MyApp(
      appPref: appPref,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.appPref,
  });

  final AppPreference appPref;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SubappRepository()),
        Provider.value(value: appPref),
        Provider.value(value: ChatgptApi(appPref.apiKey)),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          title: 'OneTool',
          debugShowCheckedModeBanner: false,
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
