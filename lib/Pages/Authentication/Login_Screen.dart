import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import your AuthService here
import '../../services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  Future<void> _signInWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userCredential = await _authService.signInWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        
        if (userCredential != null && mounted) {
          // Successfully signed in
          Navigator.pushReplacementNamed(context, '/main');
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = _getAuthErrorMessage(e.code);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: ${e.toString()}")),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Updated _signInWithGoogle method for LoginScreen

Future<void> _signInWithGoogle() async {
  setState(() => _isGoogleLoading = true);
  try {
    final userCredential = await _authService.signInWithGoogle();
    
    // Check if user is signed in (either through userCredential or directly checking auth state)
    if (userCredential != null || _authService.currentUser != null) {
      if (mounted) {
        debugPrint("🚀 Redirecting to main screen...");
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  } catch (e) {
    debugPrint("🔥 Google Sign-In Error in UI: $e");
    
    // FINAL BYPASS: Check if user is actually signed in despite any error
    await Future.delayed(Duration(milliseconds: 1000)); // Wait a bit longer
    
    if (_authService.currentUser != null && mounted) {
      debugPrint("🎯 FINAL BYPASS: User is signed in, redirecting anyway!");
      Navigator.pushReplacementNamed(context, '/main');
      return;
    }
    
    // Only show error if user is really not signed in
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: ${e.toString()}")),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isGoogleLoading = false);
    }
  }
}

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 24),
                
                // Sign in button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithEmailPassword,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          "Sign In",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                
                SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "or",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Google sign in button
                OutlinedButton.icon(
                  onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isGoogleLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
                  label: Text(
                    _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        // Navigate to sign up screen
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text("Sign Up"),
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
}