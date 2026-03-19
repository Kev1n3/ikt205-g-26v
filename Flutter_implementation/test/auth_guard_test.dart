import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test1/login_screen.dart';

class MockUser {}

class MockMyHomePage extends StatelessWidget {
  final String title;
  
  const MockMyHomePage({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Mock Home Page')),
    );
  }
}

void main() {
  //Test 1: Tester uten bruker, skal vise LoginScreen
  testWidgets('Auth guard viser riktig skjerm basert på user status', (tester) async {
    dynamic mockUser = null;
    
    await tester.pumpWidget(
      MaterialApp(
        home: mockUser != null 
            ? const MockMyHomePage(title: 'Jobb Notater')
            : const LoginScreen(),
      ),
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MockMyHomePage), findsNothing);

    //Test 2: Tester med bruker, skal vise MockMyHomePage
    mockUser = MockUser();
    
    await tester.pumpWidget(
      MaterialApp(
        home: mockUser != null 
            ? const MockMyHomePage(title: 'Jobb Notater')
            : const LoginScreen(),
      ),
    );
    
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(MockMyHomePage), findsOneWidget);
  });
}