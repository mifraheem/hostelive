import 'package:flutter/material.dart';
import 'package:hostelive_app/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, List<String>> _fieldErrors = {};
  String? _selectedRole = 'user';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _fieldErrors = {};
    });

    try {
      final requestBody = json.encode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
      });

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/register/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        throw Exception('Invalid response format from server');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Color(0xFF1A365D), // Navy blue
          ),
        );

        Navigator.pushNamed(context, '/login');
      } else if (response.statusCode == 400) {
        setState(() {
          responseData.forEach((key, value) {
            if (value is List) {
              _fieldErrors[key] = List<String>.from(value);
            } else if (value is String) {
              _fieldErrors[key] = [value];
            }
          });

          if (_fieldErrors.containsKey('username') &&
              _fieldErrors.containsKey('email')) {
            _errorMessage = 'Both username and email are already taken.';
          } else if (_fieldErrors.containsKey('username')) {
            _errorMessage = 'This username is already taken.';
          } else if (_fieldErrors.containsKey('email')) {
            _errorMessage = 'This email is already registered.';
          } else {
            _errorMessage = 'Please correct the errors above and try again.';
          }
        });
      } else {
        setState(() {
          _errorMessage =
              responseData['message'] ??
              responseData['detail'] ??
              'Registration failed. Please try again later.';
        });
      }
    } catch (error) {
      setState(() {
        if (error.toString().contains('timeout')) {
          _errorMessage =
              'Request timed out. Please check your connection and try again.';
        } else if (error.toString().contains('SocketException')) {
          _errorMessage =
              'Cannot connect to the server. Please check your internet connection.';
        } else {
          _errorMessage =
              'An unexpected error occurred. Please try again later.';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White for professional look
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const SizedBox(height: 20.0),
                    Image.asset('assets/logo12.png', height: 200, width: 200),
                    const SizedBox(height: 20.0),
                    const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D), // Navy blue
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ), // Neutral dark gray
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Sharper corners
                          borderSide: BorderSide.none,
                        ),
                        fillColor:
                            _fieldErrors['username'] != null
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey.shade100, // Light gray background
                        filled: true,
                        prefixIcon: Icon(
                          Icons.person,
                          color:
                              _fieldErrors['username'] != null
                                  ? Colors.red
                                  : const Color(0xFF1A365D), // Navy blue
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),

                    if (_fieldErrors['username'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 12),
                        child: Text(
                          _fieldErrors['username']!.first,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        fillColor:
                            _fieldErrors['email'] != null
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey.shade100, // Light gray background
                        filled: true,
                        prefixIcon: Icon(
                          Icons.email,
                          color:
                              _fieldErrors['email'] != null
                                  ? Colors.red
                                  : const Color(0xFF1A365D), // Navy blue
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    if (_fieldErrors['email'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 12),
                        child: Text(
                          _fieldErrors['email']!.first,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        fillColor:
                            _fieldErrors['password'] != null
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey.shade100, // Light gray background
                        filled: true,
                        prefixIcon: Icon(
                          Icons.password,
                          color:
                              _fieldErrors['password'] != null
                                  ? Colors.red
                                  : const Color(0xFF1A365D), // Navy blue
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                    ),

                    if (_fieldErrors['password'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 12),
                        child: Text(
                          _fieldErrors['password']!.first,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        fillColor:
                            Colors.grey.shade100, // Light gray background
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.password,
                          color: Color(0xFF1A365D), // Navy blue
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        hintText: "Select Role",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        fillColor:
                            Colors.grey.shade100, // Light gray background
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF1A365D), // Navy blue
                        ),
                      ),
                      items:
                          <String, String>{
                            'user': 'Student',
                            'business_admin': 'Business Admin',
                          }.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Match input fields
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF1A365D), // Navy blue
                      disabledBackgroundColor: const Color(
                        0xFF1A365D,
                      ).withOpacity(0.5),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white, // White for contrast
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white, // White text
                              ),
                            ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.black54,
                      ), // Neutral dark gray
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF1A365D), // Navy blue
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
