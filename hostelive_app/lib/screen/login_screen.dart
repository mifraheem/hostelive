import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/constant.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;
  String _selectedRole = 'student';
  final _storage = const FlutterSecureStorage();
  Map<String, List<String>> _fieldErrors = {};

  final List<Map<String, String>> _roleOptions = [
    {'value': 'student', 'label': 'Student'},
    {'value': 'admin', 'label': 'Admin'},
  ];

  Future<void> _login() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _fieldErrors = {};
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'role': _selectedRole,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['access'] != null) {
            await _storage.write(key: 'access_token', value: data['access']);
            await _storage.write(
              key: 'username',
              value: data['user']?['username'] ?? 'Unknown User',
            );
            await _storage.write(key: 'user_role', value: _selectedRole);

            _navigateBasedOnRole();
          } else {
            setState(() {
              _errorMessage = 'Login failed. Please try again.';
            });
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Something went wrong. Please try again.';
          });
        }
      } else if (response.statusCode == 400) {
        _handleValidationErrors(response);
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Invalid username or password.';
        });
      } else if (response.statusCode >= 500) {
        setState(() {
          _errorMessage = 'Server error. Please try again later.';
        });
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleValidationErrors(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      setState(() {
        data.forEach((key, value) {
          if (value is List) {
            _fieldErrors[key] = List<String>.from(value);
          } else if (value is String) {
            _fieldErrors[key] = [value];
          }
        });
        _errorMessage = 'Please correct the errors above and try again.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid response format from server.';
      });
    }
  }

  void _navigateBasedOnRole() {
    if (_selectedRole == 'student') {
      Navigator.pushReplacementNamed(context, '/student-dashboard');
    } else if (_selectedRole == 'admin') {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 224, 236, 251),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildInputFields(),
                const SizedBox(height: 20),
                _buildSignUpLink(),
                if (_errorMessage != null) _buildErrorMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/logo.png', height: 200, width: 200),
        const SizedBox(height: 20),
        const Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE6C871),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Enter your credentials to login",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color.fromARGB(179, 12, 13, 70),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role Selection Dropdown
        _buildRoleSelector(),
        const SizedBox(height: 20),

        // Username Field
        _buildUsernameField(),
        const SizedBox(height: 20),

        // Password Field
        _buildPasswordField(),
        const SizedBox(height: 20),

        // Login Button
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Role',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3B5A7A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3B5A7A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              prefixIcon: const Icon(
                Icons.admin_panel_settings,
                color: Color(0xFFE6C871),
              ),
            ),
            items:
                _roleOptions.map((role) {
                  return DropdownMenuItem<String>(
                    value: role['value'],
                    child: Text(
                      role['label']!,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedRole = newValue;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a role';
              }
              return null;
            },
          ),
        ),
        if (_fieldErrors['role'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 12),
            child: Text(
              _fieldErrors['role']!.first,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: "Username",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor:
                _fieldErrors['username'] != null
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFF3B5A7A).withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(
              Icons.person,
              color:
                  _fieldErrors['username'] != null
                      ? Colors.red
                      : const Color(0xFFE6C871),
            ),
          ),
          style: const TextStyle(color: Colors.black),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your username';
            }
            return null;
          },
        ),
        if (_fieldErrors['username'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 12),
            child: Text(
              _fieldErrors['username']!.first,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor:
                _fieldErrors['password'] != null
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFF3B5A7A).withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(
              Icons.lock,
              color:
                  _fieldErrors['password'] != null
                      ? Colors.red
                      : const Color(0xFFE6C871),
            ),
          ),
          obscureText: true,
          style: const TextStyle(color: Colors.black),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
        if (_fieldErrors['password'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 12),
            child: Text(
              _fieldErrors['password']!.first,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFFE6C871),
        disabledBackgroundColor: const Color(0xFFE6C871).withOpacity(0.5),
      ),
      child:
          _isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
              : const Text(
                "Login",
                style: TextStyle(fontSize: 20, color: Color(0xFF3B5A7A)),
              ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Color.fromARGB(179, 12, 13, 70)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Color(0xFFE6C871)),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
