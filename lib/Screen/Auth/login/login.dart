import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Bloc/login/login_bloc.dart';
import '../../Dashbord/Dashboard/Dashboard.dart';

class MyloginPage extends StatefulWidget {
   MyloginPage({super.key});

  @override
  State<MyloginPage> createState() => _MyloginPageState();
}

class _MyloginPageState extends State<MyloginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding:  EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 SizedBox(height: 60),

                // --- Logo/Icon ---
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color:  Color(0xFF3B82F6), // Bright blue from image
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child:  Icon(
                    Icons.bolt,
                    color: Colors.white,
                    size: 60,
                  ),
                ),

                 SizedBox(height: 32),

                // --- Title and Subtitle ---
                 Text(
                  'Power Supply',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                 SizedBox(height: 8),
                 Text(
                  'Meter Reading Management System',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),

                 SizedBox(height: 48),

                // --- Phone Input ---
                Align(
                  alignment: Alignment.centerLeft,
                  child:  Text(
                    'Phone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                 SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    contentPadding:  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:  BorderSide(color: Colors.grey),
                    ),
                  ),
                ),

                 SizedBox(height: 24),

                // --- Password Input ---
                Align(
                  alignment: Alignment.centerLeft,
                  child:  Text(
                    'Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                 SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    contentPadding:  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:  BorderSide(color: Colors.grey),
                    ),
                  ),
                ),

                 SizedBox(height: 40),

                // --- Login Button ---
                BlocListener<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ ${state.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (state is LoginSuccess) {
                      final userName = state.userData['name'] ?? 'User';
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Login Successful! Welcome back, $userName'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      // Navigate to Dashboard and remove login screen from stack
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardPage(),
                        ),
                      );
                    }
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final phone = _phoneController.text.trim();
                        final password = _passwordController.text.trim();

                        if (phone.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter both phone and password'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Dispatch login event
                        context.read<LoginBloc>().add(
                          LoginSubmitted(phone: phone, password: password),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Login',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}