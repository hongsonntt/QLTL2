import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'screens/intro_screen.dart';
import 'screens/webview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WebViewPlatform.instance = WebWebViewPlatform();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Management Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isAuthenticated = false;
  String _currentPasscode = '';
  
  static final List<Widget> _screens = [
    const IntroScreen(),
    const WebViewScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPasscodeDialog();
    });
  }

  String _getTodayPasscode() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}';
  }

  void _addDigit(String digit) {
    if (_currentPasscode.length < 4) {
      setState(() {
        _currentPasscode += digit;
      });

      // Check passcode when 4 digits are entered
      if (_currentPasscode.length == 4) {
        _checkPasscode();
      }
    }
  }

  void _removeDigit() {
    if (_currentPasscode.isNotEmpty) {
      setState(() {
        _currentPasscode = _currentPasscode.substring(0, _currentPasscode.length - 1);
      });
    }
  }

  void _checkPasscode() {
    if (_currentPasscode == _getTodayPasscode()) {
      setState(() {
        _isAuthenticated = true;
      });
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã không đúng. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _currentPasscode = '';
      });
    }
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextButton(
          onPressed: () => _addDigit(number),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Text(
            number,
            style: const TextStyle(fontSize: 24, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  void _showPasscodeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text(
                  'Nhập mã truy cập\n(Ngày hiện tại)',
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Passcode dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _currentPasscode.length 
                              ? const Color.fromARGB(255, 73, 54, 244)
                              : Colors.grey.shade300,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    // Number pad
                    Column(
                      children: [
                        Row(
                          children: [
                            _buildNumberButton('1'),
                            _buildNumberButton('2'),
                            _buildNumberButton('3'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildNumberButton('4'),
                            _buildNumberButton('5'),
                            _buildNumberButton('6'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildNumberButton('7'),
                            _buildNumberButton('8'),
                            _buildNumberButton('9'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Container()),
                            _buildNumberButton('0'),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: TextButton(
                                  onPressed: _removeDigit,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      side: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  child: const Icon(Icons.backspace_outlined, color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.all(20),
              );
            },
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Banner(  
      message: 'DEMO',  
      location: BannerLocation.topEnd,
      color: const Color.fromARGB(255, 73, 54, 244),
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Hướng dẫn',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.web),
                    label: 'Vào app',
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.white,
                selectedItemColor: const Color.fromARGB(255, 73, 54, 244),
                unselectedItemColor: Colors.grey,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}